//
//  DataPointCollectionView2.swift
//  netlaband
//
//  Created by Joseph Heck on 3/8/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct DataPointCollectionView2<CollectionType: RandomAccessCollection, ScaleType: Scale>: View where CollectionType.Element == NetworkAnalysisDataPoint,
    ScaleType.TickType.InputType == ScaleType.InputType,
    ScaleType.TickType.InputType == CGFloat {
    let points: CollectionType
    var scale: ScaleType

    @State private var blur: CGFloat = 2.0
    @State private var stroke: CGFloat = 2.0
    @State private var opacity: CGFloat = 0.8
    @State private var timeDuration: CGFloat = 50.0

    func scalePosition(myScale: ScaleType, size: CGSize, point: NetworkAnalysisDataPoint) -> CGPoint {
        let xPos = myScale.scale(CGFloat(point.latency),
                                 range: 0 ... size.width)
        // ternary structure: question ? answerYes : answerNo
        let limitedX = xPos.isNaN ? CGFloat(0) : xPos

        // y-position in the middle of the view - no vertical scaling
        // let limitedY = size.height / 2

        let minDiameterToScale = 10
        let maxDiameterToScaleSize = max(min(size.height * 0.4, size.width), CGFloat(minDiameterToScale))

        // age of point
        let age = point.timestamp.timeIntervalSinceNow * -1.0
        print("Age: ", age)

        var constrainedRange: ClosedRange<CGFloat>
        if size.height - maxDiameterToScaleSize < 0 {
            constrainedRange = 0 ... 0
        } else {
            constrainedRange = 0 ... size.height - maxDiameterToScaleSize
        }

        // y-position scaled by age of the datapoint
        let anotherY = LinearScale(domain: 0 ... timeDuration, isClamped: false).scale(CGFloat(age), range: constrainedRange)

        let pointval = CGPoint(x: limitedX, y: anotherY + maxDiameterToScaleSize / 2.0)
        print("returning: ", pointval)
        return pointval
    }

    func sizeFromBandwidth(_ point: NetworkAnalysisDataPoint, size: CGSize) -> CGFloat {
        if point.bandwidth < 1 {
            return CGFloat(10)
        }
        let minDiameterToScale = 10
        let maxDiameterToScale = max(min(size.height * 0.4, size.width), CGFloat(minDiameterToScale))

        let internalScale = LogScale(domain: 1 ... 10000.0, isClamped: false)
        let scaledSize = internalScale.scale(CGFloat(point.bandwidth), range: 10 ... maxDiameterToScale)

        return scaledSize
    }

    var body: some View {
        VStack {
            // VizControlsView(min: 0.5, max: 20.0, strokeValue: $stroke, blurVal: $blur, opacityVal: $opacity, timeDurationVal: $timeDuration)
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
                        Circle()
                            .stroke(Color.blue, lineWidth: self.stroke)
                            .blur(radius: CGFloat(self.blur))
                            .frame(width: self.sizeFromBandwidth(point, size: geometry.size), height: self.sizeFromBandwidth(point, size: geometry.size), alignment: .center)
                            .position(self.scalePosition(myScale: self.scale, size: geometry.size, point: point))
                            .opacity(Double(self.opacity))
                    }
                } // GeometryReader
            } // ZStack
            HorizontalTickDisplayView(scale: scale,
                                      labeledValues: [
                                          (CGFloat(1.0), "1 ms"),
                                          (CGFloat(10), "10 ms"),
                                          (CGFloat(100), "100 ms"),
                                          (CGFloat(1000), "1 s"),
                                          (CGFloat(10000), "10 s"),
                                      ])
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

    struct DataPointCollectionView2_Previews: PreviewProvider {
        static var previews: some View {
            DataPointCollectionView2(points: dataPoints(),
                                     scale: LogScale(domain: 1 ... 10000.0, isClamped: false))
                .frame(width: 400, height: 100, alignment: .center)
                .padding()
        }
    }
#endif
