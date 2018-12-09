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
    @IBOutlet weak var dateGuageView:UIView!
    @IBOutlet weak var dateLabel:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let dayOfMonth = Calendar.current.dateComponents([Calendar.Component.day], from: Date())
        dateLabel.text = "\(dayOfMonth)"
    }


}

