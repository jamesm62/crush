//
//  Username.swift
//  rate
//
//  Created by James McGivern on 12/7/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit
import Parse

class Username: UIViewController, UITextFieldDelegate {

    @IBOutlet var usernameField: UITextField!
    @IBOutlet var feedbackImage: UIImageView!
    @IBOutlet var feedback: UILabel!
    
    var badnames = ["fuck", "bitch", "niger", "cunt", "faggot", "clit", "ass", "hoe", "shit", "pussy", "penis", "dick", "sex", "anal", "orgy", "rape", "slut", "pennis", "fucck", "shiit", "porn", "porrn", "stripper", "whore", "mastur", "jerk", "cum", "nigg", "cock", "kawk", "kock", "nigger"]
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(Username.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        feedbackImage.image = UIImage()
        feedback.text = ""
        
        usernameField.addTarget(self, action: #selector(Username.usernameTyped), for: .editingChanged)
        usernameField.becomeFirstResponder()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(Username.touched))
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
    
    override func viewDidAppear(_ animated: Bool) {
        right.isEnabled = true
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    @objc func usernameTyped() {
        if let username2 = usernameField.text {
            if username2.count == 0 {
                feedbackImage.image = UIImage()
                feedback.text = ""
            } else if username2.count < 5 {
                feedbackImage.image = UIImage(named: "red-cross.png")
                feedback.text = "Must be at least 5 characters"
            } else if username2.count > 25 {
                feedbackImage.image = UIImage(named: "red-cross.png")
                feedback.text = "Cannot go over 25 characters"
            } else if username2.contains(" ") {
                feedbackImage.image = UIImage(named: "red-cross.png")
                feedback.text = "Do not include spaces"
            } else {
                feedbackImage.image = UIImage(named: "Check_mark.png")
                feedback.text = "Good username"
            }
        } else {
            feedbackImage.image = UIImage()
            feedback.text = ""
        }
    }
    
    @objc func done() {
        if let username2 = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            for badname in badnames {
                if username2.contains(badname) {
                    let alert = UIAlertController(title: "Oops", message: "Please choose an appropriate username", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            if username2.count == 0 {
                let alert = UIAlertController(title: "Oops", message: "Please enter a username", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if username2.count < 5 {
                let alert = UIAlertController(title: "Oops", message: "Username must be at least 5 characters", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if username2.count > 30 {
                let alert = UIAlertController(title: "Oops", message: "Username must be 30 characters or less", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if username2.contains(" ") {
                let alert = UIAlertController(title: "Oops", message: "Username cannot have spaces", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                feedback.text = "Checking availability..."
                
                let query = PFUser.query()
                
                query?.whereKey("username", equalTo: username2)
                
                query?.getFirstObjectInBackground(block: { (user, error) in
                    if error == nil {
                        if user != nil {
                            let alert = UIAlertController(title: "Oops", message: "Sorry, that username is taken. Please try another one", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        if error!.localizedDescription.lowercased().contains("matched") {
                            username = username2
                            self.performSegue(withIdentifier: "password", sender: self)
                        } else {
                            let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        } else {
            let alert = UIAlertController(title: "Oops", message: "Please enter a username", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        done()
        
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        usernameField.text = username
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
