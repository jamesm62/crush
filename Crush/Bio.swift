//
//  Bio.swift
//  rate
//
//  Created by James McGivern on 12/15/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit

class Bio: UIViewController {

    @IBOutlet var bio: UITextView!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        bio.layer.cornerRadius = 5
        
        bio.becomeFirstResponder()
        
        right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(Bio.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(Bio.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(recognizer)
        
        self.view.gradientLayer.colors = [UIColor.yellow.cgColor, UIColor.cyan.cgColor]
        self.view.gradientLayer.gradient = GradientPoint.bottomLeftTopRight.draw()
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        right.isEnabled = true
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bio.text = descrip
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
                descrip = bio
                self.performSegue(withIdentifier: "terms", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
