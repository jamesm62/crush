//
//  TabBarController.swift
//  rate
//
//  Created by James McGivern on 1/26/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

var indexToSelect = 0

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        self.tabBar.tintColor = UIColor.black
        
        var fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 36.5)!]
        self.viewControllers![0].tabBarItem.setTitleTextAttributes(fontStyle, for: .normal)
        self.viewControllers![0].tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -6.25)
        self.viewControllers![0].tabBarItem.tag = 0
        fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
        self.viewControllers![1].tabBarItem.setTitleTextAttributes(fontStyle, for: .normal)
        self.viewControllers![1].tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -12)
        self.viewControllers![1].tabBarItem.tag = 1
        fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 29)!]
        self.viewControllers![2].tabBarItem.setTitleTextAttributes(fontStyle, for: .normal)
        self.viewControllers![2].tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -11)
        self.viewControllers![2].tabBarItem.tag = 2
        fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 30)!]
        self.viewControllers![3].tabBarItem.setTitleTextAttributes(fontStyle, for: .normal)
        self.viewControllers![3].tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
        self.viewControllers![3].tabBarItem.tag = 3
        
        self.viewControllers![0].tabBarItem.title = String(describing: NSString(utf8String: "\u{E800}")!)
        
        self.viewControllers![1].tabBarItem.title = String(describing: NSString(utf8String: "\u{F0F3}")!)
        
        self.viewControllers![2].tabBarItem.title = String(describing: NSString(utf8String: "\u{F4AC}")!)
        
        self.viewControllers![3].tabBarItem.title = String(describing: NSString(utf8String: "\u{E802}")!)
        
        self.selectedIndex = indexToSelect
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        item.badgeValue = nil
        if item.tag == 0 {
            print("setting shouldshowratebutton to true")
            shouldShowRateButton = true
            fromNotifications = false
        } else if item.tag == 1 {
            print("setting shouldshowratebutton to false")
            shouldShowRateButton = false
            fromNotifications = true
        } else {
            print("setting shouldshowratebutton to false")
            shouldShowRateButton = false
            fromNotifications = false
        }
        
        switch(item.tag) {
        case 1:
            let badgeQuery = PFQuery(className: "Badges")
            badgeQuery.whereKey("userId", equalTo: PFUser.current()!.objectId!)
            
            badgeQuery.getFirstObjectInBackground { (badge, error) in
                if error == nil {
                    if badge != nil {
                        badge!.setValue(0, forKey: "notificationsBadge")
                        badge!.saveInBackground()
                    }
                }
            }
        case 2:
            let badgeQuery = PFQuery(className: "Badges")
            badgeQuery.whereKey("userId", equalTo: PFUser.current()!.objectId!)
            
            badgeQuery.getFirstObjectInBackground { (badge, error) in
                if error == nil {
                    if badge != nil {
                        badge!.setValue(0, forKey: "messagesBadge")
                        badge!.saveInBackground()
                    }
                }
            }
        default: break;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
