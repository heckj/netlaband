//
//  DiamondDataPoint.swift
//  netlaband
//
//  Created by Joseph Heck on 3/16/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import PreviewBackground
import SwiftUI

struct DiamondDataPoint: View {
    let size: CGFloat
    let position: CGPoint
    let stroke: CGFloat = 3.0
    let backgroundOpacity = 0.2
    let borderOpacity = 0.5

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                // diamond border
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 2, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width / 5, y: geometry.size.height / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width * 4 / 5, y: geometry.size.height / 2))
                    path.closeSubpath()
                }
                .stroke(lineWidth: self.stroke)
                .opacity(self.borderOpacity)

                // diamond fill (separate opacity)
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 2, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width / 5, y: geometry.size.height / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width * 4 / 5, y: geometry.size.height / 2))
                    path.closeSubpath()
                }
                .foregroundColor(Color.accentColor)
                .opacity(self.backgroundOpacity)

                // diamond cross hairs
                Path { path in
                    // draw horizontal line
                    path.move(to: CGPoint(x: geometry.size.width / 5,
                                          y: geometry.size.width / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width * 4 / 5,
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

struct DiamondDataPoint_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                ForEach([20, 40], id: \.self) { size in
                    PreviewBackground {
                        DiamondDataPoint(size: size,
                                         position: CGPoint(x: 30, y: 30))
                            .previewDisplayName("\(size), \(colorScheme)")
                    } // PreviewBackground
                    .environment(\.colorScheme, colorScheme)
                } // ForEach size
            } // ForEach colorScheme
        }
        .frame(width: 60, height: 60, alignment: .center)
        .padding()
    }
}
