//
//  ContentView.swift
//  CoffeeshopNetworkAdvisor
//
//  Created by Joseph Heck on 3/16/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct ContentView: View {
    @ObservedObject var networkModel: NetworkAnalyzer

    var body: some View {
        Text("Hello, World!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(networkModel: NetworkAnalyzer(urlsToCheck: ["https://google.com/"]))
    }
}
