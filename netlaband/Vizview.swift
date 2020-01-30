//
//  Vizview.swift
//  netlaband
//
//  Created by Joseph Heck on 1/29/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI
import SwiftViz

// Chart().xAxis(LinearScale(0..100))
// ^^ pass in something to link/map the data - a series?
//    (one or more series, that display series of data in chart)
//    optional value, empty by default? aka [Series]()
//    KeyPath to a collection/(sequence?) for each series? (x, and y) - or (x, y, and z)
//    underlying data that keeps the metrics then could be a array of tuples(,), or objects with a keypath
//      example: \.1 picks the 'b' item from tuple(a,b)
//    this feels like a place where we should really try and re-use SwiftUI's ForEach
//    (https://developer.apple.com/documentation/swiftui/foreach), which was oriented specifically
//    to pick and retrieve data for lists of things, which is pretty close (if not identical) to the use
//    case for making a visualization/chart. Each series that we display, is in effect, one of those
//    ForEach structures - a list of values.

// Chart
//  - list of series to be displayed
//    - explicit frame size -&gt; outputrange definition for Scale and Axis pieces
//    - implicit frame size -&gt; infer the output range for scale and axis
// Chart(data: RandomCollection, series [\RandomCollection.1, \RandomCollection.4])
// or
// Chart()
//   .scatterplot() // vs. lineplot() vs. barplot()
//   .series()  - adds a series into the chart
//   .series()  - adds another series into the chart
//   .frame()
//   .xAxis(LinearScale(0...10))

//   .series(symbol type, how to pick it from data -&gt; index() -&gt; value() )

// implies xAxis() is a function that tweaks how Chart() is displayed
// - likely overrides an internal State or property of some form that has a default Scale
// - scale takes an input range and maps to an output domain
//   - if created with only one range, it'll likely be the input range

// re-reading the composing tutorial (https://developer.apple.com/tutorials/swiftui/composing-complex-interfaces)
// and it's clear that they start with a stack and partially "shuffle" the cards together
// to get the layout they want there. I guess rough equiv here would be a combined hstack and vstack:
// hstack ( leftaxis,
//          vstack ( Title
//                   top axis
//                   [Path rendering series]
//                   bottom axis )
//          rightaxis )

// bottom axis:
// vStack ( line &amp; pips with ticks
//          hstack ( Text(number), Text(number2), Text(number3) )
//         )

// NOTE: SwiftUI has an Axis frozen enum indicating the directionality of the
// axis: https://developer.apple.com/documentation/swiftui/axis, but frozen to just horizontal and vertical

// For testing this, consider using https://github.com/nalexn/ViewInspector or
// https://github.com/uber/ios-snapshot-test-case/

public struct AxisView<ScaleType: Scale>: View {
    let leftInset: CGFloat
    let rightInset: CGFloat
    let scale: ScaleType
    init(scale: ScaleType, leftInset: CGFloat?, rightInset: CGFloat?) {
        self.leftInset = leftInset ?? 5.0
        self.rightInset = rightInset ?? 5.0
        self.scale = scale
    }

    public var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                path.move(to: CGPoint(x: self.leftInset, y: 3))
                path.addLine(to: CGPoint(x: width - self.rightInset, y: 3))

                let ticks = self.scale.ticks(10)

                // get list of ticks from associated scale, draw them

                // then label the ticks by using scale.invert(//) with the values provided
            }.stroke(lineWidth: 2.1)
        }
    }
}

let myScale = LinearScale(domain: 0 ... 1.0, range: 0 ... 100.0, isClamped: false)

let start = Date() - TimeInterval(300)
let end = Date()
let myTimeScale = TimeScale(domain: start ... end, range: 0 ... 100.0, isClamped: false)

struct Vizview_Previews: PreviewProvider {
    static var previews: some View {
        AxisView(scale: myTimeScale, leftInset: 5.0, rightInset: 10.0)
    }
}
