//
//  SearchRadius.swift
//  rate
//
//  Created by James McGivern on 1/2/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class SearchRadius: UIViewController, UITextFieldDelegate {

    @IBOutlet var miles: UITextField!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SearchRadius.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        miles.becomeFirstResponder()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(SearchRadius.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        miles.text = "\(PFUser.current()!.value(forKey: "searchRadius")!)"
    }
    
    @objc func done() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        if miles.text == "" {
            UIApplication.shared.endIgnoringInteractionEvents()
            let alert = UIAlertController(title: "Oops", message: "Please enter a number", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            PFUser.current()?.setValue(Int(miles.text!), forKey: "searchRadius")
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
        }
    }
    
    @objc func touched() {
        self.view.endEditing(true)
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
