//
//  VizControlsView.swift
//  netlaband
//
//  Created by Joseph Heck on 3/5/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

struct VizControlsView: View {
    let min: CGFloat
    let max: CGFloat
    @Binding var strokeValue: CGFloat
    @Binding var blurVal: CGFloat

    func constrain(high: CGFloat, low: CGFloat, _ possible: CGFloat) -> CGFloat {
        if possible < low {
            return low
        }
        if possible > high {
            return high
        }
        return possible
    }

    var body: some View {
        VStack {
            Stepper(onIncrement: {
                self.strokeValue = self.constrain(high: self.max, low: self.min, self.strokeValue + 0.5)
            }, onDecrement: {
                self.strokeValue = self.constrain(high: self.max, low: self.min, self.strokeValue - 0.5)
            }, label: {
                HStack {
                    Text("stroke")
                    Text(String(format: "%.1f", arguments: [self.strokeValue]))
                }
            })
            Stepper(onIncrement: {
                self.blurVal = self.constrain(high: self.max, low: self.min, self.blurVal + 0.5)
            }, onDecrement: {
                self.blurVal = self.constrain(high: self.max, low: self.min, self.blurVal - 0.5)
            }, label: {
                HStack {
                    Text("blur")
                    Text(String(format: "%.1f", arguments: [self.blurVal]))
                }
            })
        }
    }
}

struct VizControlsView_Previews: PreviewProvider {
    static var previews: some View {
        VizControlsView(min: 0.5, max: 30, strokeValue: .constant(2.0), blurVal: .constant(1.0))
    }
}
