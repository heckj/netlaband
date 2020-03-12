//
//  VerticalTickDisplayView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/11/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct VerticalTickDisplayView<ScaleType: Scale>: View where ScaleType.InputType == ScaleType.TickType.InputType {
    let scale: ScaleType
    let numTicks = 10
    let formatter: Formatter
    let tickValues: [ScaleType.InputType]

    init(scale: ScaleType,
         values: [ScaleType.InputType] = [],
         formatter: Formatter = TickLabel.makeDefaultFormatter()) {
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
        let geometryRange = 0.0 ... CGFloat(geometry.size.height)

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
            ZStack(alignment: .trailing) {
                ForEach(self.tickList(geometry: geometry)) { tick in
                    Text(tick.value)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .alignmentGuide(HorizontalAlignment.trailing, computeValue: { dimensions in
                            dimensions[HorizontalAlignment.trailing]
                        })
                        .foregroundColor(Color.primary)
                        .position(x: geometry.size.width / 2,
                                  y: tick.rangeLocation)
                        .offset(x: 8, y: 0)
                    // ^^ 8 is a magic number offset for bringing
                    // the text closer to the axis that visually
                    // makes sense. I'm not entirely sure how I'd
                    // calculate it.
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .frame(alignment: .trailing)
        }
    }
}

#if DEBUG
    struct VerticalTickDisplayView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                // axis view w/ linear scale - simple/short
                HStack {
                    VerticalTickDisplayView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                    VerticalAxisView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                }
                .frame(width: 60, height: 200, alignment: .center)
                .padding()

                // axis view w/ log scale variant - manual ticks
                HStack {
                    VerticalTickDisplayView(scale: LogScale(domain: 0.1 ... 100.0, isClamped: false),
                                            values: [0.1, 1.0, 10.0, 100.0])
                    VerticalAxisView(scale: LogScale(domain: 0.1 ... 100.0, isClamped: false))
                }
                .frame(width: 60, height: 200, alignment: .center)
                .padding()
            }
        }
    }
#endif
