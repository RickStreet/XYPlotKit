//
//  NiceAxis.swift
//  PIDLab
//
//  Created by Rick Street on 9/21/23.
//  Copyright © 2023 Rick Street. All rights reserved.
//

import Foundation


class NiceAxis {
    var min: Double
    var max: Double
    let maxNumberTicks = 12
    let minNumberTicks = 6
    var numberTicks = 10
    let maxTickSpacing = 15.0
    var tickSpacing = 10.0
    let roundBys = [1000.0, 500.0, 200.0, 100.0, 50.0, 25.0, 20.0, 10.0, 5.0, 4.0, 2.0, 1.0, 0.5, 0.25, 0.2, 0.1, 0.05, 0.025, 0.02, 0.01, 0.001, 0.0001]
    var spacing = 0.0
    var newMin = 0.0
    var newMax = 0.0

    private func axis() {
        let range = max - min
        // var rMin = min
        // var rMax = max

        let rawSpacing = range / Double(numberTicks)
        let maxSpacing = range / Double(minNumberTicks)

        spacing = 0.0
        for n in roundBys {
            print("n \(n)")
            // Swift.print("\(n)")
            if n < maxSpacing {
                newMin = roundDown(value: min, by: n)
                newMax = roundUp(value: max, by: n)
                if (min - newMin <= rawSpacing) && (newMax - max <= rawSpacing) {
                    // rMin = newMin
                    // rMax = newMax
                    // roundBy = n
                    spacing = roundUp(value: rawSpacing, by: n)
                    print("spacing \(spacing)")
                    break
                }
            }
        }
        numberTicks = Int((newMax - newMin) / spacing)
        print()
        print("tick spacing \(spacing)")
        print("newMin \(newMin)")
        print("newMax \(newMax)")
        print("numberTicks \(numberTicks)")
    }
    
    func roundUp(value: Double, by: Double) -> Double {
        let newValue = ceil(value / by) * by
        return newValue
    }

    func roundDown(value: Double, by: Double) -> Double {
        if value >= 0.0 {
            return Double(Int(value / by)) * by
        } else {
            return -ceil(-value / by) * by
        }
    }
       
    init(min: Double, max: Double) {
        self.min = min
        self.max = max
        axis()
    }
}
