//
//  DataPointView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/3/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

struct DataPointTextView: View {
    let dp: NetworkAnalysisDataPoint

    var body: some View {
        HStack {
            Text(dp.timestamp.description)
            Text(String(format: "%.1f KB/sec", arguments: [dp.bandwidth]))
            Text(String(format: "%.1f ms", arguments: [dp.latency]))
        }
    }
}

#if DEBUG
    let singleExamplePoint = NetworkAnalysisDataPoint(
        url: "https://www.google.com/",
        latency: 43.46799850463867, // in ms
        bandwidth: 2437.155212838014 // in Kbytes per second
    )

    struct DataPointTextView_Previews: PreviewProvider {
        static var previews: some View {
            DataPointTextView(dp: singleExamplePoint)
        }
    }
#endif
