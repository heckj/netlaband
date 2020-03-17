//
//  ASimpleExampleView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/9/20.
//

import SwiftUI

struct ASimpleExampleView: View {
    let opacity: Double
    @Binding var makeHeavy: Bool

    func determineOpacity() -> Double {
        // maybe do some calculation here
        // mixing the incoming data
        opacity
    }

    func determineFontWeight() -> Font.Weight {
        if makeHeavy {
            return .heavy
        }
        return .regular
    }

    var body: some View {
        ZStack {
            Text("Hello World")
                .fontWeight(determineFontWeight())
                .opacity(determineOpacity())
        }
    }
}

struct ASimpleExampleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ASimpleExampleView(opacity: 0.8, makeHeavy: .constant(true))

            ASimpleExampleView(opacity: 0.8, makeHeavy: .constant(false))
        }
    }
}
