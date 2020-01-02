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

public enum NetworkAccessible {
    case unknown
    case available
    case unavailable
}

public struct NetworkAnalysisDataPoint {
    public let url: String
    public let status: NetworkAccessible
    public let timestamp: Date
    public let latency: Double // in ms
    public let bandwidth: Double // in Kbytes per second

    /// Convenience initializer for quick sample data points
    public init(url: String, latency: Double, bandwidth: Double) {
        self.url = url
        status = .available
        timestamp = Date()
        self.latency = latency
        self.bandwidth = bandwidth
    }

    public init(fromMetric metric: URLSessionTaskTransactionMetrics) {
        url = metric.request.debugDescription

        if let _: URLResponse = metric.response {
            status = .available
        } else {
            status = .unknown
        }
        timestamp = metric.fetchStartDate ?? Date()

        if let requestEnd = metric.requestEndDate, let responseStart = metric.responseStartDate {
            latency = responseStart.timeIntervalSince(requestEnd) * 1000
        } else {
            latency = 0
        }

        if let responseStart = metric.responseStartDate, let responseEnd = metric.responseEndDate {
            bandwidth = Double(metric.countOfResponseBodyBytesReceived)
                / responseEnd.timeIntervalSince(responseStart) / 1024
        } else {
            bandwidth = 0
        }
    }
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

    public var metricPublisher = PassthroughSubject<NetworkAnalysisDataPoint, Never>()
    public var networkCheckTimerPublisher = PassthroughSubject<Date, Never>()
    public var networkPathPublisher = PassthroughSubject<NWPath, Never>()

    public init(wifi _: String, urlsToCheck: [String]) {
        active = false
        dataTasks = [:]
        urlsToValidate = urlsToCheck

        super.init()

        session = setupURLSession()
        monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        monitor?.pathUpdateHandler = networkPathUpdate
    }

    public func start() {
        os_log("Activating network analyzer!", log: OSLog.netcheck, type: .info)
        active = true
        monitor?.start(queue: queue)
        cancellableTimer = Timer.publish(every: timerinterval, on: RunLoop.main, in: .default)
            .autoconnect()
            .sink { timestamp in
                // send a notification to any external subscribers wanting to know we are
                // triggering a URL check sequence
                self.networkCheckTimerPublisher.send(timestamp)
                // And actually do the checking...
                self.resetAndCheckURLS()
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
        networkPathPublisher.send(path)
    }

    private func resetAndCheckURLS() {
        os_log("resetAndCheckURLS", log: OSLog.netcheck, type: .debug)
        session?.reset {
            // test each of the URLs for access
            for urlString in self.urlsToValidate {
                if self.dataTasks[urlString] != nil {
                    // if there's already a task there, kill it and make another
                    self.dataTasks[urlString]?.cancel()
                    self.dataTasks[urlString] = nil
                }

                self.dataTasks[urlString] = self.testURLaccess(urlString: urlString)
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

        let dataTask = session?.dataTask(with: urlRequest)
        dataTask?.resume()
        return dataTask
    }

    // MARK: URLSessionTaskDelegate methods

    // NOTE(heckj): lesson learned - URLSession (even with `.reset()` will re-use an established connection,
    // so future connections will happen *very* quickly, and some metrics are likely to be missing. What I
    // saw is that the first request had a full set of metrics, but follow on requests are missing the domain
    // and connection metrics, and the metric had "Reused Connection == true" set on it.
    //
    // You still get a requestDuration and responseDuration for the (final) redirected request
    //
    // You also get a metric for every segment of the request. In my sample case, I'm requesting "google.com"
    // and the first thing is a 301 redirect to www.google.com, followed by the request there, following the
    // redirect. The final metric is the more "useful" one, especially w/ bandwith - as it seems you really need
    // to transfer a fair bit to get to a meaningful value there.

    public func urlSession(_: URLSession,
                           task _: URLSessionTask,
                           didFinishCollecting metrics: URLSessionTaskMetrics) {
        // check the metrics
        print("task duration (ms): ", metrics.taskInterval.duration * 1000)
        // rather than iterate over the whole set, we'll just grab the final metric under the (hopefully
        // correct) assumption that it is the final data/redirect location for getting the URL data
        if let metric = metrics.transactionMetrics.last {
            // metric : URLSessionTaskTransactionMetrics
            metricPublisher.send(NetworkAnalysisDataPoint(fromMetric: metric))
            //
            print("========================================================================")
            print("request ", metric.request.debugDescription)

            print("url.absoluteString ", metric.request.url?.absoluteString as Any)
            // some of the rest of this may not actually exist if the request fails... need to check nils...
            if let fetchStartDate = metric.fetchStartDate {
                print("fetchStart ", fetchStartDate)
            }

            // the metrics don't universally exist on the "repeat" checkings...
            // not entirely sure why, need to spend a while with the debugger and seeing what's getting triggered
            if let domainStart = metric.domainLookupStartDate,
                let domainEnd = metric.domainLookupEndDate {
                print("domainDuration (ms) ", domainEnd.timeIntervalSince(domainStart) * 1000)
            } else {
                print("NO domainDuration")
            }

            if let connectStart = metric.connectStartDate, let connectEnd = metric.connectEndDate {
                print("connectDuration (ms) ", connectEnd.timeIntervalSince(connectStart) * 1000) // <<= latency
            } else {
                print("NO connectDuration")
            }

            if let requestEnd = metric.requestEndDate, let responseStart = metric.responseStartDate {
                print("alt latency (req end -> resp start) (ms) ", responseStart.timeIntervalSince(requestEnd) * 1000)
            } else {
                print("NO altLatency")
            }

            if let requestStart = metric.requestStartDate, let requestEnd = metric.requestEndDate {
                print("requestDuration (ms) ", requestEnd.timeIntervalSince(requestStart) * 1000)
            } else {
                print("NO requestDuration")
            }

            if let responseStart = metric.responseStartDate, let responseEnd = metric.responseEndDate {
                print("responseDuration (ms) ", responseEnd.timeIntervalSince(responseStart) * 1000)

                print("bandwidth (K/sec) ",
                      Double(metric.countOfResponseBodyBytesReceived)
                          / responseEnd.timeIntervalSince(responseStart)
                          / 1024)
            } else {
                print("NO responseDuration (or bandwidth)")
            }
        }
    }
}
