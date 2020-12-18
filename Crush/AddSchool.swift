//
//  AddSchool.swift
//  Crush
//
//  Created by James McGivern on 1/4/18.
//  Copyright © 2018 Crush. All rights reserved.
//

import UIKit

class AddSchool: UIViewController, UITextFieldDelegate {

    @IBOutlet var schoolName: UITextField!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(AddSchool.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        schoolName.becomeFirstResponder()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(AddSchool.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        self.view.gradientLayer.colors = [UIColor.cyan.cgColor, UIColor.magenta.cgColor]
        self.view.gradientLayer.gradient = GradientPoint.bottomLeftTopRight.draw()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        schoolName.text = school
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
            } else if schoolNamesForSignUp.contains(schoolName2) {
                let alert = UIAlertController(title: "Oops", message: "This school has already been added. Please go back and select it", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                school = schoolName2
                performSegue(withIdentifier: "socialMedia", sender: self)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
