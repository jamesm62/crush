//
//  Register.swift
//  rate
//
//  Created by James McGivern on 12/7/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit

class Register: UIViewController, UITextFieldDelegate {

    @IBOutlet var nameField: UITextField!
    var right = UIBarButtonItem()
    override func viewDidLoad() {
        /*
        var backgroundImage = UIImageView(image: UIImage(named: "homeScreenBackground.png"))
        self.view.addSubview(backgroundImage)
        self.view.sendSubview(toBack: backgroundImage)
         */
        
        right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(Register.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        nameField.becomeFirstResponder()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(Register.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        self.view.gradientLayer.colors = [UIColor.yellow.cgColor, UIColor.cyan.cgColor]
        self.view.gradientLayer.gradient = GradientPoint.bottomLeftTopRight.draw()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        right.isEnabled = true
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    @objc func done() {
        if let name2 = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if name2.count < 2 {
                let alert = UIAlertController(title: "Oops", message: "Name must be at least 2 characters", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if name2.count > 18 {
                let alert = UIAlertController(title: "Oops", message: "Name must be 18 characters or less", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if name2.contains(" ") {
                let alert = UIAlertController(title: "Oops", message: "Name cannot contain spaces", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                name = name2
                performSegue(withIdentifier: "lastName", sender: self)
            }
        } else {
            let alert = UIAlertController(title: "Oops", message: "Please enter a name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        nameField.text = name
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
