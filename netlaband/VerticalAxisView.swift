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
    let topInset: CGFloat
    let bottomInset: CGFloat
    let leftOffset: CGFloat
    let tickLength: CGFloat

    var scale: ScaleType
    init(scale: ScaleType, topInset: CGFloat = 25, bottomInset: CGFloat = 25) {
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.scale = scale
        leftOffset = 30
        tickLength = 5
    }

    func tickList(geometry: GeometryProxy) -> [ScaleType.TickType] {
        // protect against Preview sending in stupid values
        // of geometry that can't be made into a reasonable range
        // otherwise the next line will crash preview...
        if geometry.size.width < topInset + bottomInset {
            return [ScaleType.TickType]()
        }
        let geometryRange = 0.0 ... CGFloat(geometry.size.height - topInset - bottomInset)
        return scale.ticks(count: 10, range: geometryRange)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    // guard against too small:
                    if geometry.size.height < self.topInset + self.bottomInset {
                        return
                    }

                    path.move(to: CGPoint(x: self.leftOffset + self.tickLength, y: self.topInset))
                    path.addLine(to: CGPoint(x: self.leftOffset + self.tickLength, y: geometry.size.height - self.bottomInset))

                    for tick in self.tickList(geometry: geometry) {
                        path.move(to: CGPoint(x: self.leftOffset, y: tick.rangeLocation + self.topInset))
                        path.addLine(to: CGPoint(x: self.leftOffset + self.tickLength, y: tick.rangeLocation + self.topInset))
                    }
                }.stroke()
//                ForEach(self.tickList(geometry: geometry)) { tickStruct in
//                    Text(tickStruct.stringValue).position(x: 15, y: tickStruct.rangeLocation + self.topInset)
//                }
            }
        }
    }
}

struct VerticalAxisView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerticalAxisView(scale: LinearScale(domain: 0 ... 1.0, isClamped: false))
                .frame(width: 100, height: 400, alignment: .center)

            VerticalAxisView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
                .frame(width: 100, height: 400, alignment: .center)
        }
    }
}
