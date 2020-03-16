//
//  SquareDataPoint.swift
//  netlaband
//
//  Created by Joseph Heck on 3/16/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import PreviewBackground
import SwiftUI

struct SquareDataPoint: View {
    let size: CGFloat
    let position: CGPoint
    let stroke: CGFloat = 3.0
    let backgroundOpacity = 0.2
    let borderOpacity = 0.5

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.accentColor)
                .opacity(backgroundOpacity)

            // second circle isn't an overlay on the first
            // so that we can apply a different opacity to it.
            Rectangle()
                .stroke(lineWidth: stroke)
                .opacity(borderOpacity)

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

struct DiamondDataPoint: View {
    let size: CGFloat
    let position: CGPoint
    let stroke: CGFloat = 3.0
    let backgroundOpacity = 0.2
    let borderOpacity = 0.5

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.accentColor)
                .opacity(backgroundOpacity)

            // second circle isn't an overlay on the first
            // so that we can apply a different opacity to it.
            Rectangle()
                .stroke(lineWidth: stroke)
                .opacity(borderOpacity)

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
        .rotationEffect(Angle(degrees: 45.0))
        .frame(width: size, height: size, alignment: .center)
        .position(position)
    }
}

struct SquareDataPoint_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                ForEach([20, 40], id: \.self) { size in
                    PreviewBackground {
                        HStack {
                            SquareDataPoint(size: size,
                                            position: CGPoint(x: 30, y: 30))
                                .previewDisplayName("\(size), \(colorScheme)")

                            DiamondDataPoint(size: size,
                                             position: CGPoint(x: 30, y: 30))
                                .previewDisplayName("\(size), \(colorScheme)")
                        } // HStack
                    } // PreviewBackground
                    .environment(\.colorScheme, colorScheme)
                } // ForEach size
            } // ForEach colorScheme
        }
        .frame(width: 140, height: 80, alignment: .center)
        .padding()
    }
}

/*
 ForEach(ColorScheme.allCases, id: \.self) { colorScheme in

     PreviewBackground(content: {
         Text("hi")
 })
         .environment(\.colorScheme, colorScheme)
         .frame(width: 100, height: 100, alignment: .center)
         .previewDisplayName("\(colorScheme)")

 */
