//
//  ChangeGender.swift
//  rate
//
//  Created by James McGivern on 3/1/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class ChangeGender: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var genderPicker: UIPickerView!
    
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
    
    var right = UIBarButtonItem()
    
    override func viewWillAppear(_ animated: Bool) {
        if myGender == "male" {
            genderPicker.selectRow(0, inComponent: 0, animated: false)
        } else {
            genderPicker.selectRow(1, inComponent: 0, animated: false)
        }
    }
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(ChangeGender.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
    }
    
    @objc func done() {
        if self.genderPicker.selectedRow(inComponent: 0) == 0 {
            PFUser.current()!.setValue(true, forKey: "gender")
        } else {
            PFUser.current()!.setValue(false, forKey: "gender")
        }
        
        PFUser.current()!.saveInBackground { (success, error) in
            if success {
                if self.genderPicker.selectedRow(inComponent: 0) == 0 {
                    myGender = "male"
                } else {
                    myGender = "female"
                }
                UserDefaults.standard.setValue(myGender, forKey: "gender")
                
                self.navigationController?.popViewController(animated: true)
            } else {
                let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
