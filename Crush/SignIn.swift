//
//  SignIn.swift
//  rate
//
//  Created by James McGivern on 12/7/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit
import Parse

class SignIn: UIViewController, UITextFieldDelegate {

    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    override func viewDidLoad() {
        let right = UIBarButtonItem(title: "Login", style: .done, target: self, action: #selector(SignIn.login))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        username.becomeFirstResponder()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(SignIn.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.username.addGestureRecognizer(recognizer)
        self.view.addGestureRecognizer(recognizer)
        
        self.view.gradientLayer.colors = [UIColor.yellow.cgColor, UIColor.cyan.cgColor]
        self.view.gradientLayer.gradient = GradientPoint.bottomLeftTopRight.draw()
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isSecureTextEntry {
            login()
        } else {
            textField.endEditing(true)
            password.becomeFirstResponder()
        }
        return true
    }
    
    @objc func login() {
        if self.username.text == "" || self.password.text == "" {
            let alert = UIAlertController(title: "Oops", message: "Please enter a username and password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.center = self.view.center
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let user = self.username.text?.lowercased()
            let pass = self.password.text?.lowercased()
            
            PFUser.logInWithUsername(inBackground: user!, password: pass!, block: { (user, err) in
                if user != nil {
                    activityIndicator.stopAnimating()
                    shouldUpdate = true
                    justMadeAccount = false
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let storyboard = UIStoryboard(name: "App", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "App") as UIViewController
                    self.present(vc, animated: false, completion: nil)
                } else {
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let alert = UIAlertController(title: "Oops", message: err!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
