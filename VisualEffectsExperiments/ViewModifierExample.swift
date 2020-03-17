//
//  NeonEffect.swift
//  netlaband
//
//  Created by Joseph Heck on 3/13/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

// example ViewModifier from Paul Hudson's Hacking with Swift
// https://www.hackingwithswift.com/books/ios-swiftui/custom-modifiers

struct PrimaryLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.red)
            .foregroundColor(Color.white)
            .font(.largeTitle)
    }
}

extension View {
    // convenience function for applying our style effects
    // as a modifier
    func primaryLabel() -> some View {
        modifier(PrimaryLabel())
    }
}

struct ViewModifierExample: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ViewModifierExample_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewModifierExample()
                .modifier(PrimaryLabel())

            ViewModifierExample()
                .primaryLabel()
        }
    }
}
