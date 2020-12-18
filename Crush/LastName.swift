//
//  LastName.swift
//  rate
//
//  Created by James McGivern on 1/1/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit

class LastName: UIViewController, UITextFieldDelegate {

    @IBOutlet var lastName: UITextField!
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(LastName.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        lastName.becomeFirstResponder()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(LastName.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        self.view.gradientLayer.colors = [UIColor.cyan.cgColor, UIColor.blue.cgColor]
        self.view.gradientLayer.gradient = GradientPoint.bottomLeftTopRight.draw()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        right.isEnabled = true
    }
    
    @objc func done() {
        if let lastName2 = lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if lastName2.count < 2 {
                let alert = UIAlertController(title: "Oops", message: "Name must be at least 2 characters", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if lastName2.count > 18 {
                let alert = UIAlertController(title: "Oops", message: "Name must be 30 characters or less", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if lastName2.contains(" ") {
                let alert = UIAlertController(title: "Oops", message: "Name cannot contain spaces", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                last = lastName2
                performSegue(withIdentifier: "age", sender: self)
            }
        } else {
            let alert = UIAlertController(title: "Oops", message: "Please enter a name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        done()
        
        return true
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lastName.text = last
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
