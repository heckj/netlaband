//
//  HorizontalTickDisplayView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/8/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct HorizontalTickDisplayView<ScaleType: Scale>: View {
    let scale: ScaleType
    let numTicks = 10
    let numberFormatter = NumberFormatter()

    init(scale: ScaleType) {
        self.scale = scale
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 1
    }

    func tickList(geometry: GeometryProxy) -> [ScaleType.TickType] {
        // protect against Preview sending in stupid values
        // of geometry that can't be made into a reasonable range
        // otherwise the next line will crash preview...
        let geometryRange = 0.0 ... CGFloat(geometry.size.width)
        return scale.ticks(count: numTicks, range: geometryRange)
    }

    func tickLabel(_ tick: ScaleType.TickType) -> String {
        // let foo = String(format: "%.1f", tick.value)
        // this runs into all sorts of freakish issues converting
        // the inferred type into CVarArg for the
        // implied NumberFormatter under the covers

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 1

        // to avoid this force-cast nonsense, which is otherwise
        // required for the compilation, we might want to
        // twiddle Tick (the protocol) to explictly return
        // an NSNumber
        let formattedString = numberFormatter.string(from: tick.value as! NSNumber) ?? "erp"

        return formattedString
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(self.tickList(geometry: geometry)) { tick in
                    Text(self.tickLabel(tick))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primary)
                        .position(x: tick.rangeLocation, y: 0)
                }
            }
        }
    }
}

#if DEBUG
    struct HorizontalTickDisplayView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                // axis view w/ linear scale - simple/short
                VStack {
                    HorizontalAxisView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                    HorizontalTickDisplayView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()

                // band view w/ linear scale - simple/short
                VStack {
                    HorizontalBandView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                    HorizontalTickDisplayView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()

                // axis view w/ log scale variant - simple/short
                VStack {
                    HorizontalAxisView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
                    HorizontalTickDisplayView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()

                // band view w/ log scale variant - simple/short
                VStack {
                    HorizontalBandView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
                    HorizontalTickDisplayView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
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
                    HorizontalTickDisplayView(scale: LogScale(domain: 0.1 ... 100.0, isClamped: false))
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()
            }
        }
    }
#endif
