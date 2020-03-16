//
//  NeonEffect.swift
//  netlaband
//
//  Created by Joseph Heck on 3/13/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import PreviewBackground
import SwiftUI

// NOTE(heckj): I was originally thinking this could be done with
// a ViewModifier, but as I'm wanting to leverage the specifics
// of a generic 'Shape', it was clear that ViewModifier (which
// only works on View) wasn't the right tool.
// I need a specific variant of that generic - so we're over in
// ViewBuilder land to achieve this effect.

struct NeonShape<Content>: View where Content: Shape {
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
            content()
                .stroke(color, lineWidth: lineWidth / 4)

            if colorSchemeMode == .dark {
                // blends in an explicit lightness in dark mode
                // to make the effect stand out as more "light producing"
                // - if done in light mode, the primary color (black)
                // just produces a darkening effect, making a sort of
                // negative light visual impact. The next layer down
                // of color alone does a nice job crisping up the
                // visual with light mode.
                content()
                    .stroke(Color.primary, lineWidth: lineWidth / 2.0)
                    .blendMode(blendMode)
                    .opacity(0.8)
            }

            // middle layer, half-width of the stroke and blended
            // with reduced opacity. re-inforces the underlying
            // color - blended to impact the color, but not blurred
            content()
                .stroke(color, lineWidth: lineWidth)
                .blendMode(blendMode)
                .opacity(0.8)

            // bottom layer - broad, blurred out, semi-transparent
            // this is the "glow" around the shape
            content()
                .stroke(color, lineWidth: lineWidth)
                // decreasing the blur here decreases the "glow"
                // effect and re-inforces the overall shape
                .blur(radius: lineWidth / 2)
                .opacity(0.4)
        }
    }
}

struct NeonShape_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in

            PreviewBackground(content: {
                VStack {
                    NeonShape(color: Color.orange, lineWidth: 4) {
                        Rectangle()
                    }

                    NeonShape(color: Color.red, lineWidth: 4) {
                        Circle()
                    }

                    NeonShape(color: Color.blue, lineWidth: 4) {
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
