//
//  LaserLightShape.swift
//  netlaband
//
//  Created by Joseph Heck on 3/14/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

struct LaserLightShape<Content>: View where Content: Shape {
    let content: () -> Content
    let color: Color
    let lineWidth: CGFloat

    @Environment(\.colorScheme) var colorSchemeMode
    var blendMode: BlendMode {
        if colorSchemeMode == .dark {
            // fundamentally lightens within a dark
            // color scheme
            return BlendMode.colorDodge
        } else {
            // fundamentally darkens within a light
            // color scheme
            return BlendMode.colorBurn
        }
    }

    init(color: Color, lineWidth: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.color = color
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            // top layer, intended only to reinforce the color
            // narrowest, and not blurred or blended
            if colorSchemeMode == .dark {
                content()
                    .stroke(Color.primary, lineWidth: lineWidth / 4)
            } else {
                content()
                    .stroke(color, lineWidth: lineWidth / 4)
            }

            if colorSchemeMode == .dark {
                // pushes in a bit of additional lightness in dark mode
                content()
                    .stroke(Color.primary, lineWidth: lineWidth )
                    .blendMode(.softLight)
            }
            // middle layer, half-width of the stroke and blended
            // with reduced opacity. re-inforces the underlying
            // color - blended to impact the color, but not blurred
            content()
                .stroke(color, lineWidth: lineWidth / 2 )
                .blendMode(blendMode)

            // bottom layer - broad, blurred out, semi-transparent
            // this is the "glow" around the shape
            if colorSchemeMode == .dark {
            content()
                .stroke(color, lineWidth: lineWidth )
                .blur(radius: lineWidth)
                .opacity(0.9)
            } else {
                // knock back the blur/background effects on
                // light mode vs. dark mode
                content()
                    .stroke(color, lineWidth: lineWidth / 2 )
                    .blur(radius: lineWidth / 1.5 )
                    .opacity(0.8)

            }

        }
    }
}

/* blend modes kinda confuse me - so here's a primer with external
 // visuals:
 // https://www.slrlounge.com/workshop/the-ultimate-visual-guide-to-understanding-blend-modes/

 lighten:
 BlendMode.lighten
 BlendMode.screen
 BlendMode.colorDodge
 BlendMode.plusLighter

 darken:
 BlendMode.darken
 BlendMode.multiply
 BlendMode.colorBurn
 BlendMode.plusDarker

 contrast:
 BlendMode.overlay
 BlendMode.softLight
 BlendMode.hardLight

 inversion:
 BlendMode.difference,
 BlendMode.exclusion,

 component:
 BlendMode.hue
 BlendMode.saturation
 BlendMode.color
 BlendMode.luminosity

 unclear about the following:
 BlendMode.destinationOut,
 BlendMode.destinationOver,
 BlendMode.normal,
 BlendMode.sourceAtop

 */

struct LaserLightShape_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in

            PreviewBackground(content: {
                VStack {
                    LaserLightShape(color: Color.orange, lineWidth: 1) {
                        Rectangle()
                    }

                    LaserLightShape(color: Color.red, lineWidth: 2) {
                        Circle()
                    }

                    LaserLightShape(color: Color.blue, lineWidth: 0.5) {
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: 50, y: 50))
                        }
                    }
                }.padding()
            }).environment(\.colorScheme, colorScheme)
                .frame(width: 100, height: 200, alignment: .center)
                .previewDisplayName("\(colorScheme) mode")
        }
    }
}
