//
//  ContentView.swift
//  netlaband
//
//  Created by Joseph Heck on 12/27/19.
//  Copyright © 2019 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct ContentView: View {
    @ObservedObject var networkModel: NetworkAnalyzer

    var body: some View {
        VStack {
            NetworkAnalyzerControlView(networkModel: networkModel)

            TabView {
                IterationOneView(networkModel: networkModel)
                    .tabItem {
                        // Image(systemName: "1.circle")
                        // :-( no SFSymbols on Mac yet
                        Text("1")
                    }

                IterationTwoView(networkModel: networkModel)
                    .tabItem {
                        // Image(systemName: "2.circle")
                        // :-( no SFSymbols on Mac yet
                        Text("2")
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(networkModel: NetworkAnalyzer(urlsToCheck: ["https://google.com/"]))
    }
}
