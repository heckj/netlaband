//
//  ContentView.swift
//  netlaband
//
//  Created by Joseph Heck on 12/27/19.
//  Copyright © 2019 JFH Consulting. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var networkModel: NetworkAnalyzer

    var body: some View {
        VStack {
            Toggle(isOn: $networkModel.active, label: {
                Text("Active")
            })
            HStack {
                Text("Frequency: ")
                // this seems to exhibit some sort of SwiftUI bug
                // Text(String(format: "%.1f", networkModel.timerinterval))
            }
            Slider(value: $networkModel.timerinterval, in: 0.0 ... 10.0)
            ForEach(networkModel.urlsToValidate, id: \.self) { site in
                Text(site)
            }
            Button("Yo!") {
                // no action right now
            }
        }
        .frame(maxWidth: 400, maxHeight: 180)
        .background(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(networkModel: NetworkAnalyzer(urlsToCheck: ["https://google.com/"]))
    }
}
