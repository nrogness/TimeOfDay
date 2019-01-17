//
//  InterfaceController.swift
//  TimeOfDay WatchKit Extension
//
//  Created by Nick Rogness on 11/23/18.
//  Copyright © 2018 Rogness Software. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var dateLabel:WKInterfaceLabel!
    @IBOutlet var colorPicker:WKInterfacePicker!
    @IBOutlet weak var topGroup: WKInterfaceGroup!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        let dayOfMonth = Calendar.current.component(.day, from: Date())
        dateLabel.setText("\(dayOfMonth)")
        
        // Get the color from UserDefaults
        var currentColorIndex = 0
        if let currentColorName = UserDefaults.standard.object(forKey: "TimeColor") as? String {
            if let index = Colors.indexOf(colorName: currentColorName) {
                currentColorIndex = index
            }
            
            if let color = Colors.color(namedBy: currentColorName) {
                dateLabel.setTextColor(color)
                topGroup.setBackgroundColor(color)
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
        topGroup.setBackgroundColor(color)
        
        UserDefaults.standard.set(name, forKey: "TimeColor")
        
        ExtensionDelegate.reloadComplications()
    }
}
