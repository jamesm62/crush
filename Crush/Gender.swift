//
//  Gender.swift
//  rate
//
//  Created by James McGivern on 12/30/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit

class Gender: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "male"
        } else {
            return "female"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        right.isEnabled = true
    }
    
    @IBOutlet var genderPicker: UIPickerView!
    
    var right = UIBarButtonItem()
    
    override func viewWillAppear(_ animated: Bool) {
        if gender {
            genderPicker.selectRow(0, inComponent: 0, animated: false)
        } else {
            genderPicker.selectRow(1, inComponent: 0, animated: false)
        }
    }
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(Gender.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        self.view.gradientLayer.colors = [UIColor.yellow.cgColor, UIColor.cyan.cgColor]
        self.view.gradientLayer.gradient = GradientPoint.bottomLeftTopRight.draw()
    }
    
    @objc func done() {
        gender = genderPicker.selectedRow(inComponent: 0) == 0
        self.performSegue(withIdentifier: "username", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
