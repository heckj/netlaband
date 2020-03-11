//
//  VerticalAxisView.swift
//  netlaband
//
//  Created by Joseph Heck on 2/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct VerticalAxisView<ScaleType: Scale>: View {
    let scale: ScaleType
    let inset: CGFloat = 3.0
    let tickLength: CGFloat = 5.0
    let numTicks = 10

    init(scale: ScaleType) {
        self.scale = scale
    }

    func tickList(geometry: GeometryProxy) -> [ScaleType.TickType] {
        let geometryRange = 0.0 ... CGFloat(geometry.size.height)
        return scale.ticks(count: numTicks, range: geometryRange)
    }

    var body: some View {
        GeometryReader { geometry in
            Path { path in

                path.move(to: CGPoint(x: self.inset + self.tickLength, y: 0))
                path.addLine(to: CGPoint(x: self.inset + self.tickLength, y: geometry.size.height))

                for tick in self.tickList(geometry: geometry) {
                    path.move(to: CGPoint(x: self.inset, y: tick.rangeLocation))
                    path.addLine(to: CGPoint(x: self.inset + self.tickLength, y: tick.rangeLocation))
                }
            }.stroke()
        }.fixedSize(horizontal: true, vertical: false)
        // view is a fixed size horizontally because I'm not sure
        // of how to say "has to be a minimum of
        // self.inset + self.tickLength, but otherwise you can
        // have more space around this if needed.
    }
}

struct VerticalAxisView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerticalAxisView(scale: LinearScale(domain: 0 ... 1.0, isClamped: false))
                .frame(width: 50, height: 400, alignment: .center)
                .padding()

            VerticalAxisView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
                .frame(width: 50, height: 400, alignment: .center)
                .padding()
        }
    }
}
