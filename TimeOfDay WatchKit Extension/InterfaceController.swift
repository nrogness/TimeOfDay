//
//  InterfaceController.swift
//  TimeOfDay WatchKit Extension
//
//  Created by Nick Rogness on 11/23/18.
//  Copyright © 2018 Rogness Software. All rights reserved.
//

import WatchKit
import Foundation

class Colors {
    static let colors:[(UIColor, String)] = [(.white, "White"), (.red, "Red"), (.blue, "Blue"), (.green, "Green"), (.black, "Black")]
    
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


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var dateLabel:WKInterfaceDate!
    @IBOutlet var colorPicker:WKInterfacePicker!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        // Get the color from UserDefaults
        var currentColorIndex = 0
        if let currentColorName = UserDefaults.standard.object(forKey: "TimeColor") as? String {
            if let index = Colors.indexOf(colorName: currentColorName) {
                currentColorIndex = index
            }
            
            if let color = Colors.color(namedBy: currentColorName) {
                dateLabel.setTextColor(color)
            }
        }
        
        let pickerItems = Colors.names.map { (name) -> WKPickerItem in
            let item = WKPickerItem()
            item.title = name
            return item
        }
        colorPicker.setItems(pickerItems)
        colorPicker.setSelectedItemIndex(currentColorIndex)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func colorPickerAction(_ value: Int) {
        let (color, name) = Colors.colors[value]
        
        dateLabel.setTextColor(color)
        
        UserDefaults.standard.set(name, forKey: "TimeColor")
        
        ExtensionDelegate.reloadComplications()
    }
}
