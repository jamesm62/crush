//
//  ViewProfileImage.swift
//  rate
//
//  Created by James McGivern on 1/13/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class ViewProfileImage: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        if !displayProfilePic {
            let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewProfileImage.leftSwipe))
            recognizer.direction = UISwipeGestureRecognizerDirection.left
            imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(recognizer)
            self.view.addGestureRecognizer(recognizer)
            
            let recognizer2 = UISwipeGestureRecognizer(target: self, action: #selector(ViewProfileImage.rightSwipe))
            recognizer2.direction = UISwipeGestureRecognizerDirection.right
            imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(recognizer2)
            self.view.addGestureRecognizer(recognizer2)
        }
        if !isMyProfile {
            let btn = UIButton(type: UIButtonType.system)
            let fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
            let title = NSAttributedString(string: (String(describing: NSString(utf8String: "\u{E810}")!)), attributes: fontStyle)
            btn.setAttributedTitle(title, for: UIControlState.normal)
            btn.tintColor = UIColor.red
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            btn.addTarget(self, action: #selector(ViewProfileImage.report), for: UIControlEvents.touchUpInside)
            let right = UIBarButtonItem(customView: btn)
            self.navigationItem.rightBarButtonItem = right
        }
    }
    
    @objc func leftSwipe() {
        if isMyProfile {
            if photoNumber != (PFUser.current()?.value(forKey: "addedPics") as! [PFFile]).count-1 {
                photoNumber = photoNumber + 1
                imageView.image = myAddedPicsArray[photoNumber]
            }
        } else {
            if !fromNotifications {
                if photoNumber != addedPicsArrayToDisplay.count-1 {
                    photoNumber = photoNumber + 1
                    imageView.image = addedPicsArrayToDisplay[photoNumber]
                }
            } else {
                if photoNumber != notificationsAddedPicsArrayToDisplay.count-1 {
                    photoNumber = photoNumber + 1
                    imageView.image = notificationsAddedPicsArrayToDisplay[photoNumber]
                }
            }
        }
    }
    
    @objc func rightSwipe() {
        if isMyProfile {
            if photoNumber != 0 {
                photoNumber = photoNumber - 1
                imageView.image = myAddedPicsArray[photoNumber]
            }
        } else {
            if photoNumber != 0 {
                photoNumber = photoNumber - 1
                if !fromNotifications {
                    imageView.image = addedPicsArrayToDisplay[photoNumber]
                } else {
                    imageView.image = notificationsAddedPicsArrayToDisplay[photoNumber]
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMyProfile {
            if displayProfilePic {
                imageView.image = myPic
            } else {
                imageView.image = myAddedPicsArray[photoNumber]
            }
        } else {
            if displayProfilePic {
                if !fromNotifications {
                    imageView.image = picToDisplay
                } else {
                    imageView.image = notificationsPicToDisplay
                }
            } else {
                if !fromNotifications {
                    imageView.image = addedPicsArrayToDisplay[photoNumber]
                } else {
                    imageView.image = notificationsAddedPicsArrayToDisplay[photoNumber]
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @objc func report() {
        let alert = UIAlertController(title: "Crush", message: "Are you sure you want to report this photo?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            if !fromNotifications {
                let query = PFQuery(className: "Badges")
                query.whereKey("userId", equalTo: userToDisplay.objectId!)
                query.getFirstObjectInBackground { (badge, error) in
                    if error == nil {
                        if badge != nil {
                            print(1)
                            if !displayProfilePic {
                                print(2)
                                var reports = badge?.value(forKey: "reports") as! [Int]
                                print(3)
                                reports[photoNumber] = reports[photoNumber] + 1
                                print(4)
                                badge?.setValue(reports, forKey: "reports")
                            } else {
                                var profilePicReports = badge?.value(forKey: "profilePicReports") as! Int
                                profilePicReports = profilePicReports + 1
                                badge?.setValue(profilePicReports, forKey: "profilePicReports")
                            }
                            badge?.saveInBackground()
                        }
                    } else {
                        let alert = UIAlertController(title: "Oops", message: "An error occurred. We could not report the photo.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                let query = PFQuery(className: "Badges")
                query.whereKey("userId", equalTo: notificationsUserToDisplay.objectId!)
                query.getFirstObjectInBackground { (badge, error) in
                    if error == nil {
                        if badge != nil {
                            if !displayProfilePic {
                                var reports = badge?.value(forKey: "reports") as! [Int]
                                reports[photoNumber] = reports[photoNumber] + 1
                                badge?.setValue(reports, forKey: "reports")
                            } else {
                                var profilePicReports = badge?.value(forKey: "profilePicReports") as! Int
                                profilePicReports = profilePicReports + 1
                                badge?.setValue(profilePicReports, forKey: "profilePicReports")
                            }
                            badge?.saveInBackground()
                        }
                    } else {
                        let alert = UIAlertController(title: "Oops", message: "An error occurred. We could not report the photo.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true) {
            let btn = UIButton(type: UIButtonType.system)
            let fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
            let title = NSAttributedString(string: (String(describing: NSString(utf8String: "\u{E810}")!)), attributes: fontStyle)
            btn.setAttributedTitle(title, for: UIControlState.normal)
            btn.tintColor = UIColor.gray
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            btn.addTarget(self, action: #selector(ViewProfileImage.report), for: UIControlEvents.touchUpInside)
            let right = UIBarButtonItem(customView: btn)
            self.navigationItem.rightBarButtonItem = right
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
