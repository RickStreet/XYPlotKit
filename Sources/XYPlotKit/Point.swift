//
//  Point.swift
//  Transform
//
//  Created by Rick Street on 7/5/18.
//  Copyright © 2018 Rick Street. All rights reserved.
//

import Foundation

public struct Point {
    public var x: Double
    public var y: Double
    public let time: Double
    
    static var idFactory = -1

    static func getUniqueId() -> Int {
        idFactory += 1
        // print(identifierFactory)
        return idFactory
    }
    
    public init(x: Double, y: Double) {
        time = Double(Point.getUniqueId())
        self.x = x
        self.y = y
    }
    
    public static func reset() {
        idFactory = -1
    }

    
}
