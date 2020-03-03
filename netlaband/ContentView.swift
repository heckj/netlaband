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
    @State private var latestMetric: [NetworkAnalysisDataPoint] = [NetworkAnalysisDataPoint]()

    var body: some View {
        VStack {
            NetworkAnalyzerControlView(networkModel: networkModel)
            Button("Yo!") {
                // no action right now
            }
            .onReceive(networkModel.metricPublisher, perform: { dp in
                self.latestMetric.append(dp)
            })
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
