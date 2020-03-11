//
//  TickLabel.swift
//  netlaband
//
//  Created by Joseph Heck on 3/11/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import CoreGraphics
import Foundation

// OPENQUESTION(heckj): should this be moved into SwiftViz
// and matched up with Ticks there?
//
// it's generally created with the benefit of a formatter,
// the type that we use being dependent on the type that's
// used for the domain of the Scale. Right now we keep the
// formatter bits away from the underlying SwiftViz library
// and entirely at the display logic layer... so perhaps
// it makes sense to stay here.
struct TickLabel: Identifiable {
    let id: UUID
    let rangeLocation: CGFloat
    let value: String

    init(id: UUID, rangeLocation: CGFloat, value: String) {
        self.id = id
        self.rangeLocation = rangeLocation
        self.value = value
    }

    // convenience initializer
    init(rangeLocation: CGFloat, value: String) {
        id = UUID()
        self.rangeLocation = rangeLocation
        self.value = value
    }

    static func makeDefaultFormatter() -> Formatter {
        let defaultFormatter = NumberFormatter()
        defaultFormatter.numberStyle = .decimal
        defaultFormatter.minimumFractionDigits = 1
        defaultFormatter.maximumFractionDigits = 2
        return defaultFormatter
    }
}
