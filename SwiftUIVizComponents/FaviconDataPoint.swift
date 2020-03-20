//
//  FaviconDataPoint.swift
//  netlaband
//
//  Created by Joseph Heck on 3/20/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

struct FaviconDataPoint: View {
    let siteName: String

    var body: some View {
        Image(siteName)
            .resizable()
            .overlay(Rectangle().stroke(Color.primary, lineWidth: 2))
            .frame(width: 20, height: 20, alignment: .center)
    }
}

struct FaviconDataPoint_Previews: PreviewProvider {
    static var previews: some View {
        FaviconDataPoint(siteName: "google")
    }
}
