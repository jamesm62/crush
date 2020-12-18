//
//  MySettings.swift
//  rate
//
//  Created by James McGivern on 2/21/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse
import CoreData
import UserNotifications

var shouldUpdate = true

class MySettings: UITableViewController {

    @IBOutlet var name: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var school: UILabel!
    @IBOutlet var age: UILabel!
    @IBOutlet var gender: UILabel!
    @IBOutlet var bio: UILabel!
    
    @IBOutlet var cell1: UITableViewCell!
    @IBOutlet var cell2: UITableViewCell!
    @IBOutlet var cell3: UITableViewCell!
    @IBOutlet var cell4: UITableViewCell!
    @IBOutlet var cell5: UITableViewCell!
    @IBOutlet var cell6: UITableViewCell!
    @IBOutlet var cell7: UITableViewCell!
    @IBOutlet var cell8: UITableViewCell!
    @IBOutlet var cell9: UITableViewCell!
    @IBOutlet var cell10: UITableViewCell!
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cell1.accessoryType = .disclosureIndicator
        cell2.accessoryType = .disclosureIndicator
        cell3.accessoryType = .disclosureIndicator
        cell4.accessoryType = .disclosureIndicator
        cell5.accessoryType = .disclosureIndicator
        cell6.accessoryType = .disclosureIndicator
        cell7.accessoryType = .disclosureIndicator
        cell8.accessoryType = .disclosureIndicator
        cell9.accessoryType = .disclosureIndicator
        cell10.accessoryType = .disclosureIndicator
        
        name.text = "\(myName) \(myLast)"
        username.text = myUsername
        if mySchool != "" {
            self.school.text = mySchool
        } else {
            self.school.text = "No school"
        }
        age.text = "\(myAge)"
        gender.text = myGender
        bio.text = myBio
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "changeName", sender: self)
            } else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "changeUsername", sender: self)
            } else if indexPath.row == 2 {
                self.performSegue(withIdentifier: "changePassword", sender: self)
            } else if indexPath.row == 3 {
                self.performSegue(withIdentifier: "changeSchool", sender: self)
            } else if indexPath.row == 4 {
                self.performSegue(withIdentifier: "changeAge", sender: self)
            } else if indexPath.row == 5 {
                self.performSegue(withIdentifier: "changeGender", sender: self)
            } else if indexPath.row == 6 {
                self.performSegue(withIdentifier: "changeBio", sender: self)
            } else if indexPath.row == 7 {
                self.performSegue(withIdentifier: "changePhotos", sender: self)
            } else if indexPath.row == 8 {
                self.performSegue(withIdentifier: "changeSocialMedia", sender: self)
            }
        } else {
            if indexPath.row == 0 {
                self.logout()
            }
        }
    }
    
    func logout() {
        let alert = UIAlertController(title: "Crush", message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            PFUser.logOutInBackground(block: { (error) in
                if error == nil {
/*
                    var request = NSFetchRequest<NSFetchRequestResult>(entityName: "Accounts")
                    
                    do {
                        let results = try managedContext?.fetch(request)
                        if (results?.count)! > 0 {
                            for result in results as! [NSManagedObject] {
                                managedContext?.delete(result)
                            }
                        }
                    } catch {
                        print("There has been an error")
                    }
                    
                    request = NSFetchRequest<NSFetchRequestResult>(entityName: "Alerts")
                    
                    do {
                        let results = try managedContext?.fetch(request)
                        if (results?.count)! > 0 {
                            for result in results as! [NSManagedObject] {
                                managedContext?.delete(result)
                            }
                        }
                    } catch {
                        print("There has been an error")
                    }
                    
                    request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chats")
                    
                    do {
                        let results = try managedContext?.fetch(request)
                        if (results?.count)! > 0 {
                            for result in results as! [NSManagedObject] {
                                managedContext?.delete(result)
                            }
                        }
                    } catch {
                        print("There has been an error")
                    }
                    
                    do {
                        try managedContext?.save()
                    } catch {
                        let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
 */
                    
                    myUser = PFUser()
                    myUsername = "Loading..."
                    myPic = UIImage(named: "profilePic.png")
                    myName = ""
                    myLast = ""
                    myAge = 0
                    myGender = ""
                    myBio = ""
                    mySchool = "No school"
                    myAddedPicsArray = []
                    mySocialMediaAccounts = []
                    
                    UserDefaults.standard.removeObject(forKey: "profilePic")
                    UserDefaults.standard.removeObject(forKey: "name")
                    UserDefaults.standard.removeObject(forKey: "lastName")
                    UserDefaults.standard.removeObject(forKey: "gender")
                    UserDefaults.standard.removeObject(forKey: "bio")
                    UserDefaults.standard.removeObject(forKey: "age")
                    UserDefaults.standard.removeObject(forKey: "username")
                    UserDefaults.standard.removeObject(forKey: "addedPics")
                    UserDefaults.standard.removeObject(forKey: "school")
                    UserDefaults.standard.removeObject(forKey: "socialMedia")
                    
                    people.removeAll()
                    usernames.removeAll()
                    pics.removeAll()
                    names.removeAll()
                    lasts.removeAll()
                    distances.removeAll()
                    ages.removeAll()
                    genders.removeAll()
                    bios.removeAll()
                    schools.removeAll()
                    addedPicsArrays.removeAll()
                    socialMediaAccountsArrays.removeAll()
                    
                    searchPeople.removeAll()
                    searchUsernames.removeAll()
                    searchPics.removeAll()
                    searchNames.removeAll()
                    searchLasts.removeAll()
                    searchDistances.removeAll()
                    searchAges.removeAll()
                    searchGenders.removeAll()
                    searchBios.removeAll()
                    searchSchools.removeAll()
                    searchAddedPicsArrays.removeAll()
                    searchSocialMediaAccountsArrays.removeAll()
                    
                    alerts.removeAll()
                    
                    allChats.removeAll()
                    chats.removeAll()
                    mainChats.removeAll()
                    
                    userToDisplay = PFUser()
                    usernameToDisplay = ""
                    picToDisplay = UIImage(named: "profilePic.png")!
                    nameToDisplay = ""
                    lastToDisplay = ""
                    distanceToDisplay = 0.0
                    ageToDisplay = 0
                    genderToDisplay = ""
                    bioToDisplay = ""
                    schoolToDisplay = ""
                    addedPicsArrayToDisplay = []
                    socialMediaAccountsArrayToDisplay = []
                    
                    myUser = PFUser()
                    myUsername = "Loading..."
                    myPic = UIImage(named: "profilePic.png")
                    myName = ""
                    myLast = ""
                    myAge = 0
                    myGender = ""
                    myBio = ""
                    mySchool = "No school"
                    myAddedPicsArray = []
                    mySocialMediaAccounts = []
                    
                    myLocation = PFGeoPoint()
                    
                    UIApplication.shared.unregisterForRemoteNotifications()
                    
                    PFInstallation.current()!.setValue("", forKey: "userId")
                    
                    shouldUpdate = false
                    
                    client.disconnect()
                    
                    PFInstallation.current()!.saveInBackground(block: { (success, error) in
                        if success {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "HomeScreen") as UIViewController
                            self.present(vc, animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                } else {
                    let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 9
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "    ACCOUNT"
        } else {
            return ""
        }
    }

}
