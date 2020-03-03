//
//  BasicSiteView.swift
//  netlaband
//
//  Created by Joseph Heck on 1/2/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct BasicSiteView: View {
    let site: String
    var body: some View {
        HStack {
            Text(site)

            VStack {
                GeometryReader { geometry in
                    // geometry here provides us access to know the size of the
                    // object we've been placed within...
                    // geometry.size (CGSize)
                    // geometry.frame (CGRect)

                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height - 5))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height - 5))
                    }.stroke(Color.red)
                }

                HorizontalAxisView(scale: SwiftViz.LogScale(domain: 1 ... 10.0, isClamped: false))
            }
        }
    }
}

// https://developer.apple.com/tutorials/swiftui/drawing-paths-and-shapes

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
