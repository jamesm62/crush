//
//  Profile.swift
//  rate
//
//  Created by James McGivern on 12/30/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit
import Parse

var chatUserAccount:PFUser = PFUser()
var shouldUseChatUserAccount = false

class Profile: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var details: UILabel!
    @IBOutlet var school: UILabel!
    @IBOutlet var bio: UILabel!
    @IBOutlet var addedPhotos: UICollectionView!
    
    @IBOutlet var link: UIButton!
    @IBOutlet var chat: UIButton!
    @IBOutlet var ask: UIButton!
    @IBOutlet var more: UIButton!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        link.tintColor = UIColor.black
        chat.tintColor = UIColor.black
        ask.tintColor = UIColor.black
        more.tintColor = UIColor.black
        
        var fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
        var title = NSAttributedString(string: String(describing: NSString(utf8String: "\u{E809}")!), attributes: fontStyle)
        link.setAttributedTitle(title, for: .normal)
        
        fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 23)!]
        title = NSAttributedString(string: String(describing: NSString(utf8String: "\u{E80B}")!), attributes: fontStyle)
        ask.setAttributedTitle(title, for: .normal)
        
        fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
        title = NSAttributedString(string: String(describing: NSString(utf8String: "\u{F4AC}")!), attributes: fontStyle)
        chat.setAttributedTitle(title, for: .normal)
        
        fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
        title = NSAttributedString(string: String(describing: NSString(utf8String: "\u{E811}")!), attributes: fontStyle)
        more.setAttributedTitle(title, for: .normal)
        
        self.navigationItem.title = "Loading..."
        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderColor = UIColor.black.cgColor
        self.profilePic.layer.borderWidth = 2.0
        
        if !fromNotifications {
            profilePic.image = picToDisplay
            
            name.text = "\(nameToDisplay) \(lastToDisplay)"
            
            if distanceToDisplay != nil {
                details.text = "\(distanceToDisplay!) mi, Age \(ageToDisplay), \(genderToDisplay)"
            } else {
                details.text = "Age \(ageToDisplay), \(genderToDisplay)"
            }
            if schoolToDisplay != nil {
                school.text = schoolToDisplay
            } else {
                school.text = "No School"
            }
            
            bio.text = bioToDisplay
            
            self.navigationItem.title = usernameToDisplay
        } else {
            profilePic.image = notificationsPicToDisplay
            
            name.text = "\(notificationsNameToDisplay) \(notificationsLastToDisplay)"
            
            if notificationsDistanceToDisplay != nil {
                details.text = "\(notificationsDistanceToDisplay!) mi, Age \(notificationsAgeToDisplay), \(notificationsGenderToDisplay)"
            } else {
                details.text = "Age \(notificationsAgeToDisplay), \(notificationsGenderToDisplay)"
            }
            
            if notificationsSchoolToDisplay != nil {
                school.text = notificationsSchoolToDisplay
            } else {
                school.text = "No School"
            }
            
            bio.text = notificationsBioToDisplay
            
            self.navigationItem.title = notificationsUsernameToDisplay
        }
        
        let profilePicGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Profile.tapped))
        
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(profilePicGestureRecognizer)
    }
    
    @IBAction func link(_ sender: Any) {
        self.performSegue(withIdentifier: "link", sender: self)
    }
    
    @IBAction func chat(_ sender: Any) {
        if !fromNotifications {
            chatUserAccount = userToDisplay
        } else {
            chatUserAccount = notificationsUserToDisplay
        }
        shouldUseChatUserAccount = true
        
        var tempAllChats:[PFObject] = []
        var tempMainChats:[PFObject] = []
        
        var otherObjectIDs:[String] = []
        
        let query1 = PFQuery(className: "Messages")
        query1.whereKey("from", equalTo: PFUser.current()!)
        
        let query2 = PFQuery(className: "Messages")
        query2.whereKey("to", equalTo: PFUser.current()!)
        
        let mainQuery = PFQuery.orQuery(withSubqueries: [query1, query2])
        mainQuery.limit = 1000
        
        mainQuery.findObjectsInBackground { (messagesList, error) in
            print("found chats")
            if error == nil {
                tempAllChats = messagesList!
                tempAllChats.sort(by: { (chat1, chat2) -> Bool in
                    if chat1.createdAt!.compare(chat2.createdAt!) == ComparisonResult.orderedDescending {
                        return true
                    } else {
                        return false
                    }
                })
                let messages = tempAllChats.reversed()
                print("messages: \(messages)")
                for message in messages {
                    var objectId = ""
                    if (message.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
                        objectId = (message.value(forKey: "to") as! PFUser).objectId!
                    } else {
                        objectId = (message.value(forKey: "from") as! PFUser).objectId!
                    }
                    
                    if !otherObjectIDs.contains(objectId) {
                        otherObjectIDs.append(objectId)
                        tempMainChats.append(message)
                    }
                }
                
                allChats = tempAllChats
                mainChats = tempMainChats
                
                self.performSegue(withIdentifier: "chat", sender: self)
            } else {
                let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func ask(_ sender: Any) {
        self.performSegue(withIdentifier: "ask", sender: self)
    }
    @IBAction func more(_ sender: Any) {
        let alert = UIAlertController(title: "Profile", message: "More options", preferredStyle: UIAlertControllerStyle.actionSheet)
        if !(PFUser.current()!.value(forKey: "blockedUsers") as! [String]).contains(usernameToDisplay) {
            alert.addAction(UIAlertAction(title: "Block user", style: .destructive, handler: { (action) in
                let confirmAlert = UIAlertController(title: "Crush", message: "Are you sure you want to block \(usernameToDisplay)?", preferredStyle: .alert)
                confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    PFUser.current()!.add(usernameToDisplay, forKey: "blockedUsers")
                    PFUser.current()!.saveInBackground()
                }))
                confirmAlert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                self.present(confirmAlert, animated: true, completion: nil)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Unblock user", style: .destructive, handler: { (action) in
                let confirmAlert = UIAlertController(title: "Crush", message: "Are you sure you want to unblock \(usernameToDisplay)?", preferredStyle: .alert)
                confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    PFUser.current()!.remove(usernameToDisplay, forKey: "blockedUsers")
                    PFUser.current()!.saveInBackground()
                }))
                confirmAlert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                self.present(confirmAlert, animated: true, completion: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = more
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func tapped() {
        displayProfilePic = true
        
        self.performSegue(withIdentifier: "viewImage", sender: self)
    }
    
    @objc func rate() {
        performSegue(withIdentifier: "rate", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isMyProfile = false
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        if shouldShowRateButton {
            self.right = UIBarButtonItem(title: "Rate", style: .done, target: self, action: #selector(Profile.rate))
            self.right.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem = self.right
            
            right.isEnabled = false
        }
        
        update()
        
        let query = PFQuery(className: "Rates")
        
        query.whereKey("from", equalTo: PFUser.current()!)
        if !fromNotifications {
            query.whereKey("to", equalTo: userToDisplay)
        } else {
            query.whereKey("to", equalTo: notificationsUserToDisplay)
        }
        if shouldShowRateButton {
            print("here 1")
            query.findObjectsInBackground { (objects, error) in
                print("here 2")
                if error == nil {
                    print("here 3")
                    if let rates = objects {
                        print("here 4")
                        if rates.count > 0 {
                            print("here 5")
                            self.right = UIBarButtonItem(title: "Edit Rate", style: .done, target: self, action: #selector(Profile.rate))
                            self.right.tintColor = UIColor.black
                            self.navigationItem.rightBarButtonItem = self.right
                        } else {
                            print("here 6")
                            self.right = UIBarButtonItem(title: "Rate", style: .done, target: self, action: #selector(Profile.rate))
                            self.right.tintColor = UIColor.black
                            self.navigationItem.rightBarButtonItem = self.right
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = addedPhotos.cellForItem(at: indexPath)
        displayProfilePic = false
        photoNumber = (cell!.value(forKey: "tag") as! Int) - 2
        
        self.performSegue(withIdentifier: "viewImage", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !fromNotifications {
            return addedPicsArrayToDisplay.count
        } else {
            return notificationsAddedPicsArrayToDisplay.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = addedPhotos.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.setValue(indexPath.item+2, forKey: "tag")
        if !fromNotifications {
            (cell.viewWithTag(1) as! UIImageView).image = addedPicsArrayToDisplay[indexPath.item]
        } else {
            (cell.viewWithTag(1) as! UIImageView).image = notificationsAddedPicsArrayToDisplay[indexPath.item]
        }
        
        return cell
    }
    
    func update() {
        let viewWidth = UIScreen.main.bounds.width
        
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = addedPhotos.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
