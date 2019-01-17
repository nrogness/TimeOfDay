//
//  ViewController.swift
//  TimeOfDay
//
//  Created by Nick Rogness on 11/23/18.
//  Copyright © 2018 Rogness Software. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    
    @IBOutlet weak var colorPicker:UIPickerView!
    @IBOutlet weak var dateGaugeView: UIView!
    @IBOutlet weak var dateLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .black
        
        dateGaugeView.backgroundColor = Colors.colors[0].0
        
        colorPicker.backgroundColor = .black
        colorPicker.dataSource = self
        colorPicker.delegate = self
        
        refresh()
    }
    
    func refresh() {
        let dayOfMonth = Calendar.current.dateComponents([Calendar.Component.day], from: Date())
        dateLabel.text = "\(dayOfMonth.day ?? 0)"
        
        var currentColorIndex = 0
        if let currentColorName = UserDefaults.standard.object(forKey: "TimeColor") as? String {
            if let index = Colors.indexOf(colorName: currentColorName) {
                currentColorIndex = index
            }
            
            if let color = Colors.color(namedBy: currentColorName) {
                dateLabel.textColor = color
                dateGaugeView.backgroundColor = color
            }
        }
        
        colorPicker.selectRow(currentColorIndex, inComponent: 0, animated: false)
    }
}

extension ViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Colors.colors.count
    }
}

extension ViewController : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let color = Colors.colors[row]
        let string = color.1
        return NSAttributedString(string: string, attributes: [.foregroundColor: color.0])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let color = Colors.colors[row]
        
        UserDefaults.standard.set(color.1, forKey: "TimeColor")
        
        dateLabel.textColor = color.0
        dateGaugeView.backgroundColor = color.0
        
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.isWatchAppInstalled {
                do {
                    print("Sending TimeColor: \(color.1)")
                    let dictionary = ["TimeColor": color.1]
                    try session.updateApplicationContext(dictionary)
                } catch {
                    print("ERROR: \(error)")
                }
            }
        }
    }
}

