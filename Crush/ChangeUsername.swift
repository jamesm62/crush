//
//  ChangeUsername.swift
//  rate
//
//  Created by James McGivern on 2/21/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class ChangeUsername: UIViewController, UITextFieldDelegate {

    @IBOutlet var username: UITextField!
    
    var right = UIBarButtonItem()
    
    var badnames = ["fuck", "bitch", "niger", "cunt", "faggot", "clit", "ass", "hoe", "shit", "pussy", "penis", "dick", "sex", "anal", "orgy", "rape", "slut", "pennis", "fucck", "shiit", "porn", "porrn", "stripper", "whore", "mastur", "jerk", "cum", "nigg", "cock", "kawk", "kock", "nigger"]
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(ChangeUsername.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ChangeUsername.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
        
        username.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        username.text = myUsername
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    @objc func done() {
        if let username2 = username.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
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
                            PFUser.current()!.username = username2
                            UserDefaults.standard.setValue(username2, forKey: "username")
                            
                            PFUser.current()!.saveInBackground { (success, error) in
                                if success {
                                    myUsername = username2
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
