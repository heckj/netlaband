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

    @State private var blur: CGFloat = 1.0
    @State private var stroke: CGFloat = 1.0
    @State private var opacity: CGFloat = 1.0

    func scalePosition(myScale: ScaleType, size: CGSize, point: NetworkAnalysisDataPoint) -> CGPoint {
        let xPos = myScale.scale(CGFloat(point.latency),
                                 range: 0 ... size.width)
        // ternary structure: question ? answerYes : answerNo
        let limitedX = xPos.isNaN ? CGFloat(0) : xPos
        let pointval = CGPoint(x: limitedX, y: size.height / 2)
        // print("returning: ", pointval)
        return pointval
    }

    func sizeFromBandwidth(_ point: NetworkAnalysisDataPoint, size: CGSize) -> CGFloat {
        if point.bandwidth < 1 {
            return CGFloat(10)
        }
        let minRange = max(min(size.height * 0.8, size.width), 10)
        let internalScale = LogScale(domain: 1 ... 10000.0, isClamped: false)
        let scaledSize = internalScale.scale(CGFloat(point.bandwidth), range: 10 ... minRange)
        // print("returning: ", scaledSize)
        return scaledSize
    }

    var body: some View {
        VStack {
            VizControlsView(min: 0.5, max: 20.0, strokeValue: $stroke, blurVal: $blur, opacityVal: $opacity)
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
                            .stroke(Color.blue, lineWidth: self.stroke)
                            .blur(radius: CGFloat(self.blur))
                            .frame(width: self.sizeFromBandwidth(point, size: geometry.size), height: self.sizeFromBandwidth(point, size: geometry.size), alignment: .center)
                            .position(self.scalePosition(myScale: self.scale, size: geometry.size, point: point))
                            .opacity(Double(self.opacity))
                    }
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
