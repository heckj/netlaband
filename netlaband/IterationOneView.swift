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
    @ObservedObject var networkModel: NetworkAnalyzer
    @State private var metrics = CircularBuffer<NetworkAnalysisDataPoint>(initialCapacity: 10)

    var body: some View {
        VStack {
            HStack {
                Text("\(metrics.count) datapoints")
            }
            DataPointCollectionView(points: self.metrics, scale: LogScale(domain: 1 ... 10000.0, isClamped: false))

            List(self.metrics) { dp in
                DataPointTextView(dp: dp)
            }
        }.onReceive(networkModel.metricPublisher.receive(on: RunLoop.main), perform: { dp in
            self.metrics.append(dp)
            if self.metrics.count > 10 {
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
