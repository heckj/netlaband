//
//  CircleDataPoint.swift
//  netlaband
//
//  Created by Joseph Heck on 3/12/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

struct CircleDataPoint: View {
    let size: CGFloat
    let position: CGPoint
    let stroke: CGFloat = 3.0
    let opacity = 0.3

    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color.accentColor)
                .overlay(Circle().stroke(Color.primary, lineWidth: stroke))
                .opacity(opacity)

            GeometryReader { geometry in
                Path { path in
                    // draw horizontal line
                    path.move(to: CGPoint(x: 0,
                                          y: geometry.size.width / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width,
                                             y: geometry.size.width / 2))
                    // draw vertical line
                    path.move(to: CGPoint(x: geometry.size.height / 2,
                                          y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.height / 2,
                                             y: geometry.size.height))

                }.stroke(Color.primary, lineWidth: 0.5)
            }
        }
        .frame(width: size, height: size, alignment: .center)
        .position(position)
    }
}

struct CircleDataPoint_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CircleDataPoint(size: 20,
                            position: CGPoint(x: 30, y: 30))

            CircleDataPoint(size: 40,
                            position: CGPoint(x: 30, y: 30))
        }
        .frame(width: 60, height: 60, alignment: .center)
        .padding()
    }
}
