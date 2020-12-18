//
//  ViewImage.swift
//  rate
//
//  Created by James McGivern on 12/24/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit

class ViewImage: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        if !displayProfilePic {
            let btn = UIButton(type: UIButtonType.system)
            let fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
            let title = NSAttributedString(string: (String(describing: NSString(utf8String: "\u{E807}")!)), attributes: fontStyle)
            btn.setAttributedTitle(title, for: UIControlState.normal)
            btn.tintColor = UIColor.black
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            btn.addTarget(self, action: #selector(ViewImage.deletePhoto), for: UIControlEvents.touchUpInside)
            let right = UIBarButtonItem(customView: btn)
            self.navigationItem.rightBarButtonItem = right
            
            let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewImage.leftSwipe))
            recognizer.direction = UISwipeGestureRecognizerDirection.left
            imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(recognizer)
            self.view.addGestureRecognizer(recognizer)
            
            let recognizer2 = UISwipeGestureRecognizer(target: self, action: #selector(ViewImage.rightSwipe))
            recognizer2.direction = UISwipeGestureRecognizerDirection.right
            imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(recognizer2)
            self.view.addGestureRecognizer(recognizer2)
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
    
    @objc func leftSwipe() {
        if photoNumber != addedPics.count-1 {
            photoNumber = photoNumber + 1
            imageView.image = addedPics[photoNumber]
        }
    }
    
    @objc func rightSwipe() {
        if photoNumber != 0 {
            photoNumber = photoNumber - 1
            imageView.image = addedPics[photoNumber]
        }
    }
    
    @objc func deletePhoto() {
        let alert = UIAlertController(title: "Crush", message: "Are you sure you want to remove this photo?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            addedPics.remove(at: addedPics.index(of: self.imageView.image!)!)
            if addedPics.count == 0 {
                self.navigationController?.popViewController(animated: true)
            } else if photoNumber != addedPics.count {
                self.imageView.image = addedPics[photoNumber]
            } else {
                photoNumber = photoNumber - 1
                self.self.imageView.image = addedPics[photoNumber]
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if displayProfilePic {
            imageView.image = pic
        } else {
            imageView.image = addedPics[photoNumber]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
