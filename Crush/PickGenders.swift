//
//  PickGender.swift
//  rate
//
//  Created by James McGivern on 1/2/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class PickGenders: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(row) {
        case 0: return "male"
        case 1: return "female"
        case 2: return "both"
        default: return ""
        }
    }

    @IBOutlet var pickGenders: UIPickerView!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PickGenders.done))
        right.tintColor = UIColor.black
        
        self.navigationItem.rightBarButtonItem = right
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch(PFUser.current()?.value(forKey: "genderPreference") as! String) {
        case "male": pickGenders.selectRow(0, inComponent: 0, animated: false)
        case "female": pickGenders.selectRow(1, inComponent: 0, animated: false)
        case "both": pickGenders.selectRow(2, inComponent: 0, animated: false)
        default: print("")
        }
    }
    
    @objc func done() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        if pickGenders.selectedRow(inComponent: 0) == 0 {
            PFUser.current()?.setValue("male", forKey: "genderPreference")
        } else if pickGenders.selectedRow(inComponent: 0) == 1 {
            PFUser.current()?.setValue("female", forKey: "genderPreference")
        } else {
            PFUser.current()?.setValue("both", forKey: "genderPreference")
        }
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if success {
                shouldReloadPeople = true
                UIApplication.shared.endIgnoringInteractionEvents()
                self.navigationController?.popViewController(animated: true)
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
                let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
