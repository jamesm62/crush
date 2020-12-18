//
//  ChangePassword.swift
//  rate
//
//  Created by James McGivern on 2/22/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class ChangePassword: UIViewController, UITextFieldDelegate {

    @IBOutlet var current: UITextField!
    @IBOutlet var new: UITextField!
    @IBOutlet var confirm: UITextField!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(ChangeUsername.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ChangePassword.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
        
        current.becomeFirstResponder()
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    @objc func done() {
        if let current2 = current.text {
            if let password2 = new.text {
                if let confirm2 = confirm.text {
                    if password2 != confirm2 {
                        let alert = UIAlertController(title: "Oops", message: "Passwords don't match", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else if password2.count < 4 {
                        let alert = UIAlertController(title: "Oops", message: "Password must be at least 4 characters", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else if password2.count > 20 {
                        let alert = UIAlertController(title: "Oops", message: "Password must be 20 characters or less", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        PFUser.logInWithUsername(inBackground: PFUser.current()!.username!, password: current2, block: { (user, error) in
                            if user != nil {
                                PFUser.current()!.password = self.new.text!
                                PFUser.current()?.saveInBackground(block: { (success, error) in
                                    if success {
                                        self.navigationController?.popViewController(animated: false)
                                    } else if error != nil {
                                        let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                })
                            } else {
                                let alert = UIAlertController(title: "Oops", message: "You have not entered a valid current password!", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        })
                    }
                } else {
                    let alert = UIAlertController(title: "Oops", message: "Please confirm your password", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Oops", message: "Please enter a password", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else if current.text!.count == 0 {
            let alert = UIAlertController(title: "Oops", message: "Please enter your current password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Oops", message: "Please enter your current password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == current {
            new.becomeFirstResponder()
        } else if textField == new {
            confirm.becomeFirstResponder()
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
