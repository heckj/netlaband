//
//  BasicSiteView.swift
//  netlaband
//
//  Created by Joseph Heck on 1/2/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

struct BasicSiteView: View {
    let site: String
    var body: some View {
        HStack {
            Text(site)
            Rectangle().stroke(Color.black)
        }
    }
}

struct BasicSiteView_Previews: PreviewProvider {
    let singleExamplePoint = NetworkAnalysisDataPoint(
        url: "https://www.google.com/",
        latency: 43.46799850463867, // in ms
        bandwidth: 2437.155212838014 // in Kbytes per second
    )

    static var previews: some View {
        BasicSiteView(site: "https://www.google.com/")
            .frame(width: 400, height: 100, alignment: .center)
    }
}
