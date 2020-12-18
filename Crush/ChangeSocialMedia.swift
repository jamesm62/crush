//
//  ChangeSocialMedia.swift
//  rate
//
//  Created by James McGivern on 5/12/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class ChangeSocialMedia: UITableViewController, UITextFieldDelegate {

    var numberOfOtherAccounts = 0
    
    var right = UIBarButtonItem()
    
    var cells:[UITableViewCell] = []
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(SocialMedia.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        if mySocialMediaAccounts.contains("Instagram") {
            if mySocialMediaAccounts.contains("Snapchat") {
                numberOfOtherAccounts = (mySocialMediaAccounts.count-4)/2
            } else {
                numberOfOtherAccounts = (mySocialMediaAccounts.count-2)/2
            }
        } else {
            if mySocialMediaAccounts.contains("Snapchat") {
                numberOfOtherAccounts = (mySocialMediaAccounts.count-2)/2
            } else {
                numberOfOtherAccounts = (mySocialMediaAccounts.count)/2
            }
        }
    }
    
    @objc func done() {
        mySocialMediaAccounts.removeAll()
        for cell in cells {
            if cell.reuseIdentifier == "instagram", (cell.viewWithTag(1) as! UITextField).text! != "" {
                mySocialMediaAccounts.append("Instagram")
                mySocialMediaAccounts.append((cell.viewWithTag(1) as! UITextField).text!)
            } else if cell.reuseIdentifier == "snapchat", (cell.viewWithTag(1) as! UITextField).text! != "" {
                mySocialMediaAccounts.append("Snapchat")
                mySocialMediaAccounts.append((cell.viewWithTag(1) as! UITextField).text!)
            } else if cell.reuseIdentifier == "otherAccount" {
                if (cell.viewWithTag(1) as! UITextField).text! != "" {
                    if (cell.viewWithTag(2) as! UITextField).text! != "" {
                        mySocialMediaAccounts.append((cell.viewWithTag(1) as! UITextField).text!)
                        mySocialMediaAccounts.append((cell.viewWithTag(2) as! UITextField).text!)
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
        PFUser.current()!.setValue(mySocialMediaAccounts, forKey: "socialMedia")
        
        PFUser.current()!.saveInBackground { (success, error) in
            if success {
                UserDefaults.standard.setValue(mySocialMediaAccounts, forKey: "socialMedia")
                
                self.navigationController?.popViewController(animated: true)
            } else {
                let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
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
            if let index = mySocialMediaAccounts.index(of: "Instagram") {
                (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[index+1]
            }
        } else if indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "snapchat", for: indexPath)
            (cell.viewWithTag(1) as! UITextField).delegate = self
            if let index = mySocialMediaAccounts.index(of: "Snapchat") {
                (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[index+1]
            }
        } else {
            if numberOfOtherAccounts+2 > indexPath.row {
                cell = tableView.dequeueReusableCell(withIdentifier: "otherAccount", for: indexPath)
                (cell.viewWithTag(1) as! UITextField).delegate = self
                (cell.viewWithTag(2) as! UITextField).delegate = self
                (cell.viewWithTag(3) as! UIButton).addTarget(self, action: #selector(SocialMedia.removeRow(sender:)), for: .touchUpInside)
                if mySocialMediaAccounts.contains("Instagram") {
                    if mySocialMediaAccounts.contains("Snapchat") {
                        if numberOfOtherAccounts <= (mySocialMediaAccounts.count-4)/2 {
                            if mySocialMediaAccounts.contains("Instagram") {
                                if mySocialMediaAccounts.contains("Snapchat") {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2+1]
                                } else {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-1]
                                }
                            } else {
                                if mySocialMediaAccounts.contains("Snapchat") {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-1]
                                } else {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-4]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-3]
                                }
                            }
                        }
                    } else {
                        if numberOfOtherAccounts <= (mySocialMediaAccounts.count-2)/2 {
                            if mySocialMediaAccounts.contains("Instagram") {
                                if mySocialMediaAccounts.contains("Snapchat") {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2+1]
                                } else {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-1]
                                }
                            } else {
                                if mySocialMediaAccounts.contains("Snapchat") {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-1]
                                } else {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-4]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-3]
                                }
                            }
                        }
                    }
                } else {
                    if mySocialMediaAccounts.contains("Snapchat") {
                        if numberOfOtherAccounts <= (mySocialMediaAccounts.count-2)/2 {
                            if mySocialMediaAccounts.contains("Instagram") {
                                if mySocialMediaAccounts.contains("Snapchat") {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2+1]
                                } else {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-1]
                                }
                            } else {
                                if mySocialMediaAccounts.contains("Snapchat") {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-1]
                                } else {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-4]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-3]
                                }
                            }
                        }
                    } else {
                        if numberOfOtherAccounts <= (mySocialMediaAccounts.count)/2 {
                            if mySocialMediaAccounts.contains("Instagram") {
                                if mySocialMediaAccounts.contains("Snapchat") {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2+1]
                                } else {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-1]
                                }
                            } else {
                                if mySocialMediaAccounts.contains("Snapchat") {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-2]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-1]
                                } else {
                                    (cell.viewWithTag(1) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-4]
                                    (cell.viewWithTag(2) as! UITextField).text = mySocialMediaAccounts[indexPath.row*2-3]
                                }
                            }
                        }
                    }
                }
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "addOtherAccount", for: indexPath)
                
                (cell.viewWithTag(1) as! UIButton).addTarget(self, action: #selector(SocialMedia.addOther), for: .touchUpInside)
            }
        }
        cell.tag = indexPath.row+4
        return cell
    }
    
    @objc func removeRow(sender: UIButton) {
        numberOfOtherAccounts -= 1
        self.tableView.deleteRows(at: [IndexPath(row: (sender.superview!.superview as! UITableViewCell).tag-4, section: 0)], with: .automatic)
        cells.remove(at: (sender.superview!.superview as! UITableViewCell).tag-4)
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
