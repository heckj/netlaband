//
//  DataPointCollectionView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct DataPointCollectionView: View {
    let points: CircularBuffer<NetworkAnalysisDataPoint>

    var body: some View {
        VStack {
            GeometryReader { geometry in
                // geometry here provides us access to know the size of the
                // object we've been placed within...
                // geometry.size (CGSize)
                // geometry.frame (CGRect)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - 5))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height - 5))
                }.stroke(Color.red)
            }

            HorizontalAxisView(scale: SwiftViz.LogScale(domain: 1 ... 10.0, isClamped: false))
        }
    }
}

#if DEBUG
    var pointCollection = CircularBuffer<NetworkAnalysisDataPoint>(initialCapacity: 10)
//    .append(NetworkAnalysisDataPoint(
//        url: "https://www.google.com/",
//        latency: 43.46799850463867, // in ms
//        bandwidth: 2437.155212838014 // in Kbytes per second
//    ))

    struct DataPointCollectionView_Previews: PreviewProvider {
        static var previews: some View {
            DataPointCollectionView(points: pointCollection)
                .frame(width: 400, height: 100, alignment: .center)
        }
    }
#endif
