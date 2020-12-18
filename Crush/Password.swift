//
//  Password.swift
//  rate
//
//  Created by James McGivern on 12/8/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit

class Password: UIViewController, UITextFieldDelegate {

    @IBOutlet var feedbackImage: UIImageView!
    @IBOutlet var feedback: UILabel!
    
    @IBOutlet var password: UITextField!
    @IBOutlet var confirm: UITextField!
    @IBOutlet var show1: UIButton!
    @IBOutlet var show2: UIButton!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(Password.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        password.becomeFirstResponder()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(Password.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
        
        feedbackImage.image = UIImage()
        feedback.text = ""
        
        password.addTarget(self, action: #selector(Password.passwordTyped), for: .editingChanged)
        confirm.addTarget(self, action: #selector(Password.confirmTyped), for: .editingChanged)
        password.addTarget(self, action: #selector(Password.passwordTyped), for: .editingDidBegin)
        confirm.addTarget(self, action: #selector(Password.confirmTyped), for: .editingDidBegin)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        self.view.gradientLayer.colors = [UIColor.magenta.cgColor, UIColor.orange.cgColor]
        self.view.gradientLayer.gradient = GradientPoint.bottomLeftTopRight.draw()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        right.isEnabled = true
    }
    
    @objc func passwordTyped() {
        if let password2 = password.text {
            if password2.count == 0 {
                feedbackImage.image = UIImage()
                feedback.text = ""
            } else if password2.count < 4 {
                feedbackImage.image = UIImage(named: "red-cross.png")
                feedback.text = "Must be at least 4 characters"
            } else if password2.count < 7 {
                feedbackImage.image = UIImage(named: "warning.png")
                feedback.text = "Password should be longer"
            } else if password2.count > 30 {
                feedbackImage.image = UIImage(named: "red-cross.png")
                feedback.text = "Cannot go over 30 characters"
            } else if password2.contains(" ") {
                feedbackImage.image = UIImage(named: "red-cross.png")
                feedback.text = "Do not include spaces"
            } else {
                feedbackImage.image = UIImage(named: "Check_mark.png")
                feedback.text = "Please confirm password"
            }
        } else {
            feedbackImage.image = UIImage()
            feedback.text = ""
        }
    }
    
    @objc func confirmTyped() {
        if let confirm2 = confirm.text {
            if confirm2.count == 0 {
                feedbackImage.image = UIImage()
                feedback.text = ""
            } else if confirm2 != password.text {
                feedbackImage.image = UIImage(named: "red-cross.png")
                feedback.text = "Passwords don't match"
            } else {
                if confirm2.count < 4 {
                    feedbackImage.image = UIImage(named: "red-cross.png")
                    feedback.text = "Must be at least 4 characters"
                } else if confirm2.count < 7 {
                    feedbackImage.image = UIImage(named: "warning.png")
                    feedback.text = "Password should be longer"
                } else if confirm2.count > 30 {
                    feedbackImage.image = UIImage(named: "red-cross.png")
                    feedback.text = "Cannot go over 30 characters"
                } else if confirm2.contains(" ") {
                    feedbackImage.image = UIImage(named: "red-cross.png")
                    feedback.text = "Do not include spaces"
                } else {
                    feedbackImage.image = UIImage(named: "Check_mark.png")
                    feedback.text = "Passwords match!"
                }
            }
        } else {
            feedbackImage.image = UIImage()
            feedback.text = ""
        }
    }
    
    @objc func done() {
        if let password2 = password.text {
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
                    pass = password2
                    performSegue(withIdentifier: "photos", sender: self)
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
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    @IBAction func show1(_ sender: Any) {
        password.isSecureTextEntry = !password.isSecureTextEntry
        if show1.currentTitle == "Show" {
            show1.setTitle("Hide", for: .normal)
        } else {
            show1.setTitle("Show", for: .normal)
        }
    }
    @IBAction func show2(_ sender: Any) {
        confirm.isSecureTextEntry = !confirm.isSecureTextEntry
        if show2.currentTitle == "Show" {
            show2.setTitle("Hide", for: .normal)
        } else {
            show2.setTitle("Show", for: .normal)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == password {
            resignFirstResponder()
            confirm.becomeFirstResponder()
        } else {
            done()
        }
        
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.endIgnoringInteractionEvents()
        password.text = pass
        confirm.text = pass
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
