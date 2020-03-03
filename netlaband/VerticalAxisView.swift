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
    init(scale: ScaleType, topInset: CGFloat?, bottomInset: CGFloat?) {
        self.topInset = topInset ?? 25.0
        self.bottomInset = bottomInset ?? 25.0
        self.scale = scale
        leftOffset = 30
        tickLength = 5
    }

    func tickList(geometry: GeometryProxy) -> [Tick] {
        var result = [Tick]()
        // protect against Preview sending in stupid values
        // of geometry that can't be made into a reasonable range
        // otherwise the next line will crash preview...
        if geometry.size.width < topInset + bottomInset {
            return result
        }
        let geometryRange = 0.0 ... CGFloat(geometry.size.height - topInset - bottomInset)
        for tick in scale.ticks(10, range: geometryRange) {
            result.append(Tick(value: tick.0, location: tick.1 + topInset))
        }
        return result
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
                        path.move(to: CGPoint(x: self.leftOffset, y: tick.location))
                        path.addLine(to: CGPoint(x: self.leftOffset + self.tickLength, y: tick.location))
                    }
                }.stroke()
                ForEach(self.tickList(geometry: geometry)) { tickStruct in
                    Text(tickStruct.stringValue).position(x: 15, y: tickStruct.location)
                }
            }
        }
    }
}

struct VerticalAxisView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalAxisView(scale: LinearScale(domain: 0 ... 1.0, isClamped: false),
                         topInset: nil,
                         bottomInset: nil)
            .frame(width: 100, height: 400, alignment: .center)
    }
}
