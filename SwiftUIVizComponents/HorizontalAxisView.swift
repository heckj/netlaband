//
//  HorizontalAxisView.swift
//  netlaband
//
//  Created by Joseph Heck on 2/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

public struct HorizontalAxisView<ScaleType: Scale>: View {
    let scale: ScaleType
    let inset: CGFloat = 3.0
    let tickLength: CGFloat = 5.0
    var numTicks = 10

    init(scale: ScaleType) {
        self.scale = scale
    }

    func tickList(geometry: GeometryProxy) -> [ScaleType.TickType] {
        let geometryRange = 0.0 ... CGFloat(geometry.size.width)
        return scale.ticks(count: numTicks, range: geometryRange)
    }

    public var body: some View {
        GeometryReader { geometry in
            Path { path in
                // draw base axis line
                path.move(to: CGPoint(x: 0, y: self.inset))
                path.addLine(to: CGPoint(x: geometry.size.width, y: self.inset))

                // draw each tick in the line
                for tick in self.tickList(geometry: geometry) {
                    path.move(to: CGPoint(x: tick.rangeLocation, y: self.inset))
                    path.addLine(to: CGPoint(x: tick.rangeLocation, y: self.inset + self.tickLength))
                }
            }.stroke(Color.primary)
        }.fixedSize(horizontal: false, vertical: true)
        // view is a fixed size vertically because I'm not sure
        // of how to say "has to be a minimum of
        // self.inset + self.tickLength, but otherwise you can
        // have more space around this if needed.
    }
}

struct HorizontalAxisView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HorizontalAxisView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                .frame(width: 400, height: 10, alignment: .center)
                .padding()

            HorizontalAxisView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
                .frame(width: 400, height: 10, alignment: .center)
                .padding()
        }
    }
}
