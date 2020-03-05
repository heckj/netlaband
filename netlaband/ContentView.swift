//
//  ContentView.swift
//  netlaband
//
//  Created by Joseph Heck on 12/27/19.
//  Copyright © 2019 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct ContentView: View {
    @ObservedObject var networkModel: NetworkAnalyzer
    @State private var metrics = CircularBuffer<NetworkAnalysisDataPoint>(initialCapacity: 10)

    let date = Date()
    var body: some View {
        VStack {
            NetworkAnalyzerControlView(networkModel: networkModel)
            HStack {
                Text("\(metrics.count) datapoints")
            }
            DataPointCollectionView(points: self.metrics, scale: LogScale(domain: 1 ... 10000.0, isClamped: false))

            List(self.metrics) { dp in
                DataPointTextView(dp: dp)
            }
            .onReceive(networkModel.metricPublisher.receive(on: RunLoop.main), perform: { dp in
                self.metrics.append(dp)
                if self.metrics.count > 10 {
                    self.metrics.removeFirst()
                }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(networkModel: NetworkAnalyzer(urlsToCheck: ["https://google.com/"]))
    }
}
