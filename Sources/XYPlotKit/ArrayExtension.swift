//
//  File.swift
//  
//
//  Created by Rick Street on 3/18/20.
//

import Foundation

public extension Array where Element == Double {
    func histogram(numberBins: Int) -> (bins: [Int], binRange: Double) {
        var bins = [Int](repeating: 0, count: numberBins)
        if let max = self.max(), let min = self.min() {
            let binRange = (max - min) / Double(numberBins)
            for value in self {
                if value == Double(numberBins) * binRange {
                    print("= \(value) in bin \(numberBins - 1)")
                    bins[numberBins - 1] += 1
                } else {
                    for i in 0..<numberBins {
                        if value >= Double(i) * binRange && value < Double(i + 1) * binRange {
                            // print("r \(value) in bin \(i)")
                            bins[i] += 1
                        }
                    }
                }
            }
            return (bins: bins, binRange: binRange)
        }
        return (bins: bins, binRange: 0.0)
    }
    
    func histogram(binRange: Double) -> [Int] {
        print("array histogram range...")
        // var bins = [Int](repeating: 0, count: numberBins)
        if let max = self.max(), let min = self.min() {
            
            let numberBins = Int(((max - min) / binRange).rounded(.up))
            var bins = [Int](repeating: 0, count: numberBins)
            
            let binRange = (max - min) / Double(numberBins)
            for value in self {
                if value == Double(numberBins) * binRange {
                    print("= \(value) in bin \(numberBins - 1)")
                    bins[numberBins - 1] += 1
                } else {
                    for i in 0..<numberBins {
                        if value >= Double(i) * binRange && value < Double(i + 1) * binRange {
                            print("r \(value) in bin \(i)")
                            bins[i] += 1
                        }
                    }
                }
            }
            print("no bins \(bins.count)")
            print("array histogram comlete")
            return bins
        }
        print("array histogram comlete, empty array")
        return [Int]()
    }
}
