//
//  HorizontalTickDisplayView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/8/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

// OPENQUESTION(heckj): should this be moved into SwiftViz
// and matched up with Ticks there?
//
// it's generally created with the benefit of a formatter,
// the type that we use being dependent on the type that's
// used for the domain of the Scale. Right now we keep the
// formatter bits away from the underlying SwiftViz library
// and entirely at the display logic layer... so perhaps
// it makes sense to stay here.
struct TickLabel: Identifiable {
    let id: UUID
    let rangeLocation: CGFloat
    let value: String

    init(id: UUID, rangeLocation: CGFloat, value: String) {
        self.id = id
        self.rangeLocation = rangeLocation
        self.value = value
    }

    // convenience initializer
    init(rangeLocation: CGFloat, value: String) {
        id = UUID()
        self.rangeLocation = rangeLocation
        self.value = value
    }
}

struct HorizontalTickDisplayView<ScaleType: Scale>: View where ScaleType.InputType == ScaleType.TickType.InputType {
    let scale: ScaleType
    let numTicks = 10
    let formatter: Formatter
    let tickValues: [ScaleType.InputType]

    init(scale: ScaleType,
         values: [ScaleType.InputType] = [],
         formatter: Formatter = NumberFormatter()) {
        self.scale = scale
        self.formatter = formatter
        tickValues = values
    }

    func tickLabel(_ tick: ScaleType.TickType) -> TickLabel {
        // to avoid this force-cast nonsense, which is otherwise
        // required for the compilation, we might want to
        // twiddle Tick (the protocol) to explictly return
        // an NSNumber
        let formattedString = formatter.string(for: tick.value as! NSNumber) ?? "erp"

        return TickLabel(id: tick.id, rangeLocation: tick.rangeLocation, value: formattedString)
    }

    func makeTickLabels(ticks: [ScaleType.InputType], range: ClosedRange<CGFloat>) -> [TickLabel] {
        scale.ticks(ticks, range: range).map { tick in
            tickLabel(tick)
        }
    }

    func tickList(geometry: GeometryProxy) -> [TickLabel] {
        let geometryRange = 0.0 ... CGFloat(geometry.size.width)

        if tickValues.isEmpty {
            let listOfTicks = scale.ticks(count: numTicks, range: geometryRange)
            let listOfTickLabels = listOfTicks.map { tick in
                tickLabel(tick)
            }
            return listOfTickLabels
        } else {
            return makeTickLabels(ticks: tickValues, range: geometryRange)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(self.tickList(geometry: geometry)) { tick in
                    Text(tick.value)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primary)
                        .position(x: tick.rangeLocation, y: 0)
                }
            }
        }
    }
}

// extension HorizontalTickDisplayView: ViewModifier
// //where ScaleType.InputType == ScaleType.TickType.InputType
// {
//        func body(content: Content) -> some View {
//            content
//        }
// }

#if DEBUG
    func exampleFormatter() -> Formatter {
        let exampleFormatter = NumberFormatter()
        exampleFormatter.numberStyle = .decimal
        exampleFormatter.minimumFractionDigits = 0
        exampleFormatter.maximumFractionDigits = 2
        return exampleFormatter
    }

    struct HorizontalTickDisplayView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                // axis view w/ linear scale - simple/short
                VStack {
                    HorizontalAxisView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                    HorizontalTickDisplayView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false),
                                              formatter: exampleFormatter())
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()

                // band view w/ linear scale - simple/short
                VStack {
                    HorizontalBandView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                    HorizontalTickDisplayView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false),
                                              formatter: exampleFormatter())
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()

                // axis view w/ log scale variant - simple/short
                VStack {
                    HorizontalAxisView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
                    HorizontalTickDisplayView(scale: LogScale(domain: 1 ... 10.0, isClamped: false),
                                              formatter: exampleFormatter())
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()

                // band view w/ log scale variant - simple/short
                VStack {
                    HorizontalBandView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
                    HorizontalTickDisplayView(scale: LogScale(domain: 1 ... 10.0, isClamped: false),
                                              formatter: exampleFormatter())
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()

                // axis view w/ log scale variant - longer
                //
                // dense logScales look pretty rough here
                // so maybe one thing to do would be to make an
                // indicator on each tick if it's "major" or "minor"
                // which could be used within the band/scale to
                // improve the visualization (bolder/darker line)
                // and also to provide a labeling hint
                // "show or not-show"
                VStack {
                    HorizontalBandView(scale: LogScale(domain: 0.1 ... 100.0, isClamped: false))
                    HorizontalTickDisplayView(scale: LogScale(domain: 0.1 ... 100.0, isClamped: false),
                                              formatter: exampleFormatter())
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()

                // axis view w/ log scale variant - manual ticks
                VStack {
                    HorizontalBandView(scale: LogScale(domain: 0.1 ... 100.0, isClamped: false))
                    HorizontalTickDisplayView(scale: LogScale(domain: 0.1 ... 100.0, isClamped: false),
                                              values: [0.1, 1.0, 10.0, 100.0],
                                              formatter: exampleFormatter())
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()
            }
        }
    }
#endif
