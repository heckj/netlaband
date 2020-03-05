//
//  DataPointCollectionView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct DataPointCollectionView<CollectionType: RandomAccessCollection, ScaleType: Scale>: View where CollectionType.Element == NetworkAnalysisDataPoint, ScaleType.InputType == CGFloat {
    let points: CollectionType
    var scale: ScaleType

    func scalePosition(myScale: ScaleType, size: CGSize, point: NetworkAnalysisDataPoint) -> CGPoint {
        let xPos = myScale.scale(CGFloat(point.latency),
                                 range: 0 ... size.width)
        let yPos = size.height / 2
        return CGPoint(x: xPos, y: yPos)
    }

    func sizeFromBandwidth(_ point: NetworkAnalysisDataPoint, size: CGSize) -> CGFloat {
        let minRange = min(size.height, size.width)
        let internalScale = LogScale(domain: 1 ... 10000.0, isClamped: false)
        let scaledSize = internalScale.scale(CGFloat(point.bandwidth), range: 10 ... minRange)
        return scaledSize
    }

    var body: some View {
        ZStack {
            // when using a ZStack, the stuff listed at the
            // top of the construction pattern is on the "bottom"
            // of the stack - that is, you can think of it as
            // building "upward" to displaying the view.

            HorizontalBandView(scale: scale)

            GeometryReader { geometry in
                // geometry here provides us access to know the size of the
                // object we've been placed within...
                // geometry.size (CGSize)
                // geometry.frame (CGRect)
                ForEach(self.points) { point in
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .blur(radius: CGFloat(3.0))
                        .frame(width: self.sizeFromBandwidth(point, size: geometry.size), height: self.sizeFromBandwidth(point, size: geometry.size), alignment: .center)
                        .position(self.scalePosition(myScale: self.scale, size: geometry.size, point: point))
                }
            }
        }
    }
}

#if DEBUG
    private func dataPoints() -> CircularBuffer<NetworkAnalysisDataPoint> {
        var pointCollection = CircularBuffer<NetworkAnalysisDataPoint>(initialCapacity: 10)

        pointCollection.append(NetworkAnalysisDataPoint(
            url: "https://www.google.com/",
            latency: 55.4, // in ms
            bandwidth: 2437.1 // in Kbytes per second
        ))
        pointCollection.append(NetworkAnalysisDataPoint(
            url: "https://www.google.com/",
            latency: 128.9, // in ms
            bandwidth: 2437.15 // in Kbytes per second
        ))
        pointCollection.append(NetworkAnalysisDataPoint(
            url: "https://www.google.com/",
            latency: 33.42, // in ms
            bandwidth: 3413.4 // in Kbytes per second
        ))
        pointCollection.append(NetworkAnalysisDataPoint(
            url: "https://www.google.com/",
            latency: 932.3, // in ms
            bandwidth: 700.63 // in Kbytes per second
        ))

        return pointCollection
    }

    struct DataPointCollectionView_Previews: PreviewProvider {
        static var previews: some View {
            DataPointCollectionView(points: dataPoints(),
                                    scale: LogScale(domain: 1 ... 10000.0, isClamped: false))
                .frame(width: 400, height: 100, alignment: .center)
                .padding()
        }
    }
#endif
