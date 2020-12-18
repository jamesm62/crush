//
//  AddMySchool.swift
//  rate
//
//  Created by James McGivern on 3/6/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

var popIt = false

class AddMySchool: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var schoolName: UITextField!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AddMySchool.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        schoolName.becomeFirstResponder()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(AddMySchool.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    @objc func done() {
        if let schoolName2 = schoolName.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if schoolName2.count < 8 {
                let alert = UIAlertController(title: "Oops", message: "Please type the full name of your school", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if schoolName2.count > 50 {
                let alert = UIAlertController(title: "Oops", message: "Name is too long", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if schoolNamesForChangingSchool.contains(schoolName2) {
                let alert = UIAlertController(title: "Oops", message: "This school has already been added. Please go back and select it", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                PFUser.current()!.setValue(schoolName2, forKey: "school")
                
                PFUser.current()!.saveInBackground { (success, error) in
                    if success {
                        mySchool = schoolName2
                        popIt = true
                        UserDefaults.standard.setValue(schoolName2, forKey: "school")
                        
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "Oops", message: "Please enter a school name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        done()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
