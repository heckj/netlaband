//
//  NetworkAnalyzerControlView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

struct NetworkAnalyzerControlView: View {
    @ObservedObject var networkModel: NetworkAnalyzer

    let floatFormatter = NumberFormatter()

    var body: some View {
        VStack {
            HStack {
                Toggle(isOn: $networkModel.active, label: {
                    Text("Active")
                    }).padding()
                Slider(value: $networkModel.timerinterval,
                       in: 0.5 ... 10.0,
                       step: 0.5,
                       label: {
                           Text(String(format: "Every %.1f seconds", arguments: [networkModel.timerinterval]))
                        }).padding()
            }
//            List(networkModel.urlsToValidate, id: \.self) { site in
//                Text(site)
//            }
        }
    }
}

struct NetworkAnalyzerControlView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkAnalyzerControlView(networkModel: NetworkAnalyzer(urlsToCheck: ["https://google.com/"]))
            .frame(width: 300, height: 150, alignment: .center)
    }
}
