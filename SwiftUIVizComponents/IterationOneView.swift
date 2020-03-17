//
//  IterationOneView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct IterationOneView: View {
    let capacity = 10
    @ObservedObject var networkModel: NetworkAnalyzer
    @State private var metrics = CircularBuffer<NetworkAnalysisDataPoint>(initialCapacity: 10)

    var body: some View {
        VStack {
            HStack {
                Text("\(metrics.count) datapoints")
            }
            DataPointCollectionView(points: self.metrics, scale: LogScale(domain: 1 ... 10000.0, isClamped: false))
                .padding()

            List(self.metrics) { dp in
                DataPointTextView(dp: dp)
            }
        }.onReceive(networkModel.metricPublisher.receive(on: RunLoop.main), perform: { dp in
            self.metrics.append(dp)
            if self.metrics.count > self.capacity {
                self.metrics.removeFirst()
            }
        })
    }
}

struct IterationOneView_Previews: PreviewProvider {
    static var previews: some View {
        IterationOneView(networkModel: NetworkAnalyzer(urlsToCheck: ["https://google.com/"]))
    }
}
