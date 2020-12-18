//
//  SocialMedia.swift
//  rate
//
//  Created by James McGivern on 5/9/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit

var socialMediaAccounts:[String] = []

class SocialMedia: UITableViewController, UITextFieldDelegate {
    
    var numberOfOtherAccounts = 0
    
    var right = UIBarButtonItem()
    
    var cells:[UITableViewCell] = []

    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(SocialMedia.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
    
    @objc func done() {
        socialMediaAccounts.removeAll()
        for cell in cells {
            if cell.reuseIdentifier == "instagram", (cell.viewWithTag(1) as! UITextField).text! != "" {
                socialMediaAccounts.append("Instagram")
                socialMediaAccounts.append((cell.viewWithTag(1) as! UITextField).text!)
            } else if cell.reuseIdentifier == "snapchat", (cell.viewWithTag(1) as! UITextField).text! != "" {
                socialMediaAccounts.append("Snapchat")
                socialMediaAccounts.append((cell.viewWithTag(1) as! UITextField).text!)
            } else if cell.reuseIdentifier == "otherAccount" {
                if (cell.viewWithTag(1) as! UITextField).text! != "" {
                    if (cell.viewWithTag(2) as! UITextField).text! != "" {
                        socialMediaAccounts.append((cell.viewWithTag(1) as! UITextField).text!)
                        socialMediaAccounts.append((cell.viewWithTag(2) as! UITextField).text!)
                    } else {
                        let alert = UIAlertController(title: "Oops", message: "Please fill out all information completely", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    if (cell.viewWithTag(2) as! UITextField).text! != "" {
                        let alert = UIAlertController(title: "Oops", message: "Please fill out all information completely", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        self.performSegue(withIdentifier: "bio", sender: self)
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
        return 3+numberOfOtherAccounts
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2+numberOfOtherAccounts {
            return 43
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cells.insert(cell, at: indexPath.row)
        if cell.reuseIdentifier == "instagram" {
            (cell.viewWithTag(1) as! UITextField).becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "instagram", for: indexPath)
            (cell.viewWithTag(1) as! UITextField).delegate = self
        } else if indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "snapchat", for: indexPath)
            (cell.viewWithTag(1) as! UITextField).delegate = self
        } else {
            if numberOfOtherAccounts+2 > indexPath.row {
                cell = tableView.dequeueReusableCell(withIdentifier: "otherAccount", for: indexPath)
                (cell.viewWithTag(1) as! UITextField).delegate = self
                (cell.viewWithTag(2) as! UITextField).delegate = self
                (cell.viewWithTag(3) as! UIButton).addTarget(self, action: #selector(SocialMedia.removeRow(sender:)), for: .touchUpInside)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "addOtherAccount", for: indexPath)
                
                (cell.viewWithTag(1) as! UIButton).addTarget(self, action: #selector(SocialMedia.addOther), for: .touchUpInside)
            }
        }
        return cell
    }
    
    @objc func removeRow(sender: UIButton) {
        numberOfOtherAccounts -= 1
        let row = self.tableView.indexPath(for: sender.superview!.superview as! UITableViewCell)!.row
        self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .right)
        cells.remove(at: row)
    }
    
    @objc func addOther() {
        numberOfOtherAccounts += 1
        self.tableView.insertRows(at: [IndexPath(row: 1+numberOfOtherAccounts, section: 0)], with: .automatic)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let cell = textField.superview!.superview as! UITableViewCell
        if cell.reuseIdentifier == "instagram" {
            (cell.viewWithTag(1) as! UITextField).resignFirstResponder()
        } else if cell.reuseIdentifier == "snapchat" {
            (cell.viewWithTag(1) as! UITextField).resignFirstResponder()
        } else if cell.reuseIdentifier == "otherAccount" {
            if (cell.viewWithTag(1) as! UITextField).isFirstResponder {
                (cell.viewWithTag(1) as! UITextField).resignFirstResponder()
            } else {
                (cell.viewWithTag(2) as! UITextField).resignFirstResponder()
            }
        }
        
        return true
    }
}
