//
//  Ask.swift
//  rate
//
//  Created by James McGivern on 5/12/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class Ask: UITableViewController {
    
    var right = UIBarButtonItem()
    var left = UIBarButtonItem()

    override func viewDidLoad() {
        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false
        
        right = UIBarButtonItem(title: "Ask", style: .done, target: self, action: #selector(Ask.ask))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        right.isEnabled = false
        
        left = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(Ask.cancel))
        left.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = left
    }
    
    @objc func ask() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let notification = PFObject(className: "Notifications")
        if !fromNotifications {
            notification.setValue(userToDisplay, forKey: "firstUser")
        } else {
            notification.setValue(notificationsUserToDisplay, forKey: "firstUser")
        }
        notification.setValue(PFUser.current()!, forKey: "secondUser")
        
        notification.setValue(true, forKey: "secondUserConfirmed")
        
        notification.setValue(self.tableView.indexPathForSelectedRow!.item, forKey: "interest")
        
        notification.setValue(4, forKey: "type")
        
        notification.acl?.hasPublicReadAccess = true
        notification.acl?.hasPublicWriteAccess = true
        
        notification.saveInBackground { (success, error) in
            if success {
                let query = PFQuery(className: "Badges")
                if !fromNotifications {
                    query.whereKey("userId", equalTo: userToDisplay.objectId!)
                } else {
                    query.whereKey("userId", equalTo: notificationsUserToDisplay.objectId!)
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
                
                var alert = "error notification"
                
                switch(self.tableView.indexPathForSelectedRow!.item) {
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
                if !fromNotifications {
                    let request = [
                        "data" : data, "userId" : userToDisplay.objectId!
                        ] as [String : Any]
                    PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
                } else {
                    let request = [
                        "data" : data, "userId" : notificationsUserToDisplay.objectId!
                        ] as [String : Any]
                    PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
                }
                
                UIApplication.shared.endIgnoringInteractionEvents()
                self.navigationController?.popViewController(animated: true)
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
                let alert = UIAlertController(title: "Oops", message: "Could not save request", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "    OPTIONS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath); cell.selectionStyle = .none
        
        switch(indexPath.row) {
        case 0: cell.textLabel?.text = "Ask to start a relationship"
        case 1: cell.textLabel?.text = "Ask to go on a date"
        case 2: cell.textLabel?.text = "Ask to be more than friends"
        case 3: cell.textLabel?.text = "Ask to hang out"
        case 4: cell.textLabel?.text = "Ask to get to know each other"
        case 5: cell.textLabel?.text = "Ask to be friends"
        case 6: cell.textLabel?.text = "Ask to meet"
        default: print("lol")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        right.isEnabled = true
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
