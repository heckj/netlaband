//
//  DataPointCollectionView2.swift
//  netlaband
//
//  Created by Joseph Heck on 3/8/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

enum DataPointSize {
    case small
    case medium
    case large

    public static let maxOffset = CGFloat(15 / 2 + 10 / 2)
    public static let minOffset = CGFloat(10 / 2 + 10 / 2)

    var size: CGFloat {
        switch self {
        case .small:
            return CGFloat(10.0)
        case .medium:
            return CGFloat(9.0)
        case .large:
            return CGFloat(8.0)
        }
    }

    var stroke: CGFloat {
        switch self {
        case .small:
            return CGFloat(1.0)
        case .medium:
            return CGFloat(3.0)
        case .large:
            return CGFloat(5.0)
        }
    }
}

struct DataPointCollectionView2<CollectionType: RandomAccessCollection, ScaleType: Scale>: View where CollectionType.Element == NetworkAnalysisDataPoint,
    ScaleType.TickType.InputType == ScaleType.InputType,
    ScaleType.TickType.InputType == CGFloat {
    let points: CollectionType
    var scale: ScaleType // horizontal scale
    let maxDurationNeeded: CGFloat

    func scalePosition(myScale: ScaleType, size: CGSize, point: NetworkAnalysisDataPoint) -> CGPoint {
        let xPos = myScale.scale(CGFloat(point.latency),
                                 range: 0 ... size.width)
        // ternary structure: question ? answerYes : answerNo
        let limitedX = xPos.isNaN ? CGFloat(0) : xPos

        // incoming size.height is the max range for applying
        // the time scale/age for the data points. Domain is
        // the expected input values (0 to ?? seconds old)
        let verticalScale = LinearScale(domain: 0 ... maxDurationNeeded, isClamped: true)

        // age of point
        let age = point.timestamp.timeIntervalSinceNow * -1.0
        // print("Age: ", age)

        var insetRange: ClosedRange<CGFloat>
        if DataPointSize.maxOffset > size.height - DataPointSize.maxOffset {
            insetRange = DataPointSize.maxOffset ... DataPointSize.maxOffset
        } else {
            insetRange = DataPointSize.maxOffset ... size.height - DataPointSize.maxOffset
        }
        // y-position scaled by age of the datapoint
        let scaledY = verticalScale.scale(CGFloat(age), range: insetRange)

        let pointval = CGPoint(x: limitedX, y: scaledY)
        // print("returning: ", pointval)
        return pointval
    }

    func opacityFromAge(point: NetworkAnalysisDataPoint) -> Double {
        let verticalScale = LinearScale(domain: 0 ... maxDurationNeeded)
        // age of point
        let age = point.timestamp.timeIntervalSinceNow * -1.0
        let scaledOpacity = verticalScale.scale(CGFloat(age), range: 0.0 ... 0.8)
        print("scaled opacity = ", scaledOpacity)
        if scaledOpacity.isNaN {
            return 1.0
        }
        return Double(1 - scaledOpacity)
    }

    func sizeFromBandwidth(_ point: NetworkAnalysisDataPoint, size _: CGSize) -> DataPointSize {
        // 3 sizes:
        //  - large (>1k)
        if point.bandwidth > 1000 {
            return .large
        }
        //  - medium (>100)
        if point.bandwidth > 100, point.bandwidth < 1000 {
            return .medium
        }
        // if point.bandwidth < 100 : small
        return .small
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
                                    .stroke(Color.blue, lineWidth: self.sizeFromBandwidth(point, size: geometry.size).stroke)
                                    .frame(width: self.sizeFromBandwidth(point, size: geometry.size).size, height: self.sizeFromBandwidth(point, size: geometry.size).size, alignment: .center)
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
            }.frame(minHeight: 10, idealHeight: 20, maxHeight: 20, alignment: .center) // bottom sequence of grid - next "row"
        }
    } // VStack
}

#if DEBUG
    private func dataPoints() -> CircularBuffer<NetworkAnalysisDataPoint> {
        var pointCollection = CircularBuffer<NetworkAnalysisDataPoint>(initialCapacity: 10)
        pointCollection.append(NetworkAnalysisDataPoint(
            url: "https://www.google.com/",
            latency: 55.4, // in ms
            bandwidth: 37.1, // in Kbytes per second
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
                                     scale: LogScale(domain: 1 ... 10000.0, isClamped: true), maxDurationNeeded: 40.0)
                .frame(width: 250, height: 400, alignment: .center)
                .padding()
        }
    }
#endif
