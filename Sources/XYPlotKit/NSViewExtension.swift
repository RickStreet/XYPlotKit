//
//  Extensions.swift
//  CurveFit
//
//  Created by Rick Street on 11/14/24.
//

import Cocoa

extension NSView {
    var isDarkMode: Bool {
        if #available(OSX 10.14, *) {
            if effectiveAppearance.name == .darkAqua {
                return true
            }
        }
        return false
    }
    
    var backgroundColor: NSColor? {

            get {
                if let colorRef = self.layer?.backgroundColor {
                    return NSColor(cgColor: colorRef)
                } else {
                    return nil
                }
            }

            set {
                self.wantsLayer = true
                self.layer?.backgroundColor = newValue?.cgColor
            }
        }
}
