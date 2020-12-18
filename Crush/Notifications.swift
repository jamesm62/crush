//
//  Notifications.swift
//  rate
//
//  Created by James McGivern on 1/11/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse
import CoreData
import ParseLiveQuery

var shouldShowRateButton = true

var alerts:[PFObject] = []

var fromNotifications = false

class Notifications: UITableViewController {
    
    var subscription1: Subscription<PFObject>?
    var subscription2: Subscription<PFObject>?
    
    var query1 = PFQuery(className: "Notifications")
    var query2 = PFQuery(className: "Notifications")
    
    var loadingAnimationView = UIImageView()
    
    var noNotificationsLabel = UILabel()
    var ratePeopleLabel = UILabel()

    override func viewDidLoad() {
        print("viewDidLoad")
        if !offline {
            startLoadingAnimation()
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        
        noNotificationsLabel.isUserInteractionEnabled = false
        ratePeopleLabel.isUserInteractionEnabled = false
        
        self.noNotificationsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 40.0))
        self.ratePeopleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 60.0))
        self.noNotificationsLabel.center = self.tableView.center
        self.ratePeopleLabel.center = self.tableView.center
        self.noNotificationsLabel.center.y -= 20
        self.ratePeopleLabel.center.y += 20
        self.noNotificationsLabel.textAlignment = .center
        self.ratePeopleLabel.textAlignment = .center
        self.noNotificationsLabel.textColor = UIColor.clear
        self.ratePeopleLabel.textColor = UIColor.clear
        self.noNotificationsLabel.font = UIFont.systemFont(ofSize: 25)
        self.ratePeopleLabel.font = UIFont.systemFont(ofSize: 21)
        self.noNotificationsLabel.numberOfLines = 0
        self.ratePeopleLabel.numberOfLines = 0
        self.noNotificationsLabel.text = "No notifications yet"
        self.ratePeopleLabel.text = "Rate people to start hooking up"
        
        self.navigationController!.view.insertSubview(self.noNotificationsLabel, belowSubview: self.navigationController!.navigationBar)
        self.navigationController!.view.insertSubview(self.ratePeopleLabel, belowSubview: self.navigationController!.navigationBar)
        
        if !offline {
            loadNotifications()
        } else {
            noNotificationsLabel.text = "You are offline"
            noNotificationsLabel.textColor = UIColor.lightGray
        }
        
        self.navigationItem.title = "Notifications"
        
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double(Float.leastNormalMagnitude)))
        
        self.tableView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        /*
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        // Helpers
        var result = [NSManagedObject]()
        
        do {
            // Execute Fetch Request
            print("here 1")
            let records = try managedContext?.fetch(fetchRequest)
            print("here 2")
            
            if let records = records as? [NSManagedObject] {
                result = records
            }
            
        } catch {
            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        result.sort { (object1, object2) -> Bool in
            return (object1.value(forKey: "sortNum") as! Int) < (object2.value(forKey: "sortNum") as! Int)
        }
        print("result count \(result.count)")
        
        if result.count > 0 {
            alerts.removeAll()
            for notification in result {
                let firstId = notification.value(forKey: "firstId") as! String
                let firstName = notification.value(forKey: "firstName") as! String
                let firstPic = notification.value(forKey: "firstPic") as! Data
                
                let secondId = notification.value(forKey: "secondId") as! String
                let secondName = notification.value(forKey: "secondName") as! String
                let secondPic = notification.value(forKey: "secondPic") as! Data
                
                let newNotification = PFObject(className: "Notifications")
                
                let firstUser = PFUser()
                let secondUser = PFUser()
                
                firstUser.objectId = firstId
                firstUser["name"] = firstName
                firstUser["pic"] = PFFile(data: firstPic)
                
                secondUser.objectId = secondId
                secondUser["name"] = secondName
                secondUser["pic"] = PFFile(data: secondPic)
                
                newNotification["firstUser"] = firstUser
                newNotification["secondUser"] = secondUser
                
                newNotification["type"] = notification.value(forKey: "type") as! Int
                
                newNotification["interest"] = (notification.value(forKey: "interest") as! NSNumber).doubleValue
                if let interest2 = notification.value(forKey: "interest2") as? NSNumber {
                    newNotification["interest2"] = interest2.doubleValue
                }
                
                if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                    newNotification["firstUserConfirmed"] = firstUserConfirmed
                }
                
                if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                    newNotification["secondUserConfirmed"] = secondUserConfirmed
                }
                
                alerts.append(newNotification)
            }
            
            self.tableView.reloadData()
        }
 */
    }
    
    func loadNotifications() {
        query1 = PFQuery(className: "Notifications")
        query1.whereKey("firstUser", equalTo: PFUser.current()!)
        query2 = PFQuery(className: "Notifications")
        query2.whereKey("secondUser", equalTo: PFUser.current()!)
        
        let mainQuery = PFQuery.orQuery(withSubqueries: [query1, query2])
        mainQuery.limit = 1000
        
        mainQuery.findObjectsInBackground { (notifications, error) in
            if error == nil {
                var notificationsArray = notifications!
                notificationsArray.reverse()
                for notification in notificationsArray {
                    if notification.value(forKey: "type") as! Int == 1 {
                        if (notification.value(forKey: "secondUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
                            notificationsArray.remove(at: notificationsArray.index(of: notification)!)
                        }
                    }
                    if notification.value(forKey: "type") as! Int == 4 && notification.value(forKey: "firstUserConfirmed") == nil {
                        if (notification.value(forKey: "secondUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
                            notificationsArray.remove(at: notificationsArray.index(of: notification)!)
                        }
                    }
                }
                alerts = notificationsArray
                
                if alerts.count == 0 {
                    self.noNotificationsLabel.textColor = UIColor.lightGray
                    self.ratePeopleLabel.textColor = UIColor.lightGray
                } else {
                    self.noNotificationsLabel.textColor = UIColor.clear
                    self.ratePeopleLabel.textColor = UIColor.clear
                }
                notificationsHasDoneInitialLoad = true
                print("initial reloadData")
                self.tableView.reloadData()
                
                self.subscription1 = client.subscribe(self.query1)
                
                self.subscription1!.handleEvent({ (_, event) in
                    if shouldUpdate {
                        switch event {
                        case .created(let object):
                            print("created notification")
                            self.addNotification(object: object)
                        case .deleted(let object):
                            print("deleted notification")
                            self.deleteNotification(object: object)
                        case .entered(let object):
                            print("entered notification")
                            self.addNotification(object: object)
                        case .left(let object):
                            print("left notification")
                            self.deleteNotification(object: object)
                        case .updated(let object):
                            print("updated notification")
                            self.updateNotification(object: object)
                        default:
                            break
                        }
                    }
                })
                
                self.subscription2 = client.subscribe(self.query2)
                
                self.subscription2!.handleEvent({ (_, event) in
                    if shouldUpdate {
                        switch event {
                        case .created(let object):
                            print("created notification")
                            self.addNotification(object: object)
                        case .deleted(let object):
                            print("deleted notification")
                            self.deleteNotification(object: object)
                        case .entered(let object):
                            print("entered notification")
                            self.addNotification(object: object)
                        case .left(let object):
                            print("left notification")
                            self.deleteNotification(object: object)
                        case .updated(let object):
                            print("updated notification")
                            self.updateNotification(object: object)
                        default:
                            break
                        }
                    }
                })
                self.stopLoadingAnimation()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                // Create a background task
                /*
                childContext.perform {
                    // Perform tasks in a background queue
                    self.setNotificationsCoreData() // set up the database for the new game
                }
 */
            } else {
                self.stopLoadingAnimation()
                UIApplication.shared.endIgnoringInteractionEvents()
                let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func addNotification(object: PFObject) {
        print("yeet 1")
        if object.value(forKey: "type") as! Int == 1 {
            if (object.value(forKey: "secondUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
                return
            }
        }
        if object.value(forKey: "type") as! Int == 4 && object.value(forKey: "firstUserConfirmed") == nil {
            if (object.value(forKey: "secondUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
                return
            }
        }
        print("yeet 2")
        self.noNotificationsLabel.textColor = UIColor.clear
        self.ratePeopleLabel.textColor = UIColor.clear
        print("yeet 3")
        alerts.insert(object, at: 0)
        print("yeet 4")
        self.tableView.numberOfRows(inSection: 0)
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
            self.tableView.endUpdates()
        }
        print("yeet 5")
        
        // Create a background task
        /*
        childContext.perform {
            // Perform tasks in a background queue
            self.setNotificationsCoreData() // set up the database for the new game
        }
 */
    }
    
    func deleteNotification(object: PFObject) {
        var indexToDelete:Int?
        var count = 0
        for alert in alerts {
            if alert.objectId! == object.objectId! {
                indexToDelete = count
                alerts.remove(at: count)
            }
            count += 1
        }
        if let index = indexToDelete {
            self.tableView.numberOfRows(inSection: 0)
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
                self.tableView.endUpdates()
            }
        }
        
        // Create a background task
        /*
        childContext.perform {
            // Perform tasks in a background queue
            self.setNotificationsCoreData() // set up the database for the new game
        }
 */
    }
    
    func updateNotification(object: PFObject) {
        var indexToUpdate:Int?
        var count = 0
        for alert in alerts {
            if object.objectId! == alert.objectId! {
                indexToUpdate = count
                alerts[count] = object
            }
            count += 1
        }
        if let index = indexToUpdate {
            print("starting update")
            self.tableView.numberOfRows(inSection: 0)
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                print("ending update")
                self.tableView.endUpdates()
            }
        } else {
            self.addNotification(object: object)
        }
        
        // Create a background task
        /*
        childContext.perform {
            // Perform tasks in a background queue
            self.setNotificationsCoreData() // set up the database for the new game
        }
 */
    }
    
    func setNotificationsCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
        print(request)
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try childContext.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    childContext.delete(result)
                }
            }
        } catch {
            print("There has been an error")
        }
        
        var count = 0
        for notification in alerts {
            let alert = NSEntityDescription.insertNewObject(forEntityName: "Alerts", into: childContext)
            
            alert.setValue(notification.objectId!, forKey: "objectId")
            
            alert.setValue(notification.value(forKey: "type") as! Int, forKey: "type")
            alert.setValue(notification.value(forKey: "interest") as! Double, forKey: "interest")
            
            if let interest2 = notification.value(forKey: "interest2") as? Double {
                alert.setValue(interest2, forKey: "interest2")
            }
            
            if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                alert.setValue(firstUserConfirmed, forKey: "firstUserConfirmed")
            }
            
            if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                alert.setValue(secondUserConfirmed, forKey: "secondUserConfirmed")
            }
            
            let firstUser = notification.value(forKey: "firstUser") as! PFUser
            let secondUser = notification.value(forKey: "secondUser") as! PFUser
            do {
                try firstUser.fetchIfNeeded()
                try secondUser.fetchIfNeeded()
            } catch {
                print("Could not fetch user")
            }
            alert.setValue(firstUser.objectId!, forKey: "firstId")
            alert.setValue(firstUser.value(forKey: "name") as! String, forKey: "firstName")
            do {
                let firstPic = firstUser.value(forKey: "pic") as! PFFile
                let data = try firstPic.getData()
                alert.setValue(NSData(data: data), forKey: "firstPic")
            } catch {
                print("Could not retrieve profilePic from core data")
            }
            
            alert.setValue(secondUser.objectId!, forKey: "secondId")
            print("ay")
            alert.setValue(secondUser.value(forKey: "name") as! String, forKey: "secondName")
            print("ayyy")
            do {
                let secondPic = secondUser.value(forKey: "pic") as! PFFile
                let data = try secondPic.getData()
                alert.setValue(NSData(data: data), forKey: "secondPic")
                print("ayyyyy")
            } catch {
                print("Could not retrieve profilePic from core data")
            }
            
            alert.setValue(count, forKey: "sortNum")
            
            count += 1
        }
        do {
            try childContext.save()
        } catch {
            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        do {
            try managedContext!.save()
        } catch {
            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func startLoadingAnimation() {
        loadingAnimationView = UIImageView()
        loadingAnimationView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width-50, height: (self.tableView.frame.width-50)*0.73)
        loadingAnimationView.center = self.tableView.center
        
        if loadingAnimationImage == nil {
            loadingAnimationView.loadGif(name: "crushLoadingAnimation")
        } else {
            loadingAnimationView.image = loadingAnimationImage!
        }
        
        self.navigationController!.view.insertSubview(loadingAnimationView, belowSubview: self.navigationController!.navigationBar)
    }
    
    func stopLoadingAnimation() {
        loadingAnimationView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        
        if !offline {
            if alerts.count == 0 {
                if notificationsHasDoneInitialLoad {
                    noNotificationsLabel.textColor = UIColor.lightGray
                    ratePeopleLabel.textColor = UIColor.lightGray
                }
            } else {
                self.noNotificationsLabel.textColor = UIColor.clear
                self.ratePeopleLabel.textColor = UIColor.clear
            }
        } else {
            noNotificationsLabel.text = "You are offline"
            noNotificationsLabel.textColor = UIColor.lightGray
            ratePeopleLabel.textColor = UIColor.clear
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let notification = alerts[indexPath.row]
        var user = PFUser()
        if (notification.value(forKey: "firstUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
            user = notification.value(forKey: "secondUser") as! PFUser
        } else {
            user = notification.value(forKey: "firstUser") as! PFUser
        }
        do {
            try user.fetchIfNeeded()
        } catch {
            let alert = UIAlertController(title: "Oops", message: "Couldn't fetch notifications", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        ///////////////////////////////////////////////////////////////////////
        
        notificationsUserToDisplay = user
        
        if useLocationToLoadDistances {
            if let location = user.value(forKey: "location") as? PFGeoPoint {
                let distance = myLocation.distanceInMiles(to: location)
                let distanceAwayRounded = round(10.0 * distance) / 10.0
                notificationsDistanceToDisplay = distanceAwayRounded
            } else {
                notificationsDistanceToDisplay = nil
            }
        } else {
            notificationsDistanceToDisplay = nil
        }
        let pic = user.value(forKey: "pic") as! PFFile
        var pic2 = Data()
        do {
            pic2 = try pic.getData()
        } catch {
            let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        notificationsPicToDisplay = UIImage(data: pic2)!
        notificationsNameToDisplay = user.value(forKey: "name") as! String
        notificationsLastToDisplay = user.value(forKey: "lastName") as! String
        var gender = "male"
        if (user.value(forKey: "gender") as! Bool) {
            gender = "male"
        } else {
            gender = "female"
        }
        notificationsGenderToDisplay = gender
        notificationsBioToDisplay = user.value(forKey: "bio") as! String
        notificationsAgeToDisplay = user.value(forKey: "age") as! Int
        notificationsUsernameToDisplay = user.username!
        
        let photoFiles = user.value(forKey: "addedPics") as! [PFFile]
        
        notificationsAddedPicsArrayToDisplay.removeAll()
        
        for photoFile in photoFiles {
            var pic2 = Data()
            do {
                pic2 = try photoFile.getData()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let photo = UIImage(data: pic2)
            
            notificationsAddedPicsArrayToDisplay.append(photo!)
        }
        
        if let school = user.value(forKey: "school") as? String {
            notificationsSchoolToDisplay = school
        } else {
            notificationsSchoolToDisplay = nil
        }
        
        if let socialMediaAccounts = user.value(forKey: "socialMedia") as? [String] {
            notificationsSocialMediaAccountsArrayToDisplay = socialMediaAccounts
        }
        
        fromNotifications = true
        shouldShowRateButton = false
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        self.performSegue(withIdentifier: "profile", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Get numberOfItemsInSection", section, alerts.count)
        print(alerts)
        return alerts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = alerts[indexPath.row]
        var cell = UITableViewCell()
        if notification.value(forKey: "type") as! Int == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "confirm", for: indexPath)
            (cell.viewWithTag(5) as! UILabel).text = ""
            (cell.viewWithTag(2) as! UILabel).numberOfLines = 0
            
            (cell.viewWithTag(3) as! UIButton).addTarget(self, action: #selector(Notifications.accepted(sender:)), for: .touchDown)
            (cell.viewWithTag(4) as! UIButton).addTarget(self, action: #selector(Notifications.rejected(sender:)), for: .touchDown)
            
            (cell.viewWithTag(1) as! UIImageView).layer.cornerRadius = (cell.viewWithTag(1) as! UIImageView).frame.height/2
            (cell.viewWithTag(1) as! UIImageView).layer.masksToBounds = true
            (cell.viewWithTag(1) as! UIImageView).layer.borderColor = UIColor.black.cgColor
            (cell.viewWithTag(1) as! UIImageView).layer.borderWidth = 1.0
            
            let user = notification.value(forKey: "secondUser") as! PFUser
            do {
                try user.fetchIfNeeded()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't fetch notifications", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
            (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
            
            if (notification.value(forKey: "firstUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
                if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                    if !firstUserConfirmed {
                        if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                            if secondUserConfirmed {
                                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                                (cell.viewWithTag(5) as! UILabel).text = "You said no"
                            } else {
                                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                                (cell.viewWithTag(5) as! UILabel).text = "Both said no"
                            }
                        } else {
                            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                            (cell.viewWithTag(5) as! UILabel).text = "You said no"
                        }
                    }
                } else {
                    (cell.viewWithTag(3) as! UIButton).setImage(UIImage(named: "accept.png"), for: .normal)
                    (cell.viewWithTag(4) as! UIButton).setImage(UIImage(named: "reject.png"), for: .normal)
                    (cell.viewWithTag(3) as! UIButton).addTarget(self, action: #selector(Notifications.accepted(sender:)), for: .touchDown)
                    (cell.viewWithTag(4) as! UIButton).addTarget(self, action: #selector(Notifications.rejected(sender:)), for: .touchDown)
                }
            } else {
                if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                    if !secondUserConfirmed {
                        if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                            if firstUserConfirmed {
                                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                                (cell.viewWithTag(5) as! UILabel).text = "You said no"
                            } else {
                                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                                (cell.viewWithTag(5) as! UILabel).text = "Both said no"
                            }
                        } else {
                            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                            (cell.viewWithTag(5) as! UILabel).text = "You said no"
                        }
                    }
                } else {
                    (cell.viewWithTag(3) as! UIButton).setImage(UIImage(named: "accept.png"), for: .normal)
                    (cell.viewWithTag(4) as! UIButton).setImage(UIImage(named: "reject.png"), for: .normal)
                    (cell.viewWithTag(3) as! UIButton).addTarget(self, action: #selector(Notifications.accepted(sender:)), for: .touchDown)
                    (cell.viewWithTag(4) as! UIButton).addTarget(self, action: #selector(Notifications.rejected(sender:)), for: .touchDown)
                }
            }
            
            let pic = user.value(forKey: "pic") as! PFFile
            var pic2 = Data()
            do {
                pic2 = try pic.getData()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't fetch notifications", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let pic3 = UIImage(data: pic2)!
            (cell.viewWithTag(1) as! UIImageView).image = pic3
            
            switch(notification.value(forKey: "interest") as! Int) {
            case 0: (cell.viewWithTag(2) as! UILabel).text = "Do you want to start a relationship with \(user.value(forKey: "name")!)?"
            case 1: (cell.viewWithTag(2) as! UILabel).text = "Do you want to go on a date with \(user.value(forKey: "name")!)?"
            case 2: (cell.viewWithTag(2) as! UILabel).text = "Do you want to be more than friends with \(user.value(forKey: "name")!)?"
            case 3: (cell.viewWithTag(2) as! UILabel).text = "Do you want to hang out with \(user.value(forKey: "name")!)?"
            case 4: (cell.viewWithTag(2) as! UILabel).text = "Do you want to get to know \(user.value(forKey: "name")!)?"
            case 5: (cell.viewWithTag(2) as! UILabel).text = "Do you want to be friends with \(user.value(forKey: "name")!)?"
            case 6: (cell.viewWithTag(2) as! UILabel).text = "Do you want to meet \(user.value(forKey: "name")!)?"
            default:
                (cell.viewWithTag(2) as! UILabel).text = "error notification"
            }
                
        } else if notification.value(forKey: "type") as! Int == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "confirm", for: indexPath)
            (cell.viewWithTag(5) as! UILabel).text = ""
            (cell.viewWithTag(2) as! UILabel).numberOfLines = 0
            
            var user = PFUser()
            if (notification.value(forKey: "firstUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
                user = notification.value(forKey: "secondUser") as! PFUser
            } else {
                user = notification.value(forKey: "firstUser") as! PFUser
            }
            do {
                try user.fetchIfNeeded()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't fetch notifications", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
            (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
            
            if (notification.value(forKey: "firstUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
                if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                    if firstUserConfirmed {
                        if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                            if !secondUserConfirmed {
                                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                                (cell.viewWithTag(5) as! UILabel).text = "\(user.value(forKey: "name") as! String) said no"
                            }
                        } else {
                            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.blue
                            (cell.viewWithTag(5) as! UILabel).text = "Waiting for \(user.value(forKey: "name") as! String)"
                        }
                    } else {
                        if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                            if secondUserConfirmed {
                                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                                (cell.viewWithTag(5) as! UILabel).text = "You said no"
                            } else {
                                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                                (cell.viewWithTag(5) as! UILabel).text = "Both said no"
                            }
                        } else {
                            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                            (cell.viewWithTag(5) as! UILabel).text = "You said no"
                        }
                    }
                } else {
                    (cell.viewWithTag(3) as! UIButton).setImage(UIImage(named: "accept.png"), for: .normal)
                    (cell.viewWithTag(4) as! UIButton).setImage(UIImage(named: "reject.png"), for: .normal)
                    (cell.viewWithTag(3) as! UIButton).addTarget(self, action: #selector(Notifications.accepted(sender:)), for: .touchDown)
                    (cell.viewWithTag(4) as! UIButton).addTarget(self, action: #selector(Notifications.rejected(sender:)), for: .touchDown)
                }
            } else {
                if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                    if secondUserConfirmed {
                        if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                            if !firstUserConfirmed {
                                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                                (cell.viewWithTag(5) as! UILabel).text = "\(user.value(forKey: "name") as! String) said no"
                            }
                        } else {
                            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.blue
                            (cell.viewWithTag(5) as! UILabel).text = "Waiting for \(user.value(forKey: "name") as! String)"
                        }
                    } else {
                        if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                            if firstUserConfirmed {
                                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                                (cell.viewWithTag(5) as! UILabel).text = "You said no"
                            } else {
                                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                                (cell.viewWithTag(5) as! UILabel).text = "Both said no"
                            }
                        } else {
                            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                            (cell.viewWithTag(5) as! UILabel).text = "You said no"
                        }
                    }
                } else {
                    (cell.viewWithTag(3) as! UIButton).setImage(UIImage(named: "accept.png"), for: .normal)
                    (cell.viewWithTag(4) as! UIButton).setImage(UIImage(named: "reject.png"), for: .normal)
                    (cell.viewWithTag(3) as! UIButton).addTarget(self, action: #selector(Notifications.accepted(sender:)), for: .touchDown)
                    (cell.viewWithTag(4) as! UIButton).addTarget(self, action: #selector(Notifications.rejected(sender:)), for: .touchDown)
                }
            }
            
            (cell.viewWithTag(1) as! UIImageView).layer.cornerRadius = (cell.viewWithTag(1) as! UIImageView).frame.height/2
            (cell.viewWithTag(1) as! UIImageView).layer.masksToBounds = true
            (cell.viewWithTag(1) as! UIImageView).layer.borderColor = UIColor.black.cgColor
            (cell.viewWithTag(1) as! UIImageView).layer.borderWidth = 1.0
            let pic = user.value(forKey: "pic") as! PFFile
            var pic2 = Data()
            do {
                pic2 = try pic.getData()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let pic3 = UIImage(data: pic2)!
            (cell.viewWithTag(1) as! UIImageView).image = pic3
            
            switch(notification.value(forKey: "interest") as! Int) {
            case 0: (cell.viewWithTag(2) as! UILabel).text = "Do you want to start a relationship with \(user.value(forKey: "name")!)?"
            case 1: (cell.viewWithTag(2) as! UILabel).text = "Do you want to go on a date with \(user.value(forKey: "name")!)?"
            case 2: (cell.viewWithTag(2) as! UILabel).text = "Do you want to be more than friends with \(user.value(forKey: "name")!)?"
            case 3: (cell.viewWithTag(2) as! UILabel).text = "Do you want to hang out with \(user.value(forKey: "name")!)?"
            case 4: (cell.viewWithTag(2) as! UILabel).text = "Do you want to get to know \(user.value(forKey: "name")!)?"
            case 5: (cell.viewWithTag(2) as! UILabel).text = "Do you want to be friends with \(user.value(forKey: "name")!)?"
            case 6: (cell.viewWithTag(2) as! UILabel).text = "Do you want to meet \(user.value(forKey: "name")!)?"
            default:
                (cell.viewWithTag(2) as! UILabel).text = "error notification"
            }
        } else if notification.value(forKey: "type") as! Int == 3 {
            print("running 3")
            cell = tableView.dequeueReusableCell(withIdentifier: "notification", for: indexPath)
            (cell.viewWithTag(2) as! UILabel).numberOfLines = 0
            
            let fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 20)!]
            let title = NSAttributedString(string: String(describing: NSString(utf8String: "\u{F4AC}")!), attributes: fontStyle)
            print("making alert icon")
            (cell.viewWithTag(3) as! UILabel).attributedText = title
            (cell.viewWithTag(3) as! UILabel).textColor = UIColor.black
            (cell.viewWithTag(3) as! UILabel).tintColor = UIColor.black
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(Notifications.chat(sender:)))
            print("adding gesture recognizer")
            (cell.viewWithTag(3) as! UILabel).isUserInteractionEnabled = true
            (cell.viewWithTag(3) as! UILabel).addGestureRecognizer(tapRecognizer)
            
            (cell.viewWithTag(1) as! UIImageView).layer.cornerRadius = (cell.viewWithTag(1) as! UIImageView).frame.height/2
            (cell.viewWithTag(1) as! UIImageView).layer.masksToBounds = true
            (cell.viewWithTag(1) as! UIImageView).layer.borderColor = UIColor.black.cgColor
            (cell.viewWithTag(1) as! UIImageView).layer.borderWidth = 1.0
            var user = PFUser()
            if (notification.value(forKey: "firstUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
                user = notification.value(forKey: "secondUser") as! PFUser
            } else {
                user = notification.value(forKey: "firstUser") as! PFUser
            }
            do {
                try user.fetchIfNeeded()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't fetch user", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let pic = user.value(forKey: "pic") as! PFFile
            var pic2 = Data()
            do {
                pic2 = try pic.getData()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let pic3 = UIImage(data: pic2)!
            (cell.viewWithTag(1) as! UIImageView).image = pic3
            switch(notification.value(forKey: "interest") as! Int) {
            case 0: (cell.viewWithTag(2) as! UILabel).text = "You and \(user.value(forKey: "name")!) agreed to start a relationship"
            case 1: (cell.viewWithTag(2) as! UILabel).text = "You and \(user.value(forKey: "name")!) agreed to go on a date"
            case 2: (cell.viewWithTag(2) as! UILabel).text = "You and \(user.value(forKey: "name")!) agreed to be more than friends"
            case 3: (cell.viewWithTag(2) as! UILabel).text = "You and \(user.value(forKey: "name")!) agreed to hang out"
            case 4: (cell.viewWithTag(2) as! UILabel).text = "You and \(user.value(forKey: "name")!) agreed to get to know each other"
            case 5: (cell.viewWithTag(2) as! UILabel).text = "You and \(user.value(forKey: "name")!) agreed to be friends"
            case 6: (cell.viewWithTag(2) as! UILabel).text = "You and \(user.value(forKey: "name")!) agreed to meet each other"
            default:
                (cell.viewWithTag(2) as! UILabel).text = "error notification"
            }
        } else if notification.value(forKey: "type") as! Int == 4 {
            cell = tableView.dequeueReusableCell(withIdentifier: "confirm", for: indexPath)
            (cell.viewWithTag(5) as! UILabel).text = ""
            (cell.viewWithTag(2) as! UILabel).numberOfLines = 0
            
            (cell.viewWithTag(1) as! UIImageView).layer.cornerRadius = (cell.viewWithTag(1) as! UIImageView).frame.height/2
            (cell.viewWithTag(1) as! UIImageView).layer.masksToBounds = true
            (cell.viewWithTag(1) as! UIImageView).layer.borderColor = UIColor.black.cgColor
            (cell.viewWithTag(1) as! UIImageView).layer.borderWidth = 1.0
            
            var user = PFUser()
            if (notification.value(forKey: "firstUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
                user = notification.value(forKey: "secondUser") as! PFUser
            } else {
                user = notification.value(forKey: "firstUser") as! PFUser
            }
            do {
                try user.fetchIfNeeded()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't fetch notifications", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
            (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
            
            if notification.value(forKey: "firstUserConfirmed") != nil {
                if (notification.value(forKey: "firstUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
                    (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                    (cell.viewWithTag(5) as! UILabel).text = "You said no"
                } else {
                    (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                    (cell.viewWithTag(5) as! UILabel).text = "\(user.value(forKey: "name") as! String) said no"
                }
            } else {
                (cell.viewWithTag(3) as! UIButton).setImage(UIImage(named: "accept.png"), for: .normal)
                (cell.viewWithTag(4) as! UIButton).setImage(UIImage(named: "reject.png"), for: .normal)
                (cell.viewWithTag(3) as! UIButton).addTarget(self, action: #selector(Notifications.accepted(sender:)), for: .touchDown)
                (cell.viewWithTag(4) as! UIButton).addTarget(self, action: #selector(Notifications.rejected(sender:)), for: .touchDown)
            }
            
            let pic = user.value(forKey: "pic") as! PFFile
            var pic2 = Data()
            do {
                pic2 = try pic.getData()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let pic3 = UIImage(data: pic2)!
            (cell.viewWithTag(1) as! UIImageView).image = pic3
            
            switch(notification.value(forKey: "interest") as! Int) {
            case 0: (cell.viewWithTag(2) as! UILabel).text = "Do you want to start a relationship with \(user.value(forKey: "name")!)?"
            case 1: (cell.viewWithTag(2) as! UILabel).text = "Do you want to go on a date with \(user.value(forKey: "name")!)?"
            case 2: (cell.viewWithTag(2) as! UILabel).text = "Do you want to be more than friends with \(user.value(forKey: "name")!)?"
            case 3: (cell.viewWithTag(2) as! UILabel).text = "Do you want to hang out with \(user.value(forKey: "name")!)?"
            case 4: (cell.viewWithTag(2) as! UILabel).text = "Do you want to get to know \(user.value(forKey: "name")!)?"
            case 5: (cell.viewWithTag(2) as! UILabel).text = "Do you want to be friends with \(user.value(forKey: "name")!)?"
            case 6: (cell.viewWithTag(2) as! UILabel).text = "Do you want to meet \(user.value(forKey: "name")!)?"
            default:
                (cell.viewWithTag(2) as! UILabel).text = "error notification"
            }
        }
        
        cell.tag = indexPath.row+6
        print(cell.tag)
        return cell
    }
    
    @objc func chat(sender: UITapGestureRecognizer) {
        let cell = sender.view!.superview!.superview as! UITableViewCell
        let notification = alerts[cell.tag-6]
        
        if (notification.value(forKey: "firstUser") as! PFUser).objectId! == PFUser.current()!.objectId! {
            chatUserAccount = notification.value(forKey: "secondUser") as! PFUser
        } else {
            chatUserAccount = notification.value(forKey: "firstUser") as! PFUser
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
    
    @objc func accepted(sender: UIButton) {
        print("running")
        let cell = sender.superview!.superview as! UITableViewCell
        let notification = alerts[cell.tag-6]
        let isFirstUser = (notification.value(forKey: "firstUser") as! PFUser).objectId! == PFUser.current()!.objectId!
        
        let notificationText = (cell.viewWithTag(2) as! UILabel).text!
        let nameFindingArray = notificationText.split(separator: " ")
        var name = nameFindingArray[nameFindingArray.count-1]
        name.removeLast()
        
        if notification.value(forKey: "type") as! Int == 4 {
            notification.setValue(true, forKey: "firstUserConfirmed")
            notification.setValue(3, forKey: "type")
            
            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.green
            (cell.viewWithTag(5) as! UILabel).text = "Confirmed"
            alerts.remove(at: cell.tag-6)
            alerts.insert(notification, at: 0)
            self.tableView.reloadData()
            
            notification.acl?.hasPublicReadAccess = true
            notification.acl?.hasPublicWriteAccess = true
            
            notification.saveInBackground { (success, error) in
                if success {
                    let query = PFQuery(className: "Badges")
                    query.whereKey("userId", equalTo: (notification.value(forKey: "secondUser") as! PFUser).objectId!)
                    
                    query.getFirstObjectInBackground(block: { (badge, error) in
                        if error == nil {
                            if badge != nil {
                                var notificationsBadge = badge!.value(forKey: "notificationsBadge") as! Int
                                notificationsBadge += 1
                                
                                badge!.setValue(notificationsBadge, forKey: "notificationsBadge")
                                
                                badge!.saveInBackground()
                            }
                        }
                    })
                    /*
                    let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                    req.predicate = NSPredicate(format: "objectId = %@", notification.objectId!)
                    req.returnsObjectsAsFaults = false
                    var result = [NSManagedObject]()
                    do {
                        let tempResult = try managedContext!.fetch(req)
                        if let objectToSave = tempResult as? [NSManagedObject] {
                            result = objectToSave
                        }
                    } catch {
                        print("Failed")
                    }
                    if result.count > 0 {
                        let oneObject = result[0]
                        oneObject.setValue(true, forKey: "firstUserConfirmed")
                        oneObject.setValue(3, forKey: "type")
                        
                        do {
                            try managedContext?.save()
                        } catch {
                            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
 */
                    
                    var alert = "error notification"
                    
                    switch(notification.value(forKey: "interest") as! Int) {
                    case 0: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to start a relationship"
                    case 1: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to go on a date"
                    case 2: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to be more than friends"
                    case 3: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to hang out"
                    case 4: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to get to know each other"
                    case 5: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to be friends"
                    case 6: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to meet each other"
                    default:
                        alert = "error notification"
                    }
                    
                    let data = [
                        "badge" : "Increment",
                        "alert" : alert
                        ] as [String : Any]
                    let request = [
                        "data" : data, "userId" : (notification.value(forKey: "secondUser") as! PFUser).objectId!
                        ] as [String : Any]
                    
                    PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
                } else {
                    let alert = UIAlertController(title: "Oops", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            let notificationText = (cell.viewWithTag(2) as! UILabel).text!
            var shouldCheckConfirmation = true
            let nameFindingArray = notificationText.split(separator: " ")
            var name = nameFindingArray[nameFindingArray.count-1]
            var shouldIncreaseBadge = true
            name.removeLast()
            if isFirstUser {
                notification.setValue(true, forKey: "firstUserConfirmed")
                if notification.value(forKey: "type") as! Int == 1 {
                    shouldCheckConfirmation = false
                    notification.setValue(2, forKey: "type")
                    
                    (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                    (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                    (cell.viewWithTag(5) as! UILabel).textColor = UIColor.blue
                    (cell.viewWithTag(5) as! UILabel).text = "Waiting for \(name)"
                }
                if shouldCheckConfirmation {
                    if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                        if secondUserConfirmed {
                            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.green
                            (cell.viewWithTag(5) as! UILabel).text = "Confirmed"
                            notification.setValue(3, forKey: "type")
                            alerts.remove(at: cell.tag-6)
                            alerts.insert(notification, at: 0)
                            self.tableView.moveRow(at: IndexPath(row: cell.tag-6, section: 0), to: IndexPath(row: 0, section: 0))
                        } else {
                            (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                            (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                            (cell.viewWithTag(5) as! UILabel).text = "\(name) said no"
                            shouldIncreaseBadge = false
                        }
                    } else {
                        (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                        (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                        
                        (cell.viewWithTag(5) as! UILabel).textColor = UIColor.blue
                        (cell.viewWithTag(5) as! UILabel).text = "Waiting for \(name)"
                        shouldIncreaseBadge = false
                    }
                } else {
                    print("didn't check confirmation")
                }
                print("saving in background")
                
                notification.acl?.hasPublicReadAccess = true
                notification.acl?.hasPublicWriteAccess = true
                
                notification.saveInBackground(block: { (success, error) in
                    if success {
                        if shouldIncreaseBadge {
                            let query = PFQuery(className: "Badges")
                            query.whereKey("userId", equalTo: (notification.value(forKey: "secondUser") as! PFUser).objectId!)
                            
                            query.getFirstObjectInBackground(block: { (badge, error) in
                                if error == nil {
                                    if badge != nil {
                                        var notificationsBadge = badge!.value(forKey: "notificationsBadge") as! Int
                                        notificationsBadge += 1
                                        
                                        badge!.setValue(notificationsBadge, forKey: "notificationsBadge")
                                        
                                        badge!.saveInBackground()
                                    }
                                }
                            })
                        }
                        /*
                        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                        req.predicate = NSPredicate(format: "objectId = %@", notification.objectId!)
                        req.returnsObjectsAsFaults = false
                        var result = [NSManagedObject]()
                        do {
                            let tempResult = try managedContext!.fetch(req)
                            if let objectToSave = tempResult as? [NSManagedObject] {
                                result = objectToSave
                            }
                        } catch {
                            print("Failed")
                        }
                        if result.count > 0 {
                            let oneObject = result[0]
                            oneObject.setValue(true, forKey: "firstUserConfirmed")
                            oneObject.setValue(notification.value(forKey: "type") as! Int, forKey: "type")
                            
                            do {
                                try managedContext?.save()
                            } catch {
                                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
 */
                        
                        var alert = "error notification"
                        
                        if (notification.value(forKey: "type") as! Int) != 1, (notification.value(forKey: "type") as! Int) != 2 {
                            switch(notification.value(forKey: "interest") as! Int) {
                            case 0: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to start a relationship"
                            case 1: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to go on a date"
                            case 2: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to be more than friends"
                            case 3: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to hang out"
                            case 4: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to get to know each other"
                            case 5: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to be friends"
                            case 6: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to meet each other"
                            default:
                                alert = "error notification"
                            }
                        } else {
                            switch(notification.value(forKey: "interest") as! Int) {
                            case 0: alert = "Do you want to start a relationship with \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 1: alert = "Do you want to go on a date with \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 2: alert = "Do you want to be more than friends with \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 3: alert = "Do you want to hang out with \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 4: alert = "Do you want to get to know \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 5: alert = "Do you want to be friends with \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 6: alert = "Do you want to meet \(PFUser.current()?.value(forKey: "name") as! String)?"
                            default:
                                alert = "error notification"
                            }
                        }
                        
                        let data = [
                            "badge" : "Increment",
                            "alert" : alert
                            ] as [String : Any]
                        let request = [
                            "data" : data, "userId" : (notification.value(forKey: "secondUser") as! PFUser).objectId!
                            ] as [String : Any]
                        
                        PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
                    } else {
                        let alert = UIAlertController(title: "Oops", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            } else {
                notification.setValue(true, forKey: "secondUserConfirmed")
                let notificationText = (cell.viewWithTag(2) as! UILabel).text!
                var shouldCheckConfirmation = true
                let nameFindingArray = notificationText.split(separator: " ")
                var name = nameFindingArray[nameFindingArray.count-1]
                var shouldIncreaseBadge = true
                name.removeLast()
                if notification.value(forKey: "type") as! Int == 1 {
                    shouldCheckConfirmation = false
                    notification.setValue(2, forKey: "type")
                    
                    (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                    (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                    (cell.viewWithTag(5) as! UILabel).textColor = UIColor.blue
                    (cell.viewWithTag(5) as! UILabel).text = "Waiting for \(name)"
                }
                if shouldCheckConfirmation {
                    if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                        if firstUserConfirmed {
                            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.green
                            (cell.viewWithTag(5) as! UILabel).text = "Confirmed"
                            notification.setValue(3, forKey: "type")
                            alerts.remove(at: cell.tag-6)
                            alerts.insert(notification, at: 0)
                            self.tableView.reloadData()
                        } else {
                            (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                            (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                            
                            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                            (cell.viewWithTag(5) as! UILabel).text = "\(name) said no"
                            shouldIncreaseBadge = false
                        }
                    } else {
                        (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                        (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                        
                        (cell.viewWithTag(5) as! UILabel).textColor = UIColor.blue
                        (cell.viewWithTag(5) as! UILabel).text = "Waiting for \(name)"
                        shouldIncreaseBadge = false
                    }
                } else {
                    print("didn't check confirmation")
                }
                
                notification.acl?.hasPublicReadAccess = true
                notification.acl?.hasPublicWriteAccess = true
                
                notification.saveInBackground(block: { (success, error) in
                    if success {
                        if shouldIncreaseBadge {
                            let query = PFQuery(className: "Badges")
                            query.whereKey("userId", equalTo: (notification.value(forKey: "firstUser") as! PFUser).objectId!)
                            
                            query.getFirstObjectInBackground(block: { (badge, error) in
                                if error == nil {
                                    if badge != nil {
                                        var notificationsBadge = badge!.value(forKey: "notificationsBadge") as! Int
                                        notificationsBadge += 1
                                        
                                        badge!.setValue(notificationsBadge, forKey: "notificationsBadge")
                                        
                                        badge!.saveInBackground()
                                    }
                                }
                            })
                        }
                        /*
                        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                        req.predicate = NSPredicate(format: "objectId = %@", notification.objectId!)
                        req.returnsObjectsAsFaults = false
                        var result = [NSManagedObject]()
                        do {
                            let tempResult = try managedContext!.fetch(req)
                            if let objectToSave = tempResult as? [NSManagedObject] {
                                result = objectToSave
                            }
                        } catch {
                            print("Failed")
                        }
                        if result.count > 0 {
                            let oneObject = result[0]
                            oneObject.setValue(true, forKey: "secondUserConfirmed")
                            oneObject.setValue(notification.value(forKey: "type") as! Int, forKey: "type")
                            
                            do {
                                try managedContext?.save()
                            } catch {
                                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
 */
                        
                        var alert = "error notification"
                        
                        if (notification.value(forKey: "type") as! Int) != 1, (notification.value(forKey: "type") as! Int) != 2 {
                            switch(notification.value(forKey: "interest") as! Int) {
                            case 0: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to start a relationship"
                            case 1: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to go on a date"
                            case 2: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to be more than friends"
                            case 3: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to hang out"
                            case 4: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to get to know each other"
                            case 5: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to be friends"
                            case 6: alert = "You and \(PFUser.current()?.value(forKey: "name") as! String) agreed to meet each other"
                            default:
                                alert = "error notification"
                            }
                        } else {
                            switch(notification.value(forKey: "interest") as! Int) {
                            case 0: alert = "Do you want to start a relationship with \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 1: alert = "Do you want to go on a date with \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 2: alert = "Do you want to be more than friends with \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 3: alert = "Do you want to hang out with \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 4: alert = "Do you want to get to know \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 5: alert = "Do you want to be friends with \(PFUser.current()?.value(forKey: "name") as! String)?"
                            case 6: alert = "Do you want to meet \(PFUser.current()?.value(forKey: "name") as! String)?"
                            default:
                                alert = "error notification"
                            }
                        }
                        
                        let data = [
                            "badge" : "Increment",
                            "alert" : alert
                            ] as [String : Any]
                        let request = [
                            "data" : data, "userId" : (notification.value(forKey: "secondUser") as! PFUser).objectId!
                            ] as [String : Any]
                        
                        PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
                    } else {
                        let alert = UIAlertController(title: "Oops", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    @objc func rejected(sender: UIButton) {
        print("running")
        let cell = sender.superview!.superview as! UITableViewCell
        let notification = alerts[cell.tag-6]
        let isFirstUser = (notification.value(forKey: "firstUser") as! PFUser).objectId! == PFUser.current()!.objectId!
        
        if notification.value(forKey: "type") as! Int == 4 {
            notification.setValue(false, forKey: "firstUserConfirmed")
            
            (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
            (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
            (cell.viewWithTag(5) as! UILabel).text = "You said no"
            
            notification.acl?.hasPublicReadAccess = true
            notification.acl?.hasPublicWriteAccess = true
            
            notification.saveInBackground { (success, error) in
                if success {
                    /*
                    let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                    req.predicate = NSPredicate(format: "objectId = %@", notification.objectId!)
                    req.returnsObjectsAsFaults = false
                    var result = [NSManagedObject]()
                    do {
                        let tempResult = try managedContext!.fetch(req)
                        if let objectToSave = tempResult as? [NSManagedObject] {
                            result = objectToSave
                        }
                    } catch {
                        print("Failed")
                    }
                    if result.count > 0 {
                        let oneObject = result[0]
                        oneObject.setValue(false, forKey: "firstUserConfirmed")
                        
                        do {
                            try managedContext?.save()
                        } catch {
                            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
 */
                    print("saved notification")
                } else {
                    let alert = UIAlertController(title: "Oops", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            if isFirstUser {
                print("setting firstUserConfirmed")
                notification.setValue(false, forKey: "firstUserConfirmed")
                if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                    if secondUserConfirmed {
                        let notificationText = (cell.viewWithTag(2) as! UILabel).text!
                        
                        let nameFindingArray = notificationText.split(separator: " ")
                        var name = nameFindingArray[nameFindingArray.count-1]
                        name.removeLast()
                        
                        (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                        (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                        (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                        (cell.viewWithTag(5) as! UILabel).text = "You said no"
                    } else {
                        let notificationText = (cell.viewWithTag(2) as! UILabel).text!
                        
                        let nameFindingArray = notificationText.split(separator: " ")
                        var name = nameFindingArray[nameFindingArray.count-1]
                        name.removeLast()
                        
                        (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                        (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                        (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                        (cell.viewWithTag(5) as! UILabel).text = "Both said no"
                    }
                } else {
                    (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                    (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                    let notificationText = (cell.viewWithTag(2) as! UILabel).text!
                    
                    let nameFindingArray = notificationText.split(separator: " ")
                    var name = nameFindingArray[nameFindingArray.count-1]
                    name.removeLast()
                    
                    (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                    (cell.viewWithTag(5) as! UILabel).text = "You said no"
                }
                print("saving in background")
                
                notification.acl?.hasPublicReadAccess = true
                notification.acl?.hasPublicWriteAccess = true
                
                notification.saveInBackground(block: { (success, error) in
                    if success {
                        /*
                        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                        req.predicate = NSPredicate(format: "objectId = %@", notification.objectId!)
                        req.returnsObjectsAsFaults = false
                        var result = [NSManagedObject]()
                        do {
                            let tempResult = try managedContext!.fetch(req)
                            if let objectToSave = tempResult as? [NSManagedObject] {
                                result = objectToSave
                            }
                        } catch {
                            print("Failed")
                        }
                        if result.count > 0 {
                            let oneObject = result[0]
                            oneObject.setValue(true, forKey: "firstUserConfirmed")
                            
                            do {
                                try managedContext?.save()
                            } catch {
                                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
 */
                        print("saved in background")
                    } else {
                        let alert = UIAlertController(title: "Oops", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            } else {
                notification.setValue(false, forKey: "secondUserConfirmed")
                if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                    if firstUserConfirmed {
                        (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                        (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                        let notificationText = (cell.viewWithTag(2) as! UILabel).text!
                        
                        let nameFindingArray = notificationText.split(separator: " ")
                        var name = nameFindingArray[nameFindingArray.count-1]
                        name.removeLast()
                        
                        (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                        (cell.viewWithTag(5) as! UILabel).text = "You said no"
                    } else {
                        (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                        (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                        let notificationText = (cell.viewWithTag(2) as! UILabel).text!
                        
                        let nameFindingArray = notificationText.split(separator: " ")
                        var name = nameFindingArray[nameFindingArray.count-1]
                        name.removeLast()
                        
                        (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
                        (cell.viewWithTag(5) as! UILabel).text = "Both said no"
                    }
                } else {
                    (cell.viewWithTag(3) as! UIButton).setImage(UIImage(), for: .normal)
                    (cell.viewWithTag(4) as! UIButton).setImage(UIImage(), for: .normal)
                    let notificationText = (cell.viewWithTag(2) as! UILabel).text!
                    
                    let nameFindingArray = notificationText.split(separator: " ")
                    var name = nameFindingArray[nameFindingArray.count-1]
                    name.removeLast()
                    
                    (cell.viewWithTag(5) as! UILabel).textColor = UIColor.blue
                    (cell.viewWithTag(5) as! UILabel).text = "You said no"
                }
                
                notification.acl?.hasPublicReadAccess = true
                notification.acl?.hasPublicWriteAccess = true
                
                notification.saveInBackground(block: { (success, error) in
                    if success {
                        /*
                        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                        req.predicate = NSPredicate(format: "objectId = %@", notification.objectId!)
                        req.returnsObjectsAsFaults = false
                        var result = [NSManagedObject]()
                        do {
                            let tempResult = try managedContext!.fetch(req)
                            if let objectToSave = tempResult as? [NSManagedObject] {
                                result = objectToSave
                            }
                        } catch {
                            print("Failed")
                        }
                        if result.count > 0 {
                            let oneObject = result[0]
                            oneObject.setValue(true, forKey: "secondUserConfirmed")
                            
                            do {
                                try managedContext?.save()
                            } catch {
                                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
 */
                        print("saved in background")
                    } else {
                        let alert = UIAlertController(title: "Oops", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.noNotificationsLabel.textColor = UIColor.clear
        self.ratePeopleLabel.textColor = UIColor.clear
    }
}
