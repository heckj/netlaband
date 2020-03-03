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
    init(scale: ScaleType, leftInset: CGFloat?, rightInset: CGFloat?) {
        self.leftInset = leftInset ?? 5.0
        self.rightInset = rightInset ?? 5.0
        self.scale = scale
    }

    func tickList(geometry: GeometryProxy) -> [Tick] {
        var result = [Tick]()
        // protect against Preview sending in stupid values
        // of geometry that can't be made into a reasonable range
        // otherwise the next line will crash preview...
        if geometry.size.width < leftInset + rightInset {
            return result
        }
        let geometryRange = 0.0 ... CGFloat(geometry.size.width - leftInset - rightInset)
        for tick in scale.ticks(10, range: geometryRange) {
            result.append(Tick(value: tick.0, location: tick.1 + leftInset))
        }
        return result
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
                        path.move(to: CGPoint(x: tick.location, y: 3))
                        path.addLine(to: CGPoint(x: tick.location, y: 8))
                    }
                }.stroke()
            }
            ForEach(self.tickList(geometry: geometry)) { tickStruct in
                Text(tickStruct.stringValue).position(x: tickStruct.location, y: CGFloat(15.0))
            }
        }
    }
}

struct HorizontalAxisView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalAxisView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false),
                           leftInset: 25.0,
                           rightInset: 25.0)
            .frame(width: 400, height: 100, alignment: .center)
    }
}
