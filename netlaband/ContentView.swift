//
//  ContentView.swift
//  netlaband
//
//  Created by Joseph Heck on 12/27/19.
//  Copyright © 2019 JFH Consulting. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let message: String
    var body: some View {
        VStack {
            Text(message)
                .rotation3DEffect(Angle(degrees: 30),
                                  axis: /*@START_MENU_TOKEN@*/(x: 10.0, y: 10.0, z: 10.0)/*@END_MENU_TOKEN@*/)

            Button("Yo!") {
                // no action right now
            }
            .border(/*@START_MENU_TOKEN@*/Color.blue/*@END_MENU_TOKEN@*/, width: 3)
        }
        .frame(maxWidth: 400, maxHeight: 180)
        .background(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(message: "Hello World")
    }
}
