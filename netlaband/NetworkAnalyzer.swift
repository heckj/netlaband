//
//  NetworkAnalyzer.swift
//  netlaband
//
//  Created by Joseph Heck on 3/18/19.
//  Copyright © 2019 JFH Consulting. All rights reserved.
//

import Combine
import Foundation
import Network
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let netcheck = OSLog(subsystem: subsystem,
                                category: String(describing: NetworkAnalyzer.self))
    // specifically to allow os_log to this category...
    // os_log("View did load!", log: OSLog.netcheck, type: .info)

    // TO WATCH, use Console.log and limit to the string:
    //   process:netlaband category:NetworkAnalyzer
}

enum NetworkAccessible {
    case unknown
    case available
    case unavailable
}

struct NetworkAnalyzerUrlResponse {
    let url: String
    var status: NetworkAccessible
}

public struct NetworkAnalysisDataPoint {
    let url: String
    let status: NetworkAccessible
    let timestamp: Date
    let latency: Double
    let bandwidth: Double
}

public class NetworkAnalyzer: NSObject, URLSessionTaskDelegate {
    private var active: Bool
    private var session: URLSession?
    private var monitor: NWPathMonitor?
    private var cancellableTimer: Cancellable?

    // explicit dispatch queue for the NWPathMonitor
    private let queue = DispatchQueue(label: "netmonitor")
    private let concurrentURLUpdateQueue =
        DispatchQueue(
            label: "networkAnalyzer.urlupdates",
            attributes: .concurrent
        )
    private let timedURLCheckQueue = DispatchQueue(label: "networkAnalyzer.timercheck")
    // references the dataTask objects for validating URLs indexed by string/URL
    // - gives us a handle the cancel them if needed...
    private var dataTasks: [String: URLSessionDataTask]
    private var dataTaskResponses: [String: NetworkAnalyzerUrlResponse]

    weak var delegate: NetworkAnalyzerDelegate?

    public var urlsToValidate: [String]
    public var timerinterval: TimeInterval = 5 // seconds

    // encapsulate but expose the specifics for the PATH to be able check
    // the status of it:
    //
    // switch path.status {
    //   case .satisfied:
    //   case .requiresConnection:
    //   case .unsatisfied:
    // }
    public var path: NWPath? { // read-only 'computed' property
        monitor?.currentPath
    }

    public var publisher: PassthroughSubject<NetworkAnalysisDataPoint, Never>

    public init(wifi _: String, urlsToCheck: [String]) {
        active = false
        dataTasks = [:]
        dataTaskResponses = [:]
        urlsToValidate = urlsToCheck
        publisher = PassthroughSubject<NetworkAnalysisDataPoint, Never>()

        super.init()

        session = setupURLSession()
        monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        monitor?.pathUpdateHandler = networkPathUpdate
    }

    public func start() {
        os_log("Activating network analyzer!", log: OSLog.netcheck, type: .info)
        active = true
        monitor?.start(queue: queue)
        cancellableTimer = Timer.publish(every: timerinterval, on: RunLoop.main, in: .default).autoconnect().sink { _ in
            self.checkURLs()
        }
    }

    public func stop() {
        os_log("Deactivating network analyzer!", log: OSLog.netcheck, type: .info)
        // immediately cease all network operations in URLSession
        session?.invalidateAndCancel()
        monitor?.cancel()
        if let cancellable = self.cancellableTimer {
            cancellable.cancel()
        }
        active = false
        // reset the session for running again in the future
        session = setupURLSession()
    }

    public func checkURLs() {
        resetAndCheckURLS()
    }

    // setup and configure the URLSession for checking URLs
    private func setupURLSession() -> URLSession {
        let urlRequestQueue = OperationQueue()
        urlRequestQueue.name = "urlRequests"
        urlRequestQueue.qualityOfService = .userInteractive

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = 5
        configuration.allowsCellularAccess = false
        configuration.waitsForConnectivity = false
        configuration.allowsConstrainedNetworkAccess = true
        configuration.allowsExpensiveNetworkAccess = true
        return URLSession(configuration: configuration,
                          delegate: self,
                          delegateQueue: urlRequestQueue)
    }

    // callbacks and the cascade of checking

    private func networkPathUpdate(_ path: NWPath) {
        // called when the network path changes
        switch path.status {
        case .satisfied:
            os_log("NWPath update: satisfied", log: OSLog.netcheck, type: .debug)
        case .requiresConnection:
            os_log("NWPath update: requiresConnection", log: OSLog.netcheck, type: .debug)
        case .unsatisfied:
            os_log("NWPath update: unsatisfied", log: OSLog.netcheck, type: .debug)
        @unknown default:
            fatalError("unknown and unexpected NWPathMonitor path update")
        }

        resetAndCheckURLS()
    }

    private func resetAndCheckURLS() {
        session?.reset {
            // test each of the URLs for access
            for urlString in self.urlsToValidate {
                if self.dataTasks[urlString] != nil {
                    // if there's already a task there, kill it and make another
                    self.dataTasks[urlString]?.cancel()
                    self.dataTasks[urlString] = nil
                }

                self.dataTasks[urlString] = self.testURLaccess(urlString: urlString)
                let response = NetworkAnalyzerUrlResponse(url: urlString, status: .unknown)
                self.concurrentURLUpdateQueue.async(flags: .barrier) { [weak self] in
                    // make sure [weak self] is still assigned/valid before continuing
                    guard let self = self else {
                        return
                    }
                    // store it
                    self.dataTaskResponses[urlString] = response
                    // and send it over to the delegate
                    self.delegate?.urlUpdate(urlresponse: response)
                }
            }
        }
    }

