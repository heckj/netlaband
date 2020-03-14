//
//  PreviewBackground.swift
//  netlaband
//
//  Created by Joseph Heck on 3/13/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

/// Creates a colored background underneath an enclosed view that matches
/// from the environment settings - so that previews can have a dark or light
/// background while experimenting on macOS
struct PreviewBackground<Content>: View where Content: View {
    @Environment(\.colorScheme) var colorSchemeMode

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            if colorSchemeMode == .dark {
                Color.black
                // LinearGradient(Color.darkStart, Color.darkEnd)
            } else {
                Color.white
                // LinearGradient(Color.white, Color.offWhite)
            }
            content()
        }
    }
}

struct PreviewBackground_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in

                PreviewBackground(content: {
                    Text("hi")
                })
                    .environment(\.colorScheme, colorScheme)
                    .frame(width: 100, height: 100, alignment: .center)
                    .previewDisplayName("\(colorScheme)")
            }
        }
    }
}
