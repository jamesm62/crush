//
//  ProfileSocialMedia.swift
//  rate
//
//  Created by James McGivern on 5/11/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit

class ProfileSocialMedia: UITableViewController {
    
    var noSocialMediaLabel = UILabel()

    override func viewDidLoad() {
        self.tableView.allowsSelection = false
        
        noSocialMediaLabel.isUserInteractionEnabled = false
        
        self.noSocialMediaLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 100))
        self.noSocialMediaLabel.center = self.tableView.center
        self.noSocialMediaLabel.textAlignment = .center
        self.noSocialMediaLabel.textColor = UIColor.clear
        self.noSocialMediaLabel.font = UIFont.systemFont(ofSize: 25)
        self.noSocialMediaLabel.numberOfLines = 0
        self.noSocialMediaLabel.text = "This user has no social media accounts"
        
        self.navigationController!.view.insertSubview(self.noSocialMediaLabel, belowSubview: self.navigationController!.navigationBar)
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
        if !fromNotifications {
            if socialMediaAccountsArrayToDisplay.count == 0 {
                noSocialMediaLabel.textColor = UIColor.lightGray
            }
            return socialMediaAccountsArrayToDisplay.count/2
        } else {
            if notificationsSocialMediaAccountsArrayToDisplay.count == 0 {
                noSocialMediaLabel.textColor = UIColor.lightGray
            }
            return notificationsSocialMediaAccountsArrayToDisplay.count/2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "account", for: indexPath)
        if !fromNotifications {
            (cell.viewWithTag(1) as! UILabel).text = socialMediaAccountsArrayToDisplay[indexPath.row*2]
            (cell.viewWithTag(2) as! UILabel).text = socialMediaAccountsArrayToDisplay[indexPath.row*2+1]
        } else {
            (cell.viewWithTag(1) as! UILabel).text = notificationsSocialMediaAccountsArrayToDisplay[indexPath.row*2]
            (cell.viewWithTag(2) as! UILabel).text = notificationsSocialMediaAccountsArrayToDisplay[indexPath.row*2+1]
        }

        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        noSocialMediaLabel.textColor = UIColor.clear
    }
}
