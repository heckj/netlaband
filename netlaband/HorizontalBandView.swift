//
//  HorizontalAxisBandView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/4/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct HorizontalBandView<ScaleType: Scale>: View {
    var scale: ScaleType

    init(scale: ScaleType) {
        self.scale = scale
    }

    func tickList(geometry: GeometryProxy) -> [ScaleType.TickType] {
        // protect against Preview sending in stupid values
        // of geometry that can't be made into a reasonable range
        // otherwise the next line will crash preview...
        let geometryRange = 0.0 ... CGFloat(geometry.size.width)
        return scale.ticks(count: 10, range: geometryRange)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // boxes in the view
                Rectangle().fill(Color.white)
                Rectangle().stroke()
                Path { path in
                    // draw each tick in the line
                    for tick in self.tickList(geometry: geometry) {
                        path.move(to: CGPoint(x: tick.rangeLocation, y: 0))
                        path.addLine(to: CGPoint(x: tick.rangeLocation, y: geometry.size.height))
                    }
                }.stroke(lineWidth: 0.5)
            }
//            ForEach(self.tickList(geometry: geometry)) { tickStruct in
//                Text(tickStruct.stringValue).position(x: tickStruct.rangeLocation, y: geometry.size.height / 2)
//            }
        }
    }
}

#if DEBUG
    struct HorizontalBandView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                HorizontalBandView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                    .frame(width: 400, height: 50, alignment: .center)
                    .padding()

                HorizontalBandView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
                    .frame(width: 400, height: 50, alignment: .center)
                    .padding()

                HorizontalBandView(scale: LogScale(domain: 0.1 ... 100.0, isClamped: false))
                    .frame(width: 400, height: 50, alignment: .center)
                    .padding()
            }
        }
    }
#endif
