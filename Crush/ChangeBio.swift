//
//  ChangeBio.swift
//  rate
//
//  Created by James McGivern on 3/5/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class ChangeBio: UIViewController {

    @IBOutlet var bio: UITextView!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        bio.layer.cornerRadius = 10
        
        bio.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        bio.layer.borderWidth = 1
        
        bio.becomeFirstResponder()
        
        right = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(ChangeBio.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ChangeBio.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        right.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bio.text = myBio
    }
    
    @objc func done() {
        if let bio = bio.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if bio.count < 20 {
                let alert = UIAlertController(title: "Oops", message: "Please make your description a little longer", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if bio.count > 150 {
                let alert = UIAlertController(title: "Oops", message: "Please make your description a little shorter", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                PFUser.current()!.setValue(bio, forKey: "bio")
                
                PFUser.current()!.saveInBackground { (success, error) in
                    if success {
                        myBio = bio
                        UserDefaults.standard.setValue(bio, forKey: "bio")
                        
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
