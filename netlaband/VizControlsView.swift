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
    @Binding var opacityVal: CGFloat
    @Binding var timeDurationVal: CGFloat

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
        HStack {
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

            Stepper(onIncrement: {
                self.opacityVal = self.constrain(high: 1.0, low: 0.0, self.opacityVal + 0.1)
            }, onDecrement: {
                self.opacityVal = self.constrain(high: 1.0, low: 0.0, self.opacityVal - 0.1)
            }, label: {
                HStack {
                    Text("opacity")
                    Text(String(format: "%.1f", arguments: [self.opacityVal]))
                }
            })

            Stepper(onIncrement: {
                self.timeDurationVal = self.constrain(high: 120.0, low: 0.0, self.timeDurationVal + 1.0)
            }, onDecrement: {
                self.timeDurationVal = self.constrain(high: 120.0, low: 0.0, self.timeDurationVal - 1.0)
            }, label: {
                HStack {
                    Text("duration")
                    Text(String(format: "%.1f", arguments: [self.timeDurationVal]))
                }
            })
        }
    }
}

struct VizControlsView_Previews: PreviewProvider {
    static var previews: some View {
        VizControlsView(min: 0.5, max: 30, strokeValue: .constant(2.0), blurVal: .constant(1.0), opacityVal: .constant(1.0), timeDurationVal: .constant(50.0))
    }
}
