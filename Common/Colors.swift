//
//  Colors.swift
//  TimeOfDay
//
//  Created by Nick Rogness on 12/12/18.
//  Copyright © 2018 Rogness Software. All rights reserved.
//

import Foundation
import UIKit

class Colors {
    static let colors:[(UIColor, String)] = [(.white, "White"), (.red, "Red"), (.blue, "Blue"), (.green, "Green"), (.yellow, "Yellow"), (.cyan, "Cyan")]
    
    static var names:[String] {
        return colors.map({ (_, name) -> String in
            return name
        })
    }
    
    static func color(namedBy name:String) -> UIColor? {
        for (color, colorName) in colors {
            if name == colorName {
                return color
            }
        }
        
        return nil
    }
    
    static func indexOf(colorName:String) -> Int? {
        return colors.firstIndex(where: { (color, name) -> Bool in
            if (name == colorName) {
                return true
            }
            return false
        })
    }
}
