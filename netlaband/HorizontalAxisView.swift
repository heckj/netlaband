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

    public var body: some View {
        GeometryReader { geometry in
            Path { path in
                // preview can call this with pathological values that may not make sense...
                if geometry.size.width < self.leftInset + self.rightInset {
                    // in case the reported width is tiny (less than insets), bail!
                    return
                }
                let geometryRange = 0.0 ... Double(geometry.size.width - self.leftInset - self.rightInset)
                let width = geometry.size.width
                path.move(to: CGPoint(x: self.leftInset, y: 3))
                path.addLine(to: CGPoint(x: width - self.rightInset, y: 3))

                let ticks = self.scale.ticks(nil, range: geometryRange)

                for tick in ticks {
                    path.move(to: CGPoint(x: self.leftInset + CGFloat(tick), y: 3))
                    path.addLine(to: CGPoint(x: self.leftInset + CGFloat(tick), y: 8))
                }

                // then label the ticks by using scale.invert(//) with the values provided
            }.stroke()
        }
    }
}

struct HorizontalAxisView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalAxisView(scale: LinearScale(domain: 0 ... 1.0, isClamped: false),
                           leftInset: 5.0,
                           rightInset: 5.0)
    }
}
