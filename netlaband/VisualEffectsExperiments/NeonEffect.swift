//
//  NeonEffect.swift
//  netlaband
//
//  Created by Joseph Heck on 3/13/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

// originally thinking this was a good choice for a ViewModifier,
// but as I'm wanting to tweak specifics of a shape, I'm realizing
// that I need something a bit different - ultimately I want to
// have something that works on a Shape-conforming object. That
// I can't just twiddle a ViewModifier to use Shape instead of View
// I need a specific variant of that generic - so we're over in
// ViewBuilder land

struct NeonEffect<Content>: View where Content: Shape {
    let content: () -> Content
    let color: Color
    let blendMode: BlendMode

    init(color: Color, blendMode: BlendMode, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.color = color
        self.blendMode = blendMode
    }

    // I'm not sure handing in Color is what I want to do here...
    // as a SwiftUI Color  can be created, but then I can't determine
    // what it's color values are to make variants of it... and the
    // blend modes aren't doing quite what I hoped in overlaying them

    // I was trying .blend() with various blend modes on the ZStack
    // overlay, but not quite getting what I'd hoped for - which was
    // explicitly lightening the color to make it more "laser like"

    // current semi-working effect is using opacity to lighten towards
    // the background

    var body: some View {
        ZStack {
            // final top layer, intended only to lighten
            // narrowest, and slightly blurred.
            content()
                .stroke(Color.white, lineWidth: 1)
                .blur(radius: 1)
                .blendMode(blendMode)

            // another layer of the original color
            // blurred, narrow, and a touch transparent
            content()
                .stroke(color, lineWidth: 2)
                .blur(radius: 0.5)
                .opacity(0.8)

            // layer over the bottom explicitly lightening
            // but narrower. Slightly blurred and just a touch
            // transparent
            content()
                .stroke(Color.white, lineWidth: 2)
                .blur(radius: 0.5)
                .blendMode(blendMode)
                .opacity(0.8)

            // bottom layer - broad, blurred out, semi-transparent
            content()
                .stroke(color, lineWidth: 4)
                .blur(radius: 2.0)
                .opacity(0.6)
        }
    }
}

/* blend modes kinda confuse me - so here's a primer with external
 // visuals:
 // https://www.slrlounge.com/workshop/the-ultimate-visual-guide-to-understanding-blend-modes/

 lighten:
  lighten
 screen
 colorDodge
 LighterColor

 darken:
 darken
 multiply
 color burn
 darker color

 contrast:
 overlay
 softlight
 hardlight
 vivid light
 pin light

 inversion:
 difference
 exclusion
 extract
 divide

 component:
 hue
 saturation
 color
 luminosity
 */

func blendList() -> [BlendMode] {
    [
//        BlendMode.color, //  ?? solid color, kinda dark
        BlendMode.colorBurn, // (darken) nice glow, no white - otherwise good
        // maybe best choice for light mode, since it darkens into the color

        BlendMode.colorDodge, // (lighten) lighter center, but not white
        // ^^ best so far on black

//        BlendMode.darken, // (darken) darker, not lighter
//        BlendMode.destinationOut, // ?? darker, not lighter
//        BlendMode.destinationOver, // ?? nice glow, no white  otherwise good

//        BlendMode.difference, // (inversion) darker core
//        BlendMode.exclusion, // (inversion) darker

//        BlendMode.hardLight, // (contrast) kind of faded, but good on black

//        BlendMode.hue, // (component) darker
//        BlendMode.lighten, // (lighten) akine to hardlight

        BlendMode.luminosity, // (component) slighter glow on white, brighter on black

//        BlendMode.multiply, // (darken)
//        BlendMode.normal, // normal
//        BlendMode.overlay, // ??
//        BlendMode.plusDarker, // (darken)
        BlendMode.plusLighter, // (lighten) blurry on white, sharper on black
        // ^^ maybe best dark-mode choice

//        BlendMode.saturation, (component)
//        BlendMode.screen, // (lighten) sorta blurry
//        BlendMode.softLight, // (contrast) nice deep color on white, no "lightening" there, but ends up darker on dark background
//        BlendMode.sourceAtop, // ?
    ]
}

struct NeonEffect_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(blendList(), id: \.self) { blendMode in
                PreviewBackground(content: {
                    VStack {
                        NeonEffect(color: Color.primary, blendMode: blendMode) {
                            Rectangle()
                        }

                        NeonEffect(color: Color.red, blendMode: blendMode) {
                            Circle()
                        }

                        NeonEffect(color: Color.blue, blendMode: blendMode) {
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: 50, y: 50))
                            }
                        }
                    }.padding()
            }).environment(\.colorScheme, colorScheme)
                    .frame(width: 100, height: 200, alignment: .center)
                    .previewDisplayName("\(colorScheme) mode, blend: \(blendMode)")
            }
        }
    }
}
