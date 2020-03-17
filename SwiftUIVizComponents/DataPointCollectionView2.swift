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
    var scale: ScaleType // horizontal scale

//    @State private var blur: CGFloat = 2.0
    @State private var stroke: CGFloat = 2.0
//    @State private var opacity: CGFloat = 0.8
    @State private var timeDuration: CGFloat = 20.0

    func scalePosition(myScale: ScaleType, size: CGSize, point: NetworkAnalysisDataPoint) -> CGPoint {
        let xPos = myScale.scale(CGFloat(point.latency),
                                 range: 0 ... size.width)
        // ternary structure: question ? answerYes : answerNo
        let limitedX = xPos.isNaN ? CGFloat(0) : xPos

        // incoming size.height is the max range for applying
        // the time scale/age for the data points. Domain is
        // the expected input values (0 to ?? seconds old)
        let verticalScale = LinearScale(domain: 0 ... timeDuration)

        // age of point
        let age = point.timestamp.timeIntervalSinceNow * -1.0
        // print("Age: ", age)

        // y-position scaled by age of the datapoint
        let scaledY = verticalScale.scale(CGFloat(age), range: 0 ... size.height)

        let pointval = CGPoint(x: limitedX, y: scaledY)
        // print("returning: ", pointval)
        return pointval
    }

    func opacityFromAge(point: NetworkAnalysisDataPoint) -> Double {
        let verticalScale = LinearScale(domain: 0 ... timeDuration)
        // age of point
        let age = point.timestamp.timeIntervalSinceNow * -1.0
        let scaledOpacity = verticalScale.scale(CGFloat(age), range: 0 ... 1.0)
        print("scaled opacity = ", scaledOpacity)
        if scaledOpacity.isNaN {
            return 1.0
        }
        return Double(1 - scaledOpacity)
    }

    func discreteSizeFromBandwidth(_ point: NetworkAnalysisDataPoint, size _: CGSize) -> CGFloat {
        // 3 sizes:
        //  - sm (<100)
        //  - med (>100)
        //  - large (>1k)
        // if the bandwidth < 1, min size
        if point.bandwidth > 1000 {
            return CGFloat(20)
        }
        if point.bandwidth > 100, point.bandwidth < 1000 {
            return CGFloat(15)
        }
        // if point.bandwidth < 100
        return CGFloat(10)
    }

    var body: some View {
        VStack {
//             VizControlsView(min: 0.5, max: 20.0, strokeValue: $stroke, blurVal: $blur, opacityVal: $opacity, timeDurationVal: $timeDuration)
            HStack { // top row of "grid"
                // vertical axis tick labels
//                VerticalTickDisplayView(scale: LinearScale(domain: 0 ... timeDuration, isClamped: false),
//                                        labeledValues: [
//                                            (CGFloat(20), "20"),
//                                            (CGFloat(40), "40"),
//                                        ])
//                ZStack { // vertical axis
//                    VerticalAxisView(scale: LinearScale(domain: 0 ... timeDuration, isClamped: false))
//                }
                VStack { // data view
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
//                                    .blur(radius: CGFloat(self.blur))
                                    .frame(width: self.discreteSizeFromBandwidth(point, size: geometry.size), height: self.discreteSizeFromBandwidth(point, size: geometry.size), alignment: .center)
                                    .position(self.scalePosition(myScale: self.scale, size: geometry.size, point: point))
                                    .opacity(self.opacityFromAge(point: point))
                            }
                        } // GeometryReader
                    } // ZStack
                } // VStack - data view
            } // HStack - top row of "grid"
            HStack { // bottom sequence of grid - next "row"
//                ZStack { Spacer() } // to match tick display
//                ZStack { Spacer() } // to match axis
                // then hopefullt this tick display will match the 3rd cell - data view
                HorizontalTickDisplayView(scale: scale,
                                          labeledValues: [
                                              (CGFloat(1.0), "1 ms"),
                                              (CGFloat(10), "10 ms"),
                                              (CGFloat(100), "100 ms"),
                                              (CGFloat(1000), "1 s"),
                                              (CGFloat(10000), "10 s"),
                                          ])
            } // bottom sequence of grid - next "row"
        }
    } // VStack
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
        pointCollection.append(NetworkAnalysisDataPoint(
            url: "https://www.google.com/",
            latency: 213, // in ms
            bandwidth: 99.63, // in Kbytes per second
            timeoffset: 40 // seconds ago
        ))

        return pointCollection
    }

    struct DataPointCollectionView2_Previews: PreviewProvider {
        static var previews: some View {
            DataPointCollectionView2(points: dataPoints(),
                                     scale: LogScale(domain: 1 ... 10000.0, isClamped: false))
                .frame(width: 250, height: 400, alignment: .center)
                .padding()
        }
    }
#endif
