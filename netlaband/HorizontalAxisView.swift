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
    let leftInset: CGFloat
    let rightInset: CGFloat
    var scale: ScaleType
    init(scale: ScaleType, leftInset: CGFloat = 10, rightInset: CGFloat = 10) {
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.scale = scale
    }

    func tickList(geometry: GeometryProxy) -> [ScaleType.TickType] {
        // protect against Preview sending in stupid values
        // of geometry that can't be made into a reasonable range
        // otherwise the next line will crash preview...
        if geometry.size.width < leftInset + rightInset {
            return [ScaleType.TickType]()
        }
        let geometryRange = 0.0 ... CGFloat(geometry.size.width - leftInset - rightInset)
        return scale.ticks(count: 10, range: geometryRange)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    if geometry.size.width < self.leftInset + self.rightInset {
                        // preview can call this with pathological values that may not make sense...
                        // in case the reported width is tiny (less than insets), bail!
                        return
                    }

                    // draw base axis line
                    path.move(to: CGPoint(x: self.leftInset, y: 3))
                    path.addLine(to: CGPoint(x: geometry.size.width - self.rightInset, y: 3))

                    // draw each tick in the line
                    for tick in self.tickList(geometry: geometry) {
                        path.move(to: CGPoint(x: tick.rangeLocation + self.leftInset, y: 3))
                        path.addLine(to: CGPoint(x: tick.rangeLocation + self.leftInset, y: 8))
                    }
                }.stroke()
            }
//            ForEach(self.tickList(geometry: geometry)) { tickStruct in
//                Text(String(format: "%.1f", arguments: [tickStruct.value]))
//                    .position(x: tickStruct.rangeLocation + self.leftInset, y: CGFloat(15.0))
//            }
        }
    }
}

struct HorizontalAxisView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HorizontalAxisView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false),
                               leftInset: 25.0,
                               rightInset: 25.0)
                .frame(width: 400, height: 50, alignment: .center)

            HorizontalAxisView(scale: LogScale(domain: 1 ... 10.0, isClamped: false),
                               leftInset: 25.0,
                               rightInset: 25.0)
                .frame(width: 400, height: 50, alignment: .center)
        }
    }
}
