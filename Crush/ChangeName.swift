//
//  ChangeTextInfo.swift
//  rate
//
//  Created by James McGivern on 2/21/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class ChangeName: UIViewController, UITextFieldDelegate {

    var right = UIBarButtonItem()
    @IBOutlet var first: UITextField!
    @IBOutlet var last: UITextField!
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(ChangeName.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(AgePreference.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
        
        first.becomeFirstResponder()
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        first.text = myName
        last.text = myLast
    }
    
    @objc func done() {
        if let name2 = first.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if name2.count < 2 {
                let alert = UIAlertController(title: "Oops", message: "Name must be at least 2 characters", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if name2.count > 18 {
                let alert = UIAlertController(title: "Oops", message: "Name must be 18 characters or less", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if name2.contains(" ") {
                let alert = UIAlertController(title: "Oops", message: "First name cannot contain spaces", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                if let lastName2 = last.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    if lastName2.count < 2 {
                        let alert = UIAlertController(title: "Oops", message: "Name must be at least 2 characters", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else if lastName2.count > 18 {
                        let alert = UIAlertController(title: "Oops", message: "Name must be 30 characters or less", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else if name2.contains(" ") {
                        let alert = UIAlertController(title: "Oops", message: "Last name cannot contain spaces", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        PFUser.current()!.setValue(name2, forKey: "name")
                        PFUser.current()!.setValue(lastName2, forKey: "lastName")
                        PFUser.current()!.setValue("\(name2.lowercased()) \(lastName2.lowercased())", forKey: "fullName")
                        
                        PFUser.current()!.saveInBackground { (success, error) in
                            if success {
                                UserDefaults.standard.setValue(name2, forKey: "name")
                                UserDefaults.standard.setValue(lastName2, forKey: "lastName")
                                myName = name2
                                myLast = lastName2
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "Oops", message: "Please enter a name", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            let alert = UIAlertController(title: "Oops", message: "Please enter a name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == first {
            last.becomeFirstResponder()
        } else {
            done()
        }
        
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
