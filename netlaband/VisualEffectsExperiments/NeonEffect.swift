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

    init(color: Color, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.color = color
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
                .blendMode(.screen)

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
                .blendMode(.screen)
                .opacity(0.8)

            // bottom layer - broad, blurred out, semi-transparent
            content()
                .stroke(color, lineWidth: 4)
                .blur(radius: 2.0)
                .opacity(0.6)
        }
    }
}

struct NeonEffect_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NeonEffect(color: Color.primary) {
                Rectangle()
            }.padding()

            NeonEffect(color: Color.red) {
                Circle()
            }.padding()

            NeonEffect(color: Color.blue) {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 50, y: 50))
                }
            }.padding()
        }
    }
}
