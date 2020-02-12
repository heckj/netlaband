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
    var scale: ScaleType
    init(scale: ScaleType, topInset: CGFloat?, bottomInset: CGFloat?) {
        self.topInset = topInset ?? 5.0
        self.bottomInset = bottomInset ?? 5.0
        self.scale = scale
    }

    var body: some View {
        GeometryReader { geometry in
            Path { path in

                // guard against too small:
                if geometry.size.height < self.topInset + self.bottomInset {
                    return
                }
                let geometryRange = 0.0 ... Double(geometry.size.height - self.topInset - self.bottomInset)
                let height = geometry.size.height

                path.move(to: CGPoint(x: 8, y: self.topInset))
                path.addLine(to: CGPoint(x: 8, y: height - self.bottomInset))

                let ticks = self.scale.ticks(nil, range: geometryRange)

                for tick in ticks {
                    path.move(to: CGPoint(x: 3, y: self.topInset + CGFloat(tick)))
                    path.addLine(to: CGPoint(x: 8, y: self.topInset + CGFloat(tick)))
                }

                // then label the ticks by using scale.invert(//) with the values provided

            }.stroke()
        }
    }
}

struct VerticalAxisView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalAxisView(scale: LinearScale(domain: 0 ... 1.0, isClamped: false),
                         topInset: 5.0,
                         bottomInset: 5.0)
    }
}
