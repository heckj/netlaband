//
//  SampleShape.swift
//  netlaband
//
//  Created by Joseph Heck on 3/13/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

/// Just an interesting shape...
struct TwiddleView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 5))

                path.addCurve(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2 * 1.5),
                              control1: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 5),
                              control2: CGPoint(x: geometry.size.width / 5, y: geometry.size.height / 2))
            }.stroke(lineWidth: 1)
        }
    }
}

struct SampleShape_Previews: PreviewProvider {
    static var previews: some View {
        TwiddleView()
    }
}
