//
//  ViewController.swift
//  TimeOfDay
//
//  Created by Nick Rogness on 11/23/18.
//  Copyright © 2018 Rogness Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var colorPicker:UIPickerView!
    @IBOutlet weak var dateGaugeView: UIView!
    @IBOutlet weak var dateLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .black
        
        let dayOfMonth = Calendar.current.dateComponents([Calendar.Component.day], from: Date())
        dateLabel.text = "\(dayOfMonth.day ?? 0)"
        
        dateGaugeView.backgroundColor = Colors.colors[0].0
        
        colorPicker.backgroundColor = .black
        colorPicker.dataSource = self
        colorPicker.delegate = self
        colorPicker.selectRow(0, inComponent: 0, animated: false)
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
        dateLabel.textColor = color.0
        dateGaugeView.backgroundColor = color.0
    }
}

