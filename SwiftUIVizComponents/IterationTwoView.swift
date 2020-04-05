//
//  IterationTwoView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct IterationTwoView: View {
    let capacity = 50
    @ObservedObject var networkModel: NetworkAnalyzer
    @State private var metrics = CircularBuffer<NetworkAnalysisDataPoint>(initialCapacity: 50)

    var body: some View {
        VStack {
            HStack {
                Text("\(metrics.count) datapoints")
            }
            DataPointCollectionView2(points: self.metrics,
                                     scale: LogScale(domain: 1 ... 10000.0, isClamped: false))
//                .frame(height: 250, alignment: .center)
//                .padding()
        }.onReceive(networkModel.metricPublisher.receive(on: RunLoop.main), perform: { dp in
            self.metrics.append(dp)
            if self.metrics.count > self.capacity {
                self.metrics.removeFirst()
            }
        })
    }
}

struct IterationTwoView_Previews: PreviewProvider {
    static var previews: some View {
        IterationTwoView(networkModel: NetworkAnalyzer(urlsToCheck: ["https://google.com/"]))
    }
}
