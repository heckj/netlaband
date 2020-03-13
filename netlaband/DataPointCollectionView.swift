//
//  DataPointCollectionView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct DataPointCollectionView<CollectionType: RandomAccessCollection, ScaleType: Scale>: View
    where CollectionType.Element == NetworkAnalysisDataPoint,
    ScaleType.InputType == CGFloat,
    ScaleType.TickType.InputType == CGFloat {
    let points: CollectionType
    var scale: ScaleType

    func scalePosition(myScale: ScaleType, size: CGSize, point: NetworkAnalysisDataPoint) -> CGPoint {
        let xPos = myScale.scale(CGFloat(point.latency),
                                 range: 0 ... size.width)
        // ternary structure: question ? answerYes : answerNo
        let limitedX = xPos.isNaN ? CGFloat(0) : xPos

        // y-position in the middle of the view - no vertical scaling
        let limitedY = size.height / 2

        let pointval = CGPoint(x: limitedX, y: limitedY)
        print("scalePosition returning: ", pointval)
        return pointval
    }

    func sizeFromBandwidth(_ point: NetworkAnalysisDataPoint, size: CGSize) -> CGFloat {
        if point.bandwidth < 1 {
            return CGFloat(10)
        }
        let minDiameterToScale = 10
        let maxDiameterToScale = max(min(size.height * 0.8, size.width), CGFloat(minDiameterToScale))

        let internalScale = LogScale(domain: 1 ... 10000.0, isClamped: false)
        let scaledSize = internalScale.scale(CGFloat(point.bandwidth), range: 10 ... maxDiameterToScale)
        print("sizeFromBandwidth returning: ", scaledSize)
        return scaledSize
    }

    var body: some View {
        VStack {
            ZStack {
                // when using a ZStack, the stuff listed at the
                // top of the construction pattern is on the "bottom"
                // of the stack - that is, you can think of it as
                // building "upward" to displaying the view.

                // this presents the logrithmic background to the view
                HorizontalBandView(scale: scale)

                // and this wraps the data presentation over that background
                GeometryReader { geometry in
                    // geometry here provides us access to know the size of the
                    // object we've been placed within...
                    // geometry.size (CGSize)
                    // geometry.frame (CGRect)
                    ForEach(self.points) { point in

                        CircleDataPoint(size: self.sizeFromBandwidth(point,
                                                                     size: geometry.size),
                                        position: self.scalePosition(myScale: self.scale,
                                                                     size: geometry.size,
                                                                     point: point))
                    }
                } // GeometryReader
            } // ZStack
            // TODO(heckj): need to update the HorizontalTickDisplayView
            // (or the underlying code that it uses) so that values entered
            // OUTSIDE the domain the scale provided don't cause utter havoc
            // on the resulting view (crashes with an issue drawing origin)
            HorizontalTickDisplayView(scale: scale,
                                      values: [1.0, 10.0, 100.0, 1000.0, 10000.0])
        } // VStack
    }
}

#if DEBUG
    private func dataPoints() -> CircularBuffer<NetworkAnalysisDataPoint> {
        var pointCollection = CircularBuffer<NetworkAnalysisDataPoint>(initialCapacity: 10)
        pointCollection.append(NetworkAnalysisDataPoint(
            url: "https://www.google.com/",
            latency: 55.4, // in ms
            bandwidth: 2437.1, // in Kbytes per second
            timeoffset: 0 // seconds ago
        ))
        pointCollection.append(NetworkAnalysisDataPoint(
            url: "https://www.google.com/",
            latency: 128.9, // in ms
            bandwidth: 2437.15, // in Kbytes per second
            timeoffset: 10 // seconds ago
        ))
        pointCollection.append(NetworkAnalysisDataPoint(
            url: "https://www.google.com/",
            latency: 33.42, // in ms
            bandwidth: 3413.4, // in Kbytes per second
            timeoffset: 20 // seconds ago
        ))
        pointCollection.append(NetworkAnalysisDataPoint(
            url: "https://www.google.com/",
            latency: 932.3, // in ms
            bandwidth: 700.63, // in Kbytes per second
            timeoffset: 30 // seconds ago
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
