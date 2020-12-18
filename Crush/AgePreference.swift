//
//  AgePreference.swift
//  rate
//
//  Created by James McGivern on 1/2/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class AgePreference: UIViewController, UITextFieldDelegate {

    @IBOutlet var firstAge: UITextField!
    @IBOutlet var secondAge: UITextField!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AgePreference.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(AgePreference.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
        
        firstAge.becomeFirstResponder()
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        firstAge.text = "\((PFUser.current()!.value(forKey: "agePreference") as! [Int])[0])"
        secondAge.text = "\((PFUser.current()!.value(forKey: "agePreference") as! [Int])[1])"
    }
    
    @objc func done() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        if firstAge.text == "" || secondAge.text == "" {
            UIApplication.shared.endIgnoringInteractionEvents()
            let alert = UIAlertController(title: "Oops", message: "Please specify a valid range of ages", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if Int(firstAge.text!)! < Int(secondAge.text!)! {
            if Int(firstAge.text!)! > 17 && Int(secondAge.text!)! < 71 {
                let ageRange = [Int(firstAge.text!)!, Int(secondAge.text!)!]
                PFUser.current()?.setValue(ageRange, forKey: "agePreference")
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if success {
                        shouldReloadPeople = true
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
                let alert = UIAlertController(title: "Oops", message: "Your range must be between 18 and 70", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else if Int(firstAge.text!)! > Int(secondAge.text!)! {
            if Int(secondAge.text!)! > 17 && Int(firstAge.text!)! < 71 {
                let ageRange = [Int(secondAge.text!)!, Int(firstAge.text!)!]
                PFUser.current()?.setValue(ageRange, forKey: "agePreference")
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if success {
                        shouldReloadPeople = true
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
                let alert = UIAlertController(title: "Oops", message: "Your range must be between 18 and 70", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            if Int(firstAge.text!)! > 17 && Int(firstAge.text!)! < 71 {
                let ageRange = [Int(firstAge.text!)!, Int(secondAge.text!)!]
                PFUser.current()?.setValue(ageRange, forKey: "agePreference")
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if success {
                        shouldReloadPeople = true
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
                let alert = UIAlertController(title: "Oops", message: "Your range must be between 18 and 70", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstAge {
            secondAge.becomeFirstResponder()
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
