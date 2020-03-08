//
//  HorizontalTickDisplayView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/8/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

struct HorizontalTickDisplayView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#if DEBUG
    struct HorizontalTickDisplayView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                VStack {
                    HorizontalBandView(scale: LinearScale(domain: 0 ... 5.0, isClamped: false))
                    HorizontalTickDisplayView()
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()

                VStack {
                    HorizontalBandView(scale: LogScale(domain: 1 ... 10.0, isClamped: false))
                    HorizontalTickDisplayView()
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()

                VStack {
                    HorizontalBandView(scale: LogScale(domain: 0.1 ... 100.0, isClamped: false))
                    HorizontalTickDisplayView()
                }
                .frame(width: 400, height: 50, alignment: .center)
                .padding()
            }
        }
    }
#endif
