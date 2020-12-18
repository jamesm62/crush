//
//  Rate.swift
//  Crush
//
//  Created by James McGivern on 1/11/18.
//  Copyright © 2018 Crush. All rights reserved.
//

import UIKit
import Parse
import CoreData

var fromMyRates = false

var myRateToModify = PFObject(className: "Rates")

var picForModifyingRate = UIImage(named: "profilePic.png")!
var nameForModifyingRate = ""
var lastForModifyingRate = ""

class Rate: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 8
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(row) {
        case 0: return "Would start a relationship"
        case 1: return "Would go on a date"
        case 2: return "Would be more than friends"
        case 3: return "Would hang out"
        case 4: return "Would get to know"
        case 5: return "Would be friends"
        case 6: return "Would meet"
        case 7: return "Not interested"
        default: return ""
        }
    }
    
    @IBOutlet var userPic: UIImageView!
    @IBOutlet var thoughtsPicker: UIPickerView!
    
    var originalInterest = -1
    
    var right = UIBarButtonItem()
    
    var rateToModify = PFObject(className: "Rates")
    var shouldModifyRate = false
    
    var localFromMyRates = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.thoughtsPicker.selectRow(3, inComponent: 0, animated: true)
        if !fromMyRates {
            let query = PFQuery(className: "Rates")
            
            query.whereKey("from", equalTo: PFUser.current()!)
            if !fromNotifications {
                query.whereKey("to", equalTo: userToDisplay)
            } else {
                query.whereKey("to", equalTo: notificationsUserToDisplay)
            }
            
            query.getFirstObjectInBackground { (rate, error) in
                if error == nil {
                    if rate != nil {
                        self.originalInterest = rate!.value(forKey: "interestLevel") as! Int
                        self.thoughtsPicker.selectRow(self.originalInterest, inComponent: 0, animated: false)
                        self.rateToModify = rate!
                        self.shouldModifyRate = true
                    }
                }
            }
        } else {
            localFromMyRates = true
            fromMyRates = false
            
            let rate = myRateToModify
            
            self.originalInterest = rate.value(forKey: "interestLevel") as! Int
            self.thoughtsPicker.selectRow(self.originalInterest, inComponent: 0, animated: false)
            self.rateToModify = rate
            self.shouldModifyRate = true
        }
    }
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(Rate.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        userPic.layer.cornerRadius = userPic.frame.height/2
        userPic.layer.masksToBounds = true
        userPic.layer.borderColor = UIColor.black.cgColor
        userPic.layer.borderWidth = 2.0
        if !localFromMyRates && !fromMyRates {
            if !fromNotifications {
                userPic.image = picToDisplay
            } else {
                userPic.image = notificationsPicToDisplay
            }
        } else {
            userPic.image = picForModifyingRate
        }
    }
    
    @objc func done() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let interestLevel = thoughtsPicker.selectedRow(inComponent: 0)
        
        print("1")
        
        if interestLevel != originalInterest {
            print("2")
            if shouldModifyRate {
                rateToModify.setValue(interestLevel, forKey: "interestLevel")
                print("3")
            } else {
                rateToModify = PFObject(className: "Rates")
                
                rateToModify.setValue(PFUser.current(), forKey: "from")
                if !fromNotifications {
                    rateToModify.setValue(userToDisplay, forKey: "to")
                } else {
                    rateToModify.setValue(notificationsUserToDisplay, forKey: "to")
                }
                rateToModify.setValue(interestLevel, forKey: "interestLevel")
            }
            
            print("4")
            
            rateToModify.acl?.hasPublicReadAccess = true
            rateToModify.acl?.hasPublicWriteAccess = true
            
            rateToModify.saveInBackground(block: { (success, error) in
                print("5")
                if success {
                    print("6")
                    var foundRate = false
                    var indexOfFoundRate = 0
                    for rate in rates {
                        if rate.objectId! == self.rateToModify.objectId! {
                            indexOfFoundRate = rates.index(of: rate)!
                            foundRate = true
                        }
                    }
                    if foundRate {
                        print("7")
                        rates.remove(at: indexOfFoundRate)
                        rateValues.remove(at: indexOfFoundRate)
                        ratePics.remove(at: indexOfFoundRate)
                        rateFirsts.remove(at: indexOfFoundRate)
                        rateLasts.remove(at: indexOfFoundRate)
                    }
                    
                    print("8")
                    
                    rates.insert(self.rateToModify, at: 0)
                    rates.sort(by: { (rate1, rate2) -> Bool in
                        return (rate1.value(forKey: "interestLevel") as! Int) < (rate2.value(forKey: "interestLevel") as! Int)
                    })
                    let indexOfRate = rates.index(of: self.rateToModify)!
                    if !self.localFromMyRates {
                        if !fromNotifications {
                            rateValues.insert(interestLevel, at: indexOfRate)
                            ratePics.insert(picToDisplay, at: indexOfRate)
                            rateFirsts.insert(nameToDisplay, at: indexOfRate)
                            rateLasts.insert(lastToDisplay, at: indexOfRate)
                        } else {
                            rateValues.insert(interestLevel, at: indexOfRate)
                            ratePics.insert(notificationsPicToDisplay, at: indexOfRate)
                            rateFirsts.insert(notificationsNameToDisplay, at: indexOfRate)
                            rateLasts.insert(notificationsLastToDisplay, at: indexOfRate)
                        }
                    } else {
                        print("9")
                        rateValues.insert(interestLevel, at: indexOfRate)
                        ratePics.insert(picForModifyingRate, at: indexOfRate)
                        rateFirsts.insert(nameForModifyingRate, at: indexOfRate)
                        rateLasts.insert(lastForModifyingRate, at: indexOfRate)
                    }
                    
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let query = PFQuery(className: "Rates")
                    
                    query.whereKey("to", equalTo: PFUser.current()!)
                    if !self.localFromMyRates {
                        if !fromNotifications {
                            query.whereKey("from", equalTo: userToDisplay)
                        } else {
                            query.whereKey("from", equalTo: notificationsUserToDisplay)
                        }
                    } else {
                        query.whereKey("from", equalTo: self.rateToModify.value(forKey: "to") as! PFUser)
                    }
                    
                    if interestLevel != 7 {
                        print("10")
                        query.getFirstObjectInBackground(block: { (rate, error) in
                            print("11")
                            if error == nil {
                                print("12")
                                if rate != nil {
                                    print("13")
                                    let interest = rate!.value(forKey: "interestLevel") as! Int
                                    
                                    if interestLevel != self.originalInterest {
                                        print("14")
                                        if interestLevel != 7 {
                                            print("15")
                                            if interest != 7 {
                                                print("16")
                                                print("here 2")
                                                let query = PFQuery(className: "Notifications")
                                                
                                                query.whereKey("firstUser", equalTo: PFUser.current()!)
                                                if !self.localFromMyRates {
                                                    if !fromNotifications {
                                                        query.whereKey("secondUser", equalTo: userToDisplay)
                                                    } else {
                                                        query.whereKey("secondUser", equalTo: notificationsUserToDisplay)
                                                    }
                                                } else {
                                                    query.whereKey("secondUser", equalTo: self.rateToModify.value(forKey: "to") as! PFUser)
                                                }
                                                
                                                let query2 = PFQuery(className: "Notifications")
                                                
                                                query2.whereKey("secondUser", equalTo: PFUser.current()!)
                                                if !self.localFromMyRates {
                                                    if !fromNotifications {
                                                        query2.whereKey("firstUser", equalTo: userToDisplay)
                                                    } else {
                                                        query2.whereKey("firstUser", equalTo: notificationsUserToDisplay)
                                                    }
                                                } else {
                                                    query.whereKey("secondUser", equalTo: self.rateToModify.value(forKey: "to") as! PFUser)
                                                }
                                                
                                                let mainQuery = PFQuery.orQuery(withSubqueries: [query, query2])
                                                mainQuery.whereKey("type", notEqualTo: 0)
                                                
                                                mainQuery.findObjectsInBackground(block: { (notifications, error) in
                                                    if error == nil {
                                                        var notification:PFObject
                                                        if notifications!.count != 0 {
                                                            if notifications!.reversed()[0].value(forKey: "type") as! Int != 3 {
                                                                notification = notifications!.reversed()[0]
                                                                let notificationType = notification.value(forKey: "type") as! Int
                                                                let currentUserWasHigher = (notification.value(forKey: "interest") as! Int) == interest
                                                                print("Their interest \(interest)")
                                                                print("My interest \(interestLevel)")
                                                                var shouldSendNotification = false
                                                                var shouldSendMyNotification = false
                                                                
                                                                if interest > interestLevel {
                                                                    shouldSendMyNotification = true
                                                                    if !currentUserWasHigher || notificationType == 2 {
                                                                        notification.setValue(PFUser.current()!, forKey: "firstUser")
                                                                        if !self.localFromMyRates {
                                                                            if !fromNotifications {
                                                                                notification.setValue(userToDisplay, forKey: "secondUser")
                                                                            } else {
                                                                                notification.setValue(notificationsUserToDisplay, forKey: "secondUser")
                                                                            }
                                                                        } else {
                                                                            notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "secondUser")
                                                                        }
                                                                        
                                                                        notification.remove(forKey: "firstUserConfirmed")
                                                                        notification.remove(forKey: "secondUserConfirmed")
                                                                        
                                                                        notification.setValue(1, forKey: "type")
                                                                        notification.setValue(interest, forKey: "interest")
                                                                    } else {
                                                                        notification.setValue(interest, forKey: "interest")
                                                                        notification.remove(forKey: "firstUserConfirmed")
                                                                    }
                                                                } else if interestLevel > interest {
                                                                    shouldSendNotification = true
                                                                    if currentUserWasHigher || notificationType == 2 {
                                                                        shouldSendNotification = true
                                                                        notification.setValue(PFUser.current()!, forKey: "secondUser")
                                                                        if !self.localFromMyRates {
                                                                            if !fromNotifications {
                                                                                notification.setValue(userToDisplay, forKey: "firstUser")
                                                                            } else {
                                                                                notification.setValue(notificationsUserToDisplay, forKey: "firstUser")
                                                                            }
                                                                        } else {
                                                                            notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "firstUser")
                                                                        }
                                                                        
                                                                        notification.remove(forKey: "firstUserConfirmed")
                                                                        notification.remove(forKey: "secondUserConfirmed")
                                                                        
                                                                        print("still running 3")
                                                                        
                                                                        notification.setValue(1, forKey: "type")
                                                                        print("I am setting interestLevel to \(interestLevel)")
                                                                        notification.setValue(interestLevel, forKey: "interest")
                                                                    } else {
                                                                        shouldSendNotification = true
                                                                        notification.setValue(interestLevel, forKey: "interest")
                                                                        notification.remove(forKey: "firstUserConfirmed")
                                                                    }
                                                                } else {
                                                                    shouldSendNotification = true
                                                                    shouldSendMyNotification = true
                                                                    print("runnning 3")
                                                                    notification.remove(forKey: "firstUserConfirmed")
                                                                    notification.remove(forKey: "secondUserConfirmed")
                                                                    
                                                                    notification.setValue(2, forKey: "type")
                                                                    notification.setValue(interestLevel, forKey: "interest")
                                                                }
                                                                
                                                                notification.acl?.hasPublicReadAccess = true
                                                                notification.acl?.hasPublicWriteAccess = true
                                                                
                                                                notification.saveInBackground(block: { (success, error) in
                                                                    if success {
                                                                        if shouldSendMyNotification {
                                                                            let query = PFQuery(className: "Badges")
                                                                            query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
                                                                            
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
                                                                        if shouldSendNotification {
                                                                            let query = PFQuery(className: "Badges")
                                                                            if !self.localFromMyRates {
                                                                                if !fromNotifications {
                                                                                    query.whereKey("userId", equalTo: userToDisplay.objectId!)
                                                                                } else {
                                                                                    query.whereKey("userId", equalTo: notificationsUserToDisplay.objectId!)
                                                                                }
                                                                            } else {
                                                                                query.whereKey("userId", equalTo: (self.rateToModify.value(forKey: "to") as! PFUser).objectId!)
                                                                            }
                                                                            
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
                                                                            let alrt = NSEntityDescription.insertNewObject(forEntityName: "Alerts", into: managedContext!)
                                                                            
                                                                            alrt.setValue(notification.objectId!, forKey: "objectId")
                                                                            
                                                                            alrt.setValue(notification.value(forKey: "type") as! Int, forKey: "type")
                                                                            alrt.setValue(notification.value(forKey: "interest") as! Double, forKey: "interest")
                                                                            
                                                                            if let interest2 = notification.value(forKey: "interest2") as? Double {
                                                                                alrt.setValue(interest2, forKey: "interest2")
                                                                            }
                                                                            
                                                                            if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                                                                                alrt.setValue(firstUserConfirmed, forKey: "firstUserConfirmed")
                                                                            }
                                                                            
                                                                            if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                                                                                alrt.setValue(secondUserConfirmed, forKey: "secondUserConfirmed")
                                                                            }
                                                                            
                                                                            let firstUser = notification.value(forKey: "firstUser") as! PFUser
                                                                            let secondUser = notification.value(forKey: "secondUser") as! PFUser
                                                                            do {
                                                                                try firstUser.fetchIfNeeded()
                                                                                try secondUser.fetchIfNeeded()
                                                                            } catch {
                                                                                print("Could not fetch user")
                                                                            }
                                                                            print("yo wassup")
                                                                            alrt.setValue(firstUser.objectId!, forKey: "firstId")
                                                                            print("now we up here")
                                                                            alrt.setValue(firstUser.value(forKey: "name") as! String, forKey: "firstName")
                                                                            print("there we go")
                                                                            do {
                                                                                let firstPic = firstUser.value(forKey: "pic") as! PFFile
                                                                                let data = try firstPic.getData()
                                                                                alrt.setValue(NSData(data: data), forKey: "firstPic")
                                                                                print("gettin warmer")
                                                                            } catch {
                                                                                print("Could not retrieve profilePic from core data")
                                                                            }
                                                                            
                                                                            print("come on baby")
                                                                            
                                                                            alrt.setValue(secondUser.objectId!, forKey: "secondId")
                                                                            print("ay")
                                                                            alrt.setValue(secondUser.value(forKey: "name") as! String, forKey: "secondName")
                                                                            print("ayyy")
                                                                            do {
                                                                                let secondPic = secondUser.value(forKey: "pic") as! PFFile
                                                                                let data = try secondPic.getData()
                                                                                alrt.setValue(NSData(data: data), forKey: "secondPic")
                                                                                print("ayyyyy")
                                                                            } catch {
                                                                                print("Could not retrieve profilePic from core data")
                                                                            }
                                                                            
                                                                            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                                                                            
                                                                            fetchRequest.returnsObjectsAsFaults = false
                                                                            
                                                                            // Helpers
                                                                            var result = [NSManagedObject]()
                                                                            
                                                                            do {
                                                                                // Execute Fetch Request
                                                                                let records = try managedContext?.fetch(fetchRequest)
                                                                                
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
                                                                            
                                                                            alrt.setValue(result[0].value(forKey: "sortNum") as! Int, forKey: "sortNum")
                                                                            */
                                                                            
                                                                            var alert = "error notification"
                                                                            var interestValue = 0
                                                                            if interestLevel > interest {
                                                                                interestValue = interestLevel
                                                                            } else {
                                                                                interestValue = interest
                                                                            }
                                                                            
                                                                            switch(interestValue) {
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
                                                                            
                                                                            let data = [
                                                                                "badge" : "Increment",
                                                                                "alert" : alert
                                                                                ] as [String : Any]
                                                                            let request = [
                                                                                "data" : data, "userId" : (notification.value(forKey: "secondUser") as! PFUser).objectId!
                                                                                ] as [String : Any]
                                                                            
                                                                            PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
                                                                        }
                                                                    } else {
                                                                        let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                                        self.present(alert, animated: true, completion: nil)
                                                                    }
                                                                })
                                                            } else {
                                                                let checkNotification = notifications!.reversed()[0]
                                                                if (checkNotification.value(forKey: "interest") as! Int) > interestLevel && (checkNotification.value(forKey: "interest") as! Int) > interest {
                                                                    notification = PFObject(className: "Notifications")
                                                                    notification.acl!.hasPublicWriteAccess = true
                                                                    var shouldSendNotification = false
                                                                    var shouldSendMyNotification = false
                                                                    if interest > interestLevel {
                                                                        shouldSendMyNotification = true
                                                                        notification.setValue(PFUser.current()!, forKey: "firstUser")
                                                                        if !self.localFromMyRates {
                                                                            if !fromNotifications {
                                                                                notification.setValue(userToDisplay, forKey: "secondUser")
                                                                            } else {
                                                                                notification.setValue(notificationsUserToDisplay, forKey: "secondUser")
                                                                            }
                                                                        } else {
                                                                            notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "secondUser")
                                                                        }
                                                                        
                                                                        notification.setValue(1, forKey: "type")
                                                                        notification.setValue(interest, forKey: "interest")
                                                                    } else if interestLevel > interest {
                                                                        shouldSendNotification = true
                                                                        notification.setValue(PFUser.current()!, forKey: "secondUser")
                                                                        if !self.localFromMyRates {
                                                                            if !fromNotifications {
                                                                                notification.setValue(userToDisplay, forKey: "firstUser")
                                                                            } else {
                                                                                notification.setValue(notificationsUserToDisplay, forKey: "firstUser")
                                                                            }
                                                                        } else {
                                                                            notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "firstUser")
                                                                        }
                                                                        
                                                                        notification.setValue(1, forKey: "type")
                                                                        notification.setValue(interestLevel, forKey: "interest")
                                                                    } else {
                                                                        shouldSendNotification = true
                                                                        shouldSendMyNotification = true
                                                                        notification.setValue(PFUser.current()!, forKey: "firstUser")
                                                                        if !self.localFromMyRates {
                                                                            if !fromNotifications {
                                                                                notification.setValue(userToDisplay, forKey: "secondUser")
                                                                            } else {
                                                                                notification.setValue(notificationsUserToDisplay, forKey: "secondUser")
                                                                            }
                                                                        } else {
                                                                            notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "secondUser")
                                                                        }
                                                                        
                                                                        notification.setValue(2, forKey: "type")
                                                                        notification.setValue(interestLevel, forKey: "interest")
                                                                    }
                                                                    
                                                                    notification.acl?.hasPublicReadAccess = true
                                                                    notification.acl?.hasPublicWriteAccess = true
                                                                    
                                                                    notification.saveInBackground(block: { (success, error) in
                                                                        if success {
                                                                            if shouldSendMyNotification {
                                                                                let query = PFQuery(className: "Badges")
                                                                                query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
                                                                                
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
                                                                            if shouldSendNotification {
                                                                                let query = PFQuery(className: "Badges")
                                                                                if !self.localFromMyRates {
                                                                                    if !fromNotifications {
                                                                                        query.whereKey("userId", equalTo: userToDisplay.objectId!)
                                                                                    } else {
                                                                                        query.whereKey("userId", equalTo: notificationsUserToDisplay.objectId!)
                                                                                    }
                                                                                } else {
                                                                                    query.whereKey("userId", equalTo: (self.rateToModify.value(forKey: "to") as! PFUser).objectId!)
                                                                                }
                                                                                
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
                                                                                let alrt = NSEntityDescription.insertNewObject(forEntityName: "Alerts", into: managedContext!)
                                                                                
                                                                                alrt.setValue(notification.objectId!, forKey: "objectId")
                                                                                
                                                                                alrt.setValue(notification.value(forKey: "type") as! Int, forKey: "type")
                                                                                alrt.setValue(notification.value(forKey: "interest") as! Double, forKey: "interest")
                                                                                
                                                                                if let interest2 = notification.value(forKey: "interest2") as? Double {
                                                                                    alrt.setValue(interest2, forKey: "interest2")
                                                                                }
                                                                                
                                                                                if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                                                                                    alrt.setValue(firstUserConfirmed, forKey: "firstUserConfirmed")
                                                                                }
                                                                                
                                                                                if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                                                                                    alrt.setValue(secondUserConfirmed, forKey: "secondUserConfirmed")
                                                                                }
                                                                                
                                                                                let firstUser = notification.value(forKey: "firstUser") as! PFUser
                                                                                let secondUser = notification.value(forKey: "secondUser") as! PFUser
                                                                                do {
                                                                                    try firstUser.fetchIfNeeded()
                                                                                    try secondUser.fetchIfNeeded()
                                                                                } catch {
                                                                                    print("Could not fetch user")
                                                                                }
                                                                                print("yo wassup")
                                                                                alrt.setValue(firstUser.objectId!, forKey: "firstId")
                                                                                print("now we up here")
                                                                                alrt.setValue(firstUser.value(forKey: "name") as! String, forKey: "firstName")
                                                                                print("there we go")
                                                                                do {
                                                                                    let firstPic = firstUser.value(forKey: "pic") as! PFFile
                                                                                    let data = try firstPic.getData()
                                                                                    alrt.setValue(NSData(data: data), forKey: "firstPic")
                                                                                    print("gettin warmer")
                                                                                } catch {
                                                                                    print("Could not retrieve profilePic from core data")
                                                                                }
                                                                                
                                                                                print("come on baby")
                                                                                
                                                                                alrt.setValue(secondUser.objectId!, forKey: "secondId")
                                                                                print("ay")
                                                                                alrt.setValue(secondUser.value(forKey: "name") as! String, forKey: "secondName")
                                                                                print("ayyy")
                                                                                do {
                                                                                    let secondPic = secondUser.value(forKey: "pic") as! PFFile
                                                                                    let data = try secondPic.getData()
                                                                                    alrt.setValue(NSData(data: data), forKey: "secondPic")
                                                                                    print("ayyyyy")
                                                                                } catch {
                                                                                    print("Could not retrieve profilePic from core data")
                                                                                }
                                                                                
                                                                                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                                                                                
                                                                                fetchRequest.returnsObjectsAsFaults = false
                                                                                
                                                                                // Helpers
                                                                                var result = [NSManagedObject]()
                                                                                
                                                                                do {
                                                                                    // Execute Fetch Request
                                                                                    let records = try managedContext?.fetch(fetchRequest)
                                                                                    
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
                                                                                
                                                                                alrt.setValue(result[0].value(forKey: "sortNum") as! Int, forKey: "sortNum")
                                                                                */
                                                                                if shouldSendNotification {
                                                                                    var alert = "error notification"
                                                                                    var interestValue = 0
                                                                                    if interestLevel > interest {
                                                                                        interestValue = interestLevel
                                                                                    } else {
                                                                                        interestValue = interest
                                                                                    }
                                                                                    switch(interestValue) {
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
                                                                                    
                                                                                    let data = [
                                                                                        "badge" : "Increment",
                                                                                        "alert" : alert
                                                                                        ] as [String : Any]
                                                                                    let request = [
                                                                                        "data" : data, "userId" : (notification.value(forKey: "secondUser") as! PFUser).objectId!
                                                                                        ] as [String : Any]
                                                                                    
                                                                                    PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
                                                                                }
                                                                            }
                                                                        } else {
                                                                            let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                                            self.present(alert, animated: true, completion: nil)
                                                                        }
                                                                    })
                                                                } else if (checkNotification.value(forKey: "interest") as! Int) < interestLevel || (checkNotification.value(forKey: "interest") as! Int) < interest {
                                                                    print(checkNotification.value(forKey: "interest") as! Int)
                                                                    print(interestLevel)
                                                                    print(interest)
                                                                    notification = PFObject(className: "Notifications")
                                                                    notification.acl!.hasPublicWriteAccess = true
                                                                    var shouldSendNotification = false
                                                                    var shouldSendMyNotification = false
                                                                    if interest > interestLevel {
                                                                        shouldSendMyNotification = true
                                                                        notification.setValue(PFUser.current()!, forKey: "firstUser")
                                                                        if !self.localFromMyRates {
                                                                            if !fromNotifications {
                                                                                notification.setValue(userToDisplay, forKey: "secondUser")
                                                                            } else {
                                                                                notification.setValue(notificationsUserToDisplay, forKey: "secondUser")
                                                                            }
                                                                        } else {
                                                                            notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "secondUser")
                                                                        }
                                                                        
                                                                        notification.setValue(1, forKey: "type")
                                                                        notification.setValue(interest, forKey: "interest")
                                                                    } else if interestLevel > interest {
                                                                        shouldSendNotification = true
                                                                        notification.setValue(PFUser.current()!, forKey: "secondUser")
                                                                        if !self.localFromMyRates {
                                                                            if !fromNotifications {
                                                                                notification.setValue(userToDisplay, forKey: "firstUser")
                                                                            } else {
                                                                                notification.setValue(notificationsUserToDisplay, forKey: "firstUser")
                                                                            }
                                                                        } else {
                                                                            notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "firstUser")
                                                                        }
                                                                        
                                                                        notification.setValue(1, forKey: "type")
                                                                        notification.setValue(interestLevel, forKey: "interest")
                                                                    } else {
                                                                        shouldSendNotification = true
                                                                        shouldSendMyNotification = true
                                                                        notification.setValue(PFUser.current()!, forKey: "firstUser")
                                                                        if !self.localFromMyRates {
                                                                            if !fromNotifications {
                                                                                notification.setValue(userToDisplay, forKey: "secondUser")
                                                                            } else {
                                                                                notification.setValue(notificationsUserToDisplay, forKey: "secondUser")
                                                                            }
                                                                        } else {
                                                                            notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "secondUser")
                                                                        }
                                                                        
                                                                        notification.setValue(2, forKey: "type")
                                                                        notification.setValue(interestLevel, forKey: "interest")
                                                                    }
                                                                    
                                                                    notification.acl?.hasPublicReadAccess = true
                                                                    notification.acl?.hasPublicWriteAccess = true
                                                                    
                                                                    notification.saveInBackground(block: { (success, error) in
                                                                        if success {
                                                                            if shouldSendMyNotification {
                                                                                let query = PFQuery(className: "Badges")
                                                                                query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
                                                                                
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
                                                                            if shouldSendNotification {
                                                                                let query = PFQuery(className: "Badges")
                                                                                if !self.localFromMyRates {
                                                                                    if !fromNotifications {
                                                                                        query.whereKey("userId", equalTo: userToDisplay.objectId!)
                                                                                    } else {
                                                                                        query.whereKey("userId", equalTo: notificationsUserToDisplay.objectId!)
                                                                                    }
                                                                                } else {
                                                                                    query.whereKey("userId", equalTo: (self.rateToModify.value(forKey: "to") as! PFUser).objectId!)
                                                                                }
                                                                                
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
                                                                                let alrt = NSEntityDescription.insertNewObject(forEntityName: "Alerts", into: managedContext!)
                                                                                
                                                                                alrt.setValue(notification.objectId!, forKey: "objectId")
                                                                                
                                                                                alrt.setValue(notification.value(forKey: "type") as! Int, forKey: "type")
                                                                                alrt.setValue(notification.value(forKey: "interest") as! Double, forKey: "interest")
                                                                                
                                                                                if let interest2 = notification.value(forKey: "interest2") as? Double {
                                                                                    alrt.setValue(interest2, forKey: "interest2")
                                                                                }
                                                                                
                                                                                if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                                                                                    alrt.setValue(firstUserConfirmed, forKey: "firstUserConfirmed")
                                                                                }
                                                                                
                                                                                if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                                                                                    alrt.setValue(secondUserConfirmed, forKey: "secondUserConfirmed")
                                                                                }
                                                                                
                                                                                let firstUser = notification.value(forKey: "firstUser") as! PFUser
                                                                                let secondUser = notification.value(forKey: "secondUser") as! PFUser
                                                                                do {
                                                                                    try firstUser.fetchIfNeeded()
                                                                                    try secondUser.fetchIfNeeded()
                                                                                } catch {
                                                                                    print("Could not fetch user")
                                                                                }
                                                                                print("yo wassup")
                                                                                alrt.setValue(firstUser.objectId!, forKey: "firstId")
                                                                                print("now we up here")
                                                                                alrt.setValue(firstUser.value(forKey: "name") as! String, forKey: "firstName")
                                                                                print("there we go")
                                                                                do {
                                                                                    let firstPic = firstUser.value(forKey: "pic") as! PFFile
                                                                                    let data = try firstPic.getData()
                                                                                    alrt.setValue(NSData(data: data), forKey: "firstPic")
                                                                                    print("gettin warmer")
                                                                                } catch {
                                                                                    print("Could not retrieve profilePic from core data")
                                                                                }
                                                                                
                                                                                print("come on baby")
                                                                                
                                                                                alrt.setValue(secondUser.objectId!, forKey: "secondId")
                                                                                print("ay")
                                                                                alrt.setValue(secondUser.value(forKey: "name") as! String, forKey: "secondName")
                                                                                print("ayyy")
                                                                                do {
                                                                                    let secondPic = secondUser.value(forKey: "pic") as! PFFile
                                                                                    let data = try secondPic.getData()
                                                                                    alrt.setValue(NSData(data: data), forKey: "secondPic")
                                                                                    print("ayyyyy")
                                                                                } catch {
                                                                                    print("Could not retrieve profilePic from core data")
                                                                                }
                                                                                
                                                                                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                                                                                
                                                                                fetchRequest.returnsObjectsAsFaults = false
                                                                                
                                                                                // Helpers
                                                                                var result = [NSManagedObject]()
                                                                                
                                                                                do {
                                                                                    // Execute Fetch Request
                                                                                    let records = try managedContext?.fetch(fetchRequest)
                                                                                    
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
                                                                                
                                                                                alrt.setValue(result[0].value(forKey: "sortNum") as! Int, forKey: "sortNum")
 */
                                                                                
                                                                                if shouldSendNotification {
                                                                                    var alert = "error notification"
                                                                                    var interestValue = 0
                                                                                    if interestLevel > interest {
                                                                                        interestValue = interestLevel
                                                                                    } else {
                                                                                        interestValue = interest
                                                                                    }
                                                                                    switch(interestValue) {
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
                                                                                    
                                                                                    let data = [
                                                                                        "badge" : "Increment",
                                                                                        "alert" : alert
                                                                                        ] as [String : Any]
                                                                                    let request = [
                                                                                        "data" : data, "userId" : (notification.value(forKey: "secondUser") as! PFUser).objectId!
                                                                                        ] as [String : Any]
                                                                                    
                                                                                    PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
                                                                                }
                                                                            }
                                                                        } else {
                                                                            let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                                            self.present(alert, animated: true, completion: nil)
                                                                        }
                                                                    })
                                                                }
                                                            }
                                                        } else {
                                                            print("here 2")
                                                            let notification = PFObject(className: "Notifications")
                                                            notification.acl!.hasPublicWriteAccess = true
                                                            var shouldSendNotification = false
                                                            var shouldSendMyNotification = false
                                                            if interest > interestLevel {
                                                                shouldSendMyNotification = true
                                                                notification.setValue(PFUser.current()!, forKey: "firstUser")
                                                                if !self.localFromMyRates {
                                                                    if !fromNotifications {
                                                                        notification.setValue(userToDisplay, forKey: "secondUser")
                                                                    } else {
                                                                        notification.setValue(notificationsUserToDisplay, forKey: "secondUser")
                                                                    }
                                                                } else {
                                                                    notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "secondUser")
                                                                }
                                                                
                                                                notification.setValue(1, forKey: "type")
                                                                notification.setValue(interest, forKey: "interest")
                                                            } else if interestLevel > interest {
                                                                shouldSendNotification = true
                                                                notification.setValue(PFUser.current()!, forKey: "secondUser")
                                                                if !self.localFromMyRates {
                                                                    if !fromNotifications {
                                                                        notification.setValue(userToDisplay, forKey: "firstUser")
                                                                    } else {
                                                                        notification.setValue(notificationsUserToDisplay, forKey: "firstUser")
                                                                    }
                                                                } else {
                                                                    notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "firstUser")
                                                                }
                                                                
                                                                notification.setValue(1, forKey: "type")
                                                                notification.setValue(interestLevel, forKey: "interest")
                                                            } else {
                                                                shouldSendNotification = true
                                                                shouldSendMyNotification = true
                                                                notification.setValue(PFUser.current()!, forKey: "firstUser")
                                                                if !self.localFromMyRates {
                                                                    if !fromNotifications {
                                                                        notification.setValue(userToDisplay, forKey: "secondUser")
                                                                    } else {
                                                                        notification.setValue(notificationsUserToDisplay, forKey: "secondUser")
                                                                    }
                                                                } else {
                                                                    notification.setValue(self.rateToModify.value(forKey: "to") as! PFUser, forKey: "secondUser")
                                                                }
                                                                
                                                                notification.setValue(2, forKey: "type")
                                                                notification.setValue(interestLevel, forKey: "interest")
                                                            }
                                                            
                                                            notification.acl?.hasPublicReadAccess = true
                                                            notification.acl?.hasPublicWriteAccess = true
                                                            
                                                            notification.saveInBackground(block: { (success, error) in
                                                                if success {
                                                                    if shouldSendMyNotification {
                                                                        let query = PFQuery(className: "Badges")
                                                                        query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
                                                                        
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
                                                                    if shouldSendNotification {
                                                                        let query = PFQuery(className: "Badges")
                                                                        if !self.localFromMyRates {
                                                                            if !fromNotifications {
                                                                                query.whereKey("userId", equalTo: userToDisplay.objectId!)
                                                                            } else {
                                                                                query.whereKey("userId", equalTo: notificationsUserToDisplay.objectId!)
                                                                            }
                                                                        } else {
                                                                            query.whereKey("userId", equalTo: (self.rateToModify.value(forKey: "to") as! PFUser).objectId!)
                                                                        }
                                                                        
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
                                                                        let alrt = NSEntityDescription.insertNewObject(forEntityName: "Alerts", into: managedContext!)
                                                                        
                                                                        alrt.setValue(notification.objectId!, forKey: "objectId")
                                                                        
                                                                        alrt.setValue(notification.value(forKey: "type") as! Int, forKey: "type")
                                                                        alrt.setValue(notification.value(forKey: "interest") as! Double, forKey: "interest")
                                                                        
                                                                        if let interest2 = notification.value(forKey: "interest2") as? Double {
                                                                            alrt.setValue(interest2, forKey: "interest2")
                                                                        }
                                                                        
                                                                        if let firstUserConfirmed = notification.value(forKey: "firstUserConfirmed") as? Bool {
                                                                            alrt.setValue(firstUserConfirmed, forKey: "firstUserConfirmed")
                                                                        }
                                                                        
                                                                        if let secondUserConfirmed = notification.value(forKey: "secondUserConfirmed") as? Bool {
                                                                            alrt.setValue(secondUserConfirmed, forKey: "secondUserConfirmed")
                                                                        }
                                                                        
                                                                        let firstUser = notification.value(forKey: "firstUser") as! PFUser
                                                                        let secondUser = notification.value(forKey: "secondUser") as! PFUser
                                                                        do {
                                                                            try firstUser.fetchIfNeeded()
                                                                            try secondUser.fetchIfNeeded()
                                                                        } catch {
                                                                            print("Could not fetch user")
                                                                        }
                                                                        print("yo wassup")
                                                                        alrt.setValue(firstUser.objectId!, forKey: "firstId")
                                                                        print("now we up here")
                                                                        alrt.setValue(firstUser.value(forKey: "name") as! String, forKey: "firstName")
                                                                        print("there we go")
                                                                        do {
                                                                            let firstPic = firstUser.value(forKey: "pic") as! PFFile
                                                                            let data = try firstPic.getData()
                                                                            alrt.setValue(NSData(data: data), forKey: "firstPic")
                                                                            print("gettin warmer")
                                                                        } catch {
                                                                            print("Could not retrieve profilePic from core data")
                                                                        }
                                                                        
                                                                        print("come on baby")
                                                                        
                                                                        alrt.setValue(secondUser.objectId!, forKey: "secondId")
                                                                        print("ay")
                                                                        alrt.setValue(secondUser.value(forKey: "name") as! String, forKey: "secondName")
                                                                        print("ayyy")
                                                                        do {
                                                                            let secondPic = secondUser.value(forKey: "pic") as! PFFile
                                                                            let data = try secondPic.getData()
                                                                            alrt.setValue(NSData(data: data), forKey: "secondPic")
                                                                            print("ayyyyy")
                                                                        } catch {
                                                                            print("Could not retrieve profilePic from core data")
                                                                        }
                                                                        
                                                                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                                                                        
                                                                        fetchRequest.returnsObjectsAsFaults = false
                                                                        
                                                                        // Helpers
                                                                        var result = [NSManagedObject]()
                                                                        
                                                                        do {
                                                                            // Execute Fetch Request
                                                                            let records = try managedContext?.fetch(fetchRequest)
                                                                            
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
                                                                        
                                                                        alrt.setValue(result[0].value(forKey: "sortNum") as! Int, forKey: "sortNum")
                                                                        */
                                                                        if shouldSendNotification {
                                                                            var alert = "error notification"
                                                                            var interestValue = 0
                                                                            if interestLevel > interest {
                                                                                interestValue = interestLevel
                                                                            } else {
                                                                                interestValue = interest
                                                                            }
                                                                            switch(interestValue) {
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
                                                                            
                                                                            let data = [
                                                                                "badge" : "Increment",
                                                                                "alert" : alert
                                                                                ] as [String : Any]
                                                                            let request = [
                                                                                "data" : data, "userId" : (notification.value(forKey: "secondUser") as! PFUser).objectId!
                                                                                ] as [String : Any]
                                                                            
                                                                            PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
                                                                        }
                                                                    }
                                                                } else {
                                                                    let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                                    self.present(alert, animated: true, completion: nil)
                                                                }
                                                            })
                                                        }
                                                    } else {
                                                        let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                        self.present(alert, animated: true, completion: nil)
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        })
                    }
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            UIApplication.shared.endIgnoringInteractionEvents()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
