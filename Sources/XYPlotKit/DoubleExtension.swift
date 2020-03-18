//
//  File.swift
//  
//
//  Created by Rick Street on 3/18/20.
//

import Foundation

extension Double {
    
    /// Round Double to significant digits
    /// - Parameter digits: number of digits to round to.
    func roundTo(digits:Int) -> Double {
        guard self != 0.0 else {
            return 0
        }
        let divisor = pow(10.0, Double(digits) - ceil(log10(fabs(self))))
        return (self * divisor).rounded() / divisor
    }
}