    private func testURLaccess(urlString: String) -> URLSessionDataTask? {
        guard let url = URL(string: urlString) else {
            // kind of an open question of if this would be better as an error
            // vs. logged/silent failure
            os_log("Couldn't make %{public}@ into a URL",
                   log: OSLog.netcheck, type: .error, urlString, urlString)
            return nil
        }
        os_log("creating dataTask to check: %{public}@",
               log: OSLog.netcheck, type: .info, urlString)
        let urlRequest = URLRequest(url: url)

        /*
         In your extension delegate’s applicationWillResignActive() method, cancel any outstanding
         tasks by calling the URLSessionTask object’s cancel() method.
         */

        let dataTask = session?.dataTask(with: urlRequest) { data, response, error in
            // clean up after ourselves...
            // defer { self.dataTask = nil }

            // check for errors
            guard error == nil else {
                os_log("%{public}@ error:  %{public}@",
                       log: OSLog.netcheck, type: .error, urlString, String(describing: error))
                let updatedResponse = NetworkAnalyzerUrlResponse(url: urlString, status: .unavailable)

                self.concurrentURLUpdateQueue.async(flags: .barrier) { [weak self] in
                    // make sure [weak self] is still assigned/valid before continuing
                    guard let self = self else {
                        return
                    }
                    // store it
                    self.dataTaskResponses[urlString] = updatedResponse
                    // and send it over to the delegate
                    self.delegate?.urlUpdate(urlresponse: updatedResponse)
                }
                return
            }
            // make sure we gots the data
            if data != nil,
                let response = response as? HTTPURLResponse {
                os_log("%{public}@ status code: %{public}d",
                       log: OSLog.netcheck, type: OSLogType.info, urlString, response.statusCode)
                let updatedResponse = NetworkAnalyzerUrlResponse(url: urlString, status: .available)
                self.concurrentURLUpdateQueue.async(flags: .barrier) { [weak self] in
                    // make sure [weak self] is still assigned/valid before continuing
                    guard let self = self else {
                        return
                    }
                    // store it
                    self.dataTaskResponses[urlString] = updatedResponse
                    // and send it over to the delegate
                    self.delegate?.urlUpdate(urlresponse: updatedResponse)
                }
            }
        }
        dataTask?.resume()
        return dataTask
    }

    // MARK: URLSessionTaskDelegate methods

    public func urlSession(_: URLSession,
                           task _: URLSessionTask,
                           didFinishCollecting metrics: URLSessionTaskMetrics) {
        // check the metrics
        print("task duration (ms): ", metrics.taskInterval.duration * 1000)
        print("redirect count was: ", metrics.redirectCount)
        print("details...")
        let transactionMetricsList = metrics.transactionMetrics
        for metric in transactionMetricsList {
            print("request ", metric.request.debugDescription)
            print("fetchStart ", metric.fetchStartDate!)
            print("url.absoluteString ", metric.request.url?.absoluteString as Any)
            // some of the rest of this may not actually exist if the request fails... need to check nils...

            // the metrics don't universally exist on the "repeat" checkings...
            // not entirely sure why, need to spend a while with the debugger and seeing what's getting triggered
            if let domainStart = metric.domainLookupStartDate,
                let domainEnd = metric.domainLookupEndDate,
                let connectStart = metric.connectStartDate,
                let connectEnd = metric.connectEndDate,
                let requestStart = metric.requestStartDate,
                let requestEnd = metric.requestEndDate,
                let responseStart = metric.responseStartDate,
                let responseEnd = metric.responseEndDate {
                print("domainDuration (ms) ", domainEnd.timeIntervalSince(domainStart) * 1000)
                print("connectDuration (ms) ", connectEnd.timeIntervalSince(connectStart) * 1000) // <<= latency
                print("requestDuration (ms) ", requestEnd.timeIntervalSince(requestStart) * 1000)
                print("responseDuration (ms) ", responseEnd.timeIntervalSince(responseStart) * 1000)
                print("bandwidth (K/sec) ",
                      Double(metric.countOfResponseBodyBytesReceived)
                          / responseEnd.timeIntervalSince(responseStart)
                          / 1024)
                guard let fetchStartDate = metric.fetchStartDate else {
                    break
                }
                let datapoint = NetworkAnalysisDataPoint(url: metric.request.debugDescription,
                                                         status: .available,
                                                         timestamp: fetchStartDate,
                                                         latency: connectEnd.timeIntervalSince(connectStart) * 1000,
                                                         bandwidth: Double(metric.countOfResponseBodyBytesReceived)
                                                             / responseEnd.timeIntervalSince(responseStart)
                                                             / 1024)

                publisher.send(datapoint)
//                concurrentURLUpdateQueue.async(flags: .barrier) { [weak self] in
//                    // make sure [weak self] is still assigned/valid before continuing
//                    guard let self = self else {
//                        return
//                    }
//                    // store it
//                    self.dataTaskMetrics[datapoint.url] = datapoint
//                }
            }
        }
    }
}
