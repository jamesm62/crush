//
//  ViewMyImage.swift
//  rate
//
//  Created by James McGivern on 3/28/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit

var isChatPhoto = false

class ViewMyImage: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        if !displayProfilePic && !isChatPhoto {
            let btn = UIButton(type: UIButtonType.system)
            let fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
            let title = NSAttributedString(string: (String(describing: NSString(utf8String: "\u{E807}")!)), attributes: fontStyle)
            btn.setAttributedTitle(title, for: UIControlState.normal)
            btn.tintColor = UIColor.black
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            btn.addTarget(self, action: #selector(ViewMyImage.deletePhoto), for: UIControlEvents.touchUpInside)
            let right = UIBarButtonItem(customView: btn)
            self.navigationItem.rightBarButtonItem = right
        
            let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewMyImage.leftSwipe))
            recognizer.direction = UISwipeGestureRecognizerDirection.left
            imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(recognizer)
            self.view.addGestureRecognizer(recognizer)
            
            let recognizer2 = UISwipeGestureRecognizer(target: self, action: #selector(ViewMyImage.rightSwipe))
            recognizer2.direction = UISwipeGestureRecognizerDirection.right
            imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(recognizer2)
            self.view.addGestureRecognizer(recognizer2)
        }
    }
    
    @objc func leftSwipe() {
        if photoNumber != myAddedPicsArray.count-1 {
            photoNumber = photoNumber + 1
            imageView.image = myAddedPicsArray[photoNumber]
        }
    }
    
    @objc func rightSwipe() {
        if photoNumber != 0 {
            photoNumber = photoNumber - 1
            imageView.image = myAddedPicsArray[photoNumber]
        }
    }
    
    @objc func deletePhoto() {
        let alert = UIAlertController(title: "Crush", message: "Are you sure you want to remove this photo?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            let indexOfPic = myAddedPicsArray.index(of: self.imageView.image!)!
            myAddedPicsArray.remove(at: indexOfPic)
            shouldUseFile = false
            myAddedPicsArrayFiles.remove(at: indexOfPic)
            if myAddedPicsArray.count == 0 {
                self.navigationController?.popViewController(animated: true)
            } else if photoNumber != myAddedPicsArray.count {
                self.imageView.image = myAddedPicsArray[photoNumber]
            } else {
                photoNumber = photoNumber - 1
                self.imageView.image = myAddedPicsArray[photoNumber]
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isChatPhoto {
            if displayProfilePic {
                imageView.image = myPic
            } else {
                imageView.image = myAddedPicsArray[photoNumber]
            }
        } else {
            imageView.image = chatPhotoToView
            isChatPhoto = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
