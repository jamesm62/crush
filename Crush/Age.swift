//
//  Age.swift
//  rate
//
//  Created by James McGivern on 12/30/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit

class Age: UIViewController, UITextViewDelegate {

    @IBOutlet var ones: UITextView!
    @IBOutlet var tens: UITextView!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(Age.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        tens.becomeFirstResponder()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(Age.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        self.view.gradientLayer.colors = [UIColor.orange.cgColor, UIColor.yellow.cgColor]
        self.view.gradientLayer.gradient = GradientPoint.bottomLeftTopRight.draw()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        right.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if age != 0 {
            let number = Double(age)/10.0
            let tens = Int(floor(number))
            let ones = age-(10*tens)
            self.tens.text = "\(tens)"
            self.ones.text = "\(ones)"
            self.tens.isEditable = false
            self.ones.isEditable = false
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        tens.text = ""
        ones.text = ""
        ones.isEditable = true
        tens.isEditable = true
        tens.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == tens && tens.text.count == 1 {
            tens.isEditable = false
            ones.becomeFirstResponder()
        } else if textView.text.count > 1 {
            textView.text = ""
        } else if textView == ones && ones.text.count == 0 {
            ones.text = ""
        } else if textView == ones && ones.text.count == 1 {
            ones.isEditable = false
            tens.isEditable = false
        }
    }
    
    @objc func done() {
        if tens.text == "" || tens.text == "0" {
            let alert = UIAlertController(title: "Oops", message: "You must be at least 18 to use this app", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if ones.text == "" {
            let alert = UIAlertController(title: "Oops", message: "Please enter a valid age", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let tens = Int(self.tens.text!)
            let ones = Int(self.ones.text!)
            
            age = 10*tens! + ones!
            if age < 18 {
                let alert = UIAlertController(title: "Oops", message: "You must be at least 18 to use this app", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                if age > 70 {
                    let alert = UIAlertController(title: "Oops", message: "You must be 70 or younger to use this app", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "gender", sender: self)
                }
            }
        }
    }
    
    @objc func touched() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
