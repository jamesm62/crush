//
//  People.swift
//  Crush
//
//  Created by James McGivern on 12/27/17.
//  Copyright © 2017 Crush. All rights reserved.
//

import UIKit
import CoreData
import Parse
import UserNotifications
import ParseLiveQuery

var userToDisplay = PFUser()
var usernameToDisplay = ""
var picToDisplay = UIImage(named: "profilePic.png")!
var nameToDisplay = ""
var lastToDisplay = ""
var distanceToDisplay:Double?
var ageToDisplay = 0
var genderToDisplay = ""
var bioToDisplay = ""
var schoolToDisplay:String?
var addedPicsArrayToDisplay:[UIImage] = []
var socialMediaAccountsArrayToDisplay:[String] = []

var notificationsUserToDisplay = PFUser()
var notificationsUsernameToDisplay = ""
var notificationsPicToDisplay = UIImage(named: "profilePic.png")!
var notificationsNameToDisplay = ""
var notificationsLastToDisplay = ""
var notificationsDistanceToDisplay:Double?
var notificationsAgeToDisplay = 0
var notificationsGenderToDisplay = ""
var notificationsBioToDisplay = ""
var notificationsSchoolToDisplay:String?
var notificationsAddedPicsArrayToDisplay:[UIImage] = []
var notificationsSocialMediaAccountsArrayToDisplay:[String] = []

var myUser = PFUser()
var myUsername = "Loading..."
var myPic = UIImage(named: "profilePic.png")
var myName = ""
var myLast = ""
var myAge = 0
var myGender = ""
var myBio = ""
var mySchool = "No school"
var myAddedPicsArray:[UIImage] = []
var mySocialMediaAccounts:[String] = []

var useLocationToLoadDistances = false

var shouldReloadPeople = false

var myLocation = PFGeoPoint()

var managedContext:NSManagedObjectContext? = nil

var openedFromMainScreen = false

var people:[PFUser] = []
var usernames:[String] = []
var pics:[UIImage] = []
var names:[String] = []
var lasts:[String] = []
var distances:[Double?] = []
var ages:[Int] = []
var genders:[String] = []
var bios:[String] = []
var schools:[String?] = []
var addedPicsArrays:[[UIImage]] = []
var socialMediaAccountsArrays:[[String]] = []

var client = Client.shared!

let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

var navBarHeight:CGFloat = 0.0
var tabBarHeight:CGFloat = 0.0

var loadingAnimationImage:UIImage?

var peopleHasDoneInitialLoad = false
var notificationsHasDoneInitialLoad = false
var messagesHasDoneInitialLoad = false
var myRatesHasDoneInitialLoad = false

var offline = false

class People: UITableViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    var subscription1: Subscription<PFObject>?
    var subscription2: Subscription<PFObject>?
    
    var query1: PFQuery<PFObject>?
    var query2: PFQuery<PFObject>?
    
    let badgeQuery = PFQuery(className: "Badges")
    var badgeSubscription: Subscription<PFObject>?
    
    var loadingAnimationView = UIImageView()
    
    var noPeopleLabel = UILabel()
    var goToSettingsLabel = UILabel()

    override func viewDidLoad() {
        if !offline {
            startLoadingAnimation()
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        
        self.tableView.bounces = false
        
        noPeopleLabel.isUserInteractionEnabled = false
        goToSettingsLabel.isUserInteractionEnabled = false
        
        self.noPeopleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 40.0))
        self.goToSettingsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 60.0))
        self.noPeopleLabel.center = self.tableView.center
        self.goToSettingsLabel.center = self.tableView.center
        self.noPeopleLabel.center.y -= 20
        self.goToSettingsLabel.center.y += 20
        self.noPeopleLabel.textAlignment = .center
        self.goToSettingsLabel.textAlignment = .center
        self.noPeopleLabel.textColor = UIColor.clear
        self.goToSettingsLabel.textColor = UIColor.clear
        self.noPeopleLabel.font = UIFont.systemFont(ofSize: 25)
        self.goToSettingsLabel.font = UIFont.systemFont(ofSize: 21)
        self.noPeopleLabel.numberOfLines = 0
        self.goToSettingsLabel.numberOfLines = 0
        self.noPeopleLabel.text = "No users found"
        self.goToSettingsLabel.text = "Go to Settings to find more people"
        
        self.navigationController!.view.insertSubview(self.noPeopleLabel, belowSubview: self.navigationController!.navigationBar)
        self.navigationController!.view.insertSubview(self.goToSettingsLabel, belowSubview: self.navigationController!.navigationBar)
        
        registerForPushNotifications()
        
        badgeQuery.whereKey("userId", equalTo: PFUser.current()!.objectId!)
        
        badgeQuery.getFirstObjectInBackground { (badge, error) in
            if error == nil {
                if badge != nil {
                    let notificationsBadge = badge!.value(forKey: "notificationsBadge") as! Int
                    if notificationsBadge != 0 {
                        self.tabBarController!.tabBar.items![1].badgeValue = "\(notificationsBadge)"
                    }
                    let messagesBadge = badge!.value(forKey: "messagesBadge") as! Int
                    if messagesBadge != 0 {
                        self.tabBarController!.tabBar.items![2].badgeValue = "\(messagesBadge)"
                    }
                    
                    self.badgeSubscription = client.subscribe(self.badgeQuery)
                    
                    self.badgeSubscription!.handleEvent({ (_, event) in
                        if shouldUpdate {
                            switch event {
                            case .updated(let badge):
                                self.updateBadges(badge: badge)
                            default:
                                break
                            }
                        }
                    })
                }
            }
        }
        
        self.navigationItem.title = "People"
        /*
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        managedContext = appDelegate.persistentContainer.viewContext
        
        childContext.parent = managedContext!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Accounts")
        
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
        
        if let myLat = UserDefaults.standard.value(forKey: "myLocationLat") as? Double, let myLong = UserDefaults.standard.value(forKey: "myLocationLong") as? Double {
            myLocation = PFGeoPoint(latitude: myLat, longitude: myLong)
            useLocationToLoadDistances = true
        }
        
        if result.count > 0 {
            for user in result {
                let newUser = PFUser()
                if let latitude = user.value(forKey: "latitude") as? Double {
                    if let longitude = user.value(forKey: "longitude") as? Double {
                        let location = PFGeoPoint(latitude: latitude, longitude: longitude)
                        newUser["location"] = location
                        if useLocationToLoadDistances {
                            let distance = myLocation.distanceInMiles(to: location)
                            let distanceAwayRounded = round(10.0 * distance) / 10.0
                            distances.append(distanceAwayRounded)
                        } else {
                            distances.append(nil)
                        }
                    } else {
                        distances.append(nil)
                    }
                } else {
                    distances.append(nil)
                }
                
                let profilePic = UIImage(data: user.value(forKey: "profilePic") as! Data)
                let firstName = user.value(forKey: "firstName") as! String
                let lastName = user.value(forKey: "lastName") as! String
                var gender = "female"
                if user.value(forKey: "gender") as! Bool {
                    gender = "male"
                }
                let age = user.value(forKey: "age") as! Int
                let bio = user.value(forKey: "bio") as! String
                let username = user.value(forKey: "username") as! String
                let addedPicsData = user.value(forKey: "addedPics") as! [NSData]
                var addedPics:[UIImage] = []
                for addedPicData in addedPicsData {
                    let image = UIImage(data: addedPicData as Data)
                    addedPics.append(image!)
                }
                if let school = user.value(forKey: "school") as? String {
                    newUser["school"] = school
                    schools.append(school)
                } else {
                    schools.append(nil)
                }
                let socialMedia = user.value(forKey: "socialMedia") as! [String]
                
                var addedPicsDatas:[PFFile] = []
                
                for addedPic in addedPics {
                    addedPicsDatas.append(PFFile(data: UIImageJPEGRepresentation(addedPic, 0.5)!)!)
                }
                
                newUser.username = username.lowercased()
                newUser["name"] = firstName
                newUser["lastName"] = lastName
                newUser["fullName"] = "\(firstName.lowercased()) \(lastName.lowercased())"
                newUser["age"] = age
                newUser["gender"] = gender
                newUser["pic"] = PFFile(data: UIImageJPEGRepresentation(profilePic!, 0.5)!)
                newUser["addedPics"] = addedPicsDatas
                newUser["bio"] = bio
                if school != "" {
                    newUser["showSchools"] = [school]
                } else {
                    newUser["showSchools"] = []
                }
                newUser["genderPreference"] = "both"
                newUser["agePreference"] = [age-5, age+5]
                newUser["searchRadius"] = 5
                newUser["socialMedia"] = socialMedia
                
                newUser.acl?.hasPublicWriteAccess = true
                newUser.acl?.hasPublicReadAccess = true
                
                people.append(newUser)
                pics.append(profilePic!)
                names.append(firstName)
                lasts.append(lastName)
                genders.append(gender)
                ages.append(age)
                bios.append(bio)
                usernames.append(username)
                addedPicsArrays.append(addedPics)
                socialMediaAccountsArrays.append(socialMedia)
            }
            self.tableView.reloadData()
        }
 */
        
        var btn = UIButton(type: UIButtonType.system)
        var fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
        var title = NSAttributedString(string: (String(describing: NSString(utf8String: "\u{E805}")!)), attributes: fontStyle)
        btn.setAttributedTitle(title, for: UIControlState.normal)
        btn.tintColor = UIColor.black
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        btn.addTarget(self, action: #selector(People.search), for: UIControlEvents.touchUpInside)
        let left = UIBarButtonItem(customView: btn)
        self.navigationItem.leftBarButtonItem = left
        
        btn = UIButton(type: UIButtonType.system)
        fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
        title = NSAttributedString(string: (String(describing: NSString(utf8String: "\u{E804}")!)), attributes: fontStyle)
        btn.setAttributedTitle(title, for: UIControlState.normal)
        btn.tintColor = UIColor.black
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        btn.addTarget(self, action: #selector(People.settings), for: UIControlEvents.touchUpInside)
        let right = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem = right
        
        navBarHeight = self.navigationController!.navigationBar.frame.height+UIApplication.shared.statusBarFrame.height
        tabBarHeight = self.tabBarController!.tabBar.frame.height
    }
    
    func loadPeople() {
        self.query1 = PFUser.query()!
        if (PFUser.current()!.value(forKey: "showSchools") as! [String]).count != 0 {
            self.query1!.whereKey("school", containedIn: PFUser.current()?.value(forKey: "showSchools") as! [String])
        }
        let tempQuery1 = PFUser.query()!
        if (PFUser.current()!.value(forKey: "showSchools") as! [String]).count != 0 {
            tempQuery1.whereKey("school", containedIn: PFUser.current()?.value(forKey: "showSchools") as! [String])
        }
        let genderPref = PFUser.current()?.value(forKey: "genderPreference") as! String
        if genderPref == "male" {
            tempQuery1.whereKey("gender", equalTo: true)
        } else if genderPref == "female" {
            tempQuery1.whereKey("gender", equalTo: false)
        }
        let agePref = PFUser.current()?.value(forKey: "agePreference") as! [Int]
        tempQuery1.whereKey("age", greaterThan: agePref[0]-1)
        tempQuery1.whereKey("age", lessThan: agePref[1]+1)
        tempQuery1.whereKey("username", notEqualTo: PFUser.current()!.username!)
        
        var setVariables = false
        
        print("running queries")
        
        print("here 2")
        
        var tempPeople:[PFUser] = []
        var tempUsernames:[String] = []
        var tempPics:[UIImage] = []
        var tempNames:[String] = []
        var tempLasts:[String] = []
        var tempDistances:[Double?] = []
        var tempAges:[Int] = []
        var tempGenders:[String] = []
        var tempBios:[String] = []
        var tempSchools:[String?] = []
        var tempAddedPicsArrays:[[UIImage]] = []
        var tempSocialMediaAccountsArrays:[[String]] = []
        
        tempQuery1.limit = 1000
        
        tempQuery1.findObjectsInBackground(block: { (users, error) in
            if let accounts = users as? [PFUser] {
                for account in accounts {
                    if !tempPeople.contains(where: { (user) -> Bool in
                        return account.username! == user.username!
                    }) {
                        tempPeople.append(account)
                    }
                }
                
                for check in tempPeople {
                    if (check.value(forKey: "blockedUsers") as! [String]).contains(PFUser.current()!.username!) {
                        tempPeople.remove(at: tempPeople.firstIndex(of: check)!)
                    }
                }
                
                print("setVariables: \(setVariables)")
                if setVariables || !useLocationToLoadDistances {
                    if useLocationToLoadDistances {
                        tempPeople = tempPeople.sorted(by: { (user1, user2) -> Bool in
                            var distance1 = 0.0
                            var distance2 = 0.0
                            if let location1 = user1.value(forKey: "location") as? PFGeoPoint {
                                if let location2 = user2.value(forKey: "location") as? PFGeoPoint {
                                    distance1 = location1.distanceInMiles(to: myLocation)
                                    distance2 = location2.distanceInMiles(to: myLocation)
                                } else {
                                    return true
                                }
                            } else {
                                return false
                            }
                            
                            if distance1 < distance2 {
                                return true
                            } else {
                                return false
                            }
                        })
                    }
                    for person in tempPeople {
                        if useLocationToLoadDistances {
                            if let location = person.value(forKey: "location") as? PFGeoPoint {
                                let distance = myLocation.distanceInMiles(to: location)
                                let distanceAwayRounded = round(10.0 * distance) / 10.0
                                tempDistances.append(distanceAwayRounded)
                            } else {
                                tempDistances.append(nil)
                            }
                        } else {
                            tempDistances.append(nil)
                        }
                        let pic = person.value(forKey: "pic") as! PFFile
                        var pic2 = Data()
                        do {
                            pic2 = try pic.getData()
                        } catch {
                            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        tempPics.append(UIImage(data: pic2)!)
                        let name = person.value(forKey: "name") as! String
                        tempNames.append(name)
                        let last = person.value(forKey: "lastName") as! String
                        tempLasts.append(last)
                        var gender = "male"
                        let genderBool = person.value(forKey: "gender") as! Bool
                        if (genderBool) {
                            gender = "male"
                        } else {
                            gender = "female"
                        }
                        tempGenders.append(gender)
                        let bio = person.value(forKey: "bio") as! String
                        tempBios.append(bio)
                        let age = person.value(forKey: "age") as! Int
                        tempAges.append(age)
                        let username = person.username!
                        tempUsernames.append(username)
                        
                        let photoFiles = person.value(forKey: "addedPics") as! [PFFile]
                        
                        var photos:[UIImage] = []
                        
                        for photoFile in photoFiles {
                            var pic2 = Data()
                            do {
                                pic2 = try photoFile.getData()
                            } catch {
                                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            let photo = UIImage(data: pic2)!
                            
                            photos.append(photo)
                        }
                        
                        tempAddedPicsArrays.append(photos)
                        
                        if let school = person.value(forKey: "school") as? String {
                            tempSchools.append(school)
                        } else {
                            tempSchools.append(nil)
                        }
                        
                        if let socialMediaAccounts = person.value(forKey: "socialMedia") as? [String] {
                            tempSocialMediaAccountsArrays.append(socialMediaAccounts)
                        } else {
                            tempSocialMediaAccountsArrays.append([])
                        }
                    }
                    people = tempPeople
                    usernames = tempUsernames
                    pics = tempPics
                    names = tempNames
                    lasts = tempLasts
                    distances = tempDistances
                    ages = tempAges
                    genders = tempGenders
                    bios = tempBios
                    schools = tempSchools
                    addedPicsArrays = tempAddedPicsArrays
                    socialMediaAccountsArrays = tempSocialMediaAccountsArrays
                    
                    if people.count == 0 {
                        self.noPeopleLabel.textColor = UIColor.lightGray
                        self.goToSettingsLabel.textColor = UIColor.lightGray
                    } else {
                        self.noPeopleLabel.textColor = UIColor.clear
                        self.goToSettingsLabel.textColor = UIColor.clear
                    }
                    peopleHasDoneInitialLoad = true
                    
                    self.tableView.reloadData()
                    
                    client.reconnect()
                    
                    self.subscription1 = client.subscribe(self.query1!)
                    
                    self.subscription1!.handleEvent({ (_, event) in
                        if shouldUpdate {
                            switch event {
                            case .created(let object):
                                print("new person")
                                self.addPerson(object: object)
                            case .deleted(let object):
                                print("new person")
                                self.deletePerson(object: object)
                            case .entered(let object):
                                print("new person")
                                self.addPerson(object: object)
                            case .left(let object):
                                print("new person")
                                self.deletePerson(object: object)
                            case .updated(let object):
                                print("update")
                                self.updatePerson(object: object)
                            default:
                                break
                            }
                        }
                    })
                    if useLocationToLoadDistances {
                        self.subscription2 = client.subscribe(self.query2!)
                        
                        self.subscription2!.handleEvent({ (_, event) in
                            if shouldUpdate {
                                switch event {
                                case .created(let object):
                                    print("new person")
                                    self.addPerson(object: object)
                                case .deleted(let object):
                                    print("new person")
                                    self.deletePerson(object: object)
                                case .entered(let object):
                                    print("new person")
                                    self.addPerson(object: object)
                                case .left(let object):
                                    print("new person")
                                    self.deletePerson(object: object)
                                case .updated(let object):
                                    print("update")
                                    self.updatePerson(object: object)
                                default:
                                    break
                                }
                            }
                        })
                    }
                    
                    self.stopLoadingAnimation()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    // Create a background task
                    /*
                    childContext.perform {
                        // Perform tasks in a background queue
                        self.setPeopleCoreData()
                    }
 */
                    
                    setVariables = false
                } else {
                    setVariables = true
                }
            } else {
                print("stopLoadingAnimation")
                self.stopLoadingAnimation()
                UIApplication.shared.endIgnoringInteractionEvents()
                if error!.localizedDescription.contains("offline") {
                    self.stopLoadingAnimation()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    offline = true
                    self.noPeopleLabel.text = "You are offline"
                    self.noPeopleLabel.textColor = UIColor.lightGray
                } else {
                    let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
        
        if useLocationToLoadDistances {
            self.query2 = PFUser.query()!
            self.query2!.whereKey("location", nearGeoPoint: myLocation, withinMiles: Double(PFUser.current()!.value(forKey: "searchRadius") as! Int))
            let tempQuery2 = PFUser.query()!
            tempQuery2.whereKey("location", nearGeoPoint: myLocation, withinMiles: Double(PFUser.current()!.value(forKey: "searchRadius") as! Int))
            if genderPref == "male" {
                tempQuery2.whereKey("gender", equalTo: true)
            } else if genderPref == "female" {
                tempQuery2.whereKey("gender", equalTo: false)
            }
            tempQuery2.whereKey("age", greaterThan: agePref[0]-1)
            tempQuery2.whereKey("age", lessThan: agePref[1]+1)
            tempQuery2.whereKey("username", notEqualTo: PFUser.current()!.username!)
            
            tempQuery2.limit = 1000
            
            tempQuery2.findObjectsInBackground(block: { (users, error) in
                if let accounts = users as? [PFUser] {
                    for account in accounts {
                        if !tempPeople.contains(where: { (user) -> Bool in
                            return account.username! == user.username!
                        }) {
                            tempPeople.append(account)
                        }
                    }
                    
                    for check in tempPeople {
                        if (check.value(forKey: "blockedUsers") as! [String]).contains(PFUser.current()!.username!) {
                            tempPeople.remove(at: tempPeople.firstIndex(of: check)!)
                        }
                    }
                    
                    print("setVariables: \(setVariables)")
                    if setVariables {
                        if useLocationToLoadDistances {
                            tempPeople = tempPeople.sorted(by: { (user1, user2) -> Bool in
                                var distance1 = 0.0
                                var distance2 = 0.0
                                if let location1 = user1.value(forKey: "location") as? PFGeoPoint {
                                    if let location2 = user2.value(forKey: "location") as? PFGeoPoint {
                                        distance1 = location1.distanceInMiles(to: myLocation)
                                        distance2 = location2.distanceInMiles(to: myLocation)
                                    } else {
                                        return true
                                    }
                                } else {
                                    return false
                                }
                                
                                if distance1 < distance2 {
                                    return true
                                } else {
                                    return false
                                }
                            })
                        }
                        for person in tempPeople {
                            if useLocationToLoadDistances {
                                if let location = person.value(forKey: "location") as? PFGeoPoint {
                                    let distance = myLocation.distanceInMiles(to: location)
                                    let distanceAwayRounded = round(10.0 * distance) / 10.0
                                    tempDistances.append(distanceAwayRounded)
                                } else {
                                    tempDistances.append(nil)
                                }
                            } else {
                                tempDistances.append(nil)
                            }
                            let pic = person.value(forKey: "pic") as! PFFile
                            var pic2 = Data()
                            do {
                                pic2 = try pic.getData()
                            } catch {
                                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            tempPics.append(UIImage(data: pic2)!)
                            let name = person.value(forKey: "name") as! String
                            tempNames.append(name)
                            let last = person.value(forKey: "lastName") as! String
                            tempLasts.append(last)
                            var gender = "male"
                            let genderBool = person.value(forKey: "gender") as! Bool
                            if (genderBool) {
                                gender = "male"
                            } else {
                                gender = "female"
                            }
                            tempGenders.append(gender)
                            let bio = person.value(forKey: "bio") as! String
                            tempBios.append(bio)
                            let age = person.value(forKey: "age") as! Int
                            tempAges.append(age)
                            let username = person.username!
                            tempUsernames.append(username)
                            
                            let photoFiles = person.value(forKey: "addedPics") as! [PFFile]
                            
                            var photos:[UIImage] = []
                            
                            for photoFile in photoFiles {
                                var pic2 = Data()
                                do {
                                    pic2 = try photoFile.getData()
                                } catch {
                                    let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                                let photo = UIImage(data: pic2)!
                                
                                photos.append(photo)
                            }
                            
                            tempAddedPicsArrays.append(photos)
                            
                            if let school = person.value(forKey: "school") as? String {
                                tempSchools.append(school)
                            } else {
                                tempSchools.append(nil)
                            }
                            
                            if let socialMediaAccounts = person.value(forKey: "socialMedia") as? [String] {
                                tempSocialMediaAccountsArrays.append(socialMediaAccounts)
                            } else {
                                tempSocialMediaAccountsArrays.append([])
                            }
                        }
                        
                        people = tempPeople
                        usernames = tempUsernames
                        pics = tempPics
                        names = tempNames
                        lasts = tempLasts
                        distances = tempDistances
                        ages = tempAges
                        genders = tempGenders
                        bios = tempBios
                        schools = tempSchools
                        addedPicsArrays = tempAddedPicsArrays
                        socialMediaAccountsArrays = tempSocialMediaAccountsArrays
                        
                        if people.count == 0 {
                            self.noPeopleLabel.textColor = UIColor.lightGray
                            self.goToSettingsLabel.textColor = UIColor.lightGray
                        } else {
                            self.noPeopleLabel.textColor = UIColor.clear
                            self.goToSettingsLabel.textColor = UIColor.clear
                        }
                        peopleHasDoneInitialLoad = true
                        
                        self.tableView.reloadData()
                        
                        self.subscription1 = client.subscribe(self.query1!)
                        
                        self.subscription1!.handleEvent({ (_, event) in
                            if shouldUpdate {
                                switch event {
                                case .created(let object):
                                    print("new person")
                                    self.addPerson(object: object)
                                case .deleted(let object):
                                    print("new person")
                                    self.deletePerson(object: object)
                                case .entered(let object):
                                    print("new person")
                                    self.addPerson(object: object)
                                case .left(let object):
                                    print("new person")
                                    self.deletePerson(object: object)
                                case .updated(let object):
                                    print("update")
                                    self.updatePerson(object: object)
                                default:
                                    break
                                }
                            }
                        })
                        
                        if useLocationToLoadDistances {
                            self.subscription2 = client.subscribe(self.query2!)
                            
                            self.subscription2!.handleEvent({ (_, event) in
                                if shouldUpdate {
                                    switch event {
                                    case .created(let object):
                                        print("new person")
                                        self.addPerson(object: object)
                                    case .deleted(let object):
                                        print("new person")
                                        self.deletePerson(object: object)
                                    case .entered(let object):
                                        print("new person")
                                        self.addPerson(object: object)
                                    case .left(let object):
                                        print("new person")
                                        self.deletePerson(object: object)
                                    case .updated(let object):
                                        print("update")
                                        self.updatePerson(object: object)
                                    default:
                                        break
                                    }
                                }
                            })
                        }
                        
                        self.stopLoadingAnimation()
                        
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        // Create a background task
                        /*
                         childContext.perform {
                         // Perform tasks in a background queue
                         self.setPeopleCoreData()
                         }
                         */
                        
                        setVariables = false
                    } else {
                        setVariables = true
                    }
                } else {
                    print("stopLoadingAnimation")
                    self.stopLoadingAnimation()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func addPerson(object: PFObject) {
        if let person = object as? PFUser {
            var genderPrefArray:[Bool] = []
            switch(PFUser.current()?.value(forKey: "genderPreference") as! String) {
            case "male": genderPrefArray.append(true); break;
            case "female": genderPrefArray.append(false); break;
            default: genderPrefArray.append(true); genderPrefArray.append(false); break;
            }
            if genderPrefArray.contains(person.value(forKey: "gender") as! Bool) {
                let agePref = PFUser.current()?.value(forKey: "agePreference") as! [Int]
                if (person.value(forKey: "age") as! Int) > (agePref[0] - 1) && (person.value(forKey: "age") as! Int) < (agePref[1] + 1) {
                    if person.objectId! != PFUser.current()!.objectId! {
                        if !(person.value(forKey: "blockedUsers") as! [String]).contains(PFUser.current()!.username!) {
                            if !people.contains(where: { (user) -> Bool in
                                if user.objectId! == person.objectId! {
                                    return true
                                }
                                return false
                            }) {
                                self.noPeopleLabel.textColor = UIColor.clear
                                self.goToSettingsLabel.textColor = UIColor.clear
                                
                                var indexToUse = 0
                                
                                if useLocationToLoadDistances {
                                    var testPeople:[PFUser] = [person]
                                    testPeople.append(contentsOf: people.sorted(by: { (user1, user2) -> Bool in
                                        var distance1 = 0.0
                                        var distance2 = 0.0
                                        if let location1 = user1.value(forKey: "location") as? PFGeoPoint {
                                            if let location2 = user2.value(forKey: "location") as? PFGeoPoint {
                                                distance1 = location1.distanceInMiles(to: myLocation)
                                                distance2 = location2.distanceInMiles(to: myLocation)
                                            } else {
                                                return true
                                            }
                                        } else {
                                            return false
                                        }
                                        
                                        if distance1 < distance2 {
                                            return true
                                        } else {
                                            return false
                                        }
                                    }))
                                    indexToUse = testPeople.firstIndex(of: person)!
                                }
                                
                                people.insert(person, at: indexToUse)
                                if useLocationToLoadDistances {
                                    if let location = person.value(forKey: "location") as? PFGeoPoint {
                                        let distance = myLocation.distanceInMiles(to: location)
                                        let distanceAwayRounded = round(10.0 * distance) / 10.0
                                        distances.insert(distanceAwayRounded, at: indexToUse)
                                    } else {
                                        distances.insert(nil, at: indexToUse)
                                    }
                                } else {
                                    distances.insert(nil, at: indexToUse)
                                }
                                let pic = person.value(forKey: "pic") as! PFFile
                                var pic2 = Data()
                                do {
                                    pic2 = try pic.getData()
                                } catch {
                                    let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                                pics.insert(UIImage(data: pic2)!, at: indexToUse)
                                let name = person.value(forKey: "name") as! String
                                names.insert(name, at: indexToUse)
                                let last = person.value(forKey: "lastName") as! String
                                lasts.insert(last, at: indexToUse)
                                var gender = "male"
                                let genderBool = person.value(forKey: "gender") as! Bool
                                if (genderBool) {
                                    gender = "male"
                                } else {
                                    gender = "female"
                                }
                                genders.insert(gender, at: indexToUse)
                                let bio = person.value(forKey: "bio") as! String
                                bios.insert(bio, at: indexToUse)
                                let age = person.value(forKey: "age") as! Int
                                ages.insert(age, at: indexToUse)
                                let username = person.username!
                                usernames.insert(username, at: indexToUse)
                                
                                let photoFiles = person.value(forKey: "addedPics") as! [PFFile]
                                
                                var photos:[UIImage] = []
                                
                                for photoFile in photoFiles {
                                    var pic2 = Data()
                                    do {
                                        pic2 = try photoFile.getData()
                                    } catch {
                                        let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    let photo = UIImage(data: pic2)!
                                    
                                    photos.append(photo)
                                }
                                
                                addedPicsArrays.insert(photos, at: indexToUse)
                                
                                if let school = person.value(forKey: "school") as? String {
                                    schools.insert(school, at: indexToUse)
                                } else {
                                    schools.insert(nil, at: indexToUse)
                                }
                                
                                if let socialMediaAccounts = person.value(forKey: "socialMedia") as? [String] {
                                    socialMediaAccountsArrays.insert(socialMediaAccounts, at: indexToUse)
                                }
                                DispatchQueue.main.async {
                                    self.tableView.numberOfRows(inSection: 0)
                                    self.tableView.insertRows(at: [IndexPath(row: indexToUse, section: 0)], with: .right)
                                }
                                
                                // Create a background task
                                /*
                                 childContext.perform {
                                 // Perform tasks in a background queue
                                 self.setPeopleCoreData() // set up the database for the new game
                                 }
                                 */
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deletePerson(object: PFObject) {
        if let person = object as? PFUser {
            var genderPrefArray:[Bool] = []
            switch(PFUser.current()?.value(forKey: "genderPreference") as! String) {
            case "male": genderPrefArray.append(true); break;
            case "female": genderPrefArray.append(false); break;
            default: genderPrefArray.append(true); genderPrefArray.append(false); break;
            }
            if genderPrefArray.contains(person.value(forKey: "gender") as! Bool) {
                let agePref = PFUser.current()?.value(forKey: "agePreference") as! [Int]
                if (person.value(forKey: "age") as! Int) > (agePref[0] - 1) && (person.value(forKey: "age") as! Int) < (agePref[1] + 1) {
                    if person.objectId! != PFUser.current()!.objectId! {
                        if !(person.value(forKey: "blockedUsers") as! [String]).contains(PFUser.current()!.username!) {
                            var indexToDelete:Int?
                            for individual in people {
                                if individual.objectId! == person.objectId! {
                                    indexToDelete = people.index(of: individual)!
                                }
                            }
                            if let index = indexToDelete {
                                people.remove(at: index)
                                usernames.remove(at: index)
                                pics.remove(at: index)
                                names.remove(at: index)
                                lasts.remove(at: index)
                                distances.remove(at: index)
                                ages.remove(at: index)
                                genders.remove(at: index)
                                bios.remove(at: index)
                                schools.remove(at: index)
                                addedPicsArrays.remove(at: index)
                                socialMediaAccountsArrays.remove(at: index)
                                
                                DispatchQueue.main.async {
                                    self.tableView.numberOfRows(inSection: 0)
                                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
                                    if self.tableView.numberOfRows(inSection: 0) == 0 {
                                        self.noPeopleLabel.textColor = UIColor.lightGray
                                        self.goToSettingsLabel.textColor = UIColor.lightGray
                                    }
                                }
                                
                                // Create a background task
                                /*
                                childContext.perform {
                                    // Perform tasks in a background queue
                                    self.setPeopleCoreData() // set up the database for the new game
                                }
 */
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updatePerson(object: PFObject) {
        if let person = object as? PFUser {
            var userIndexToUpdate:Int?
            if !people.contains(where: { (user) -> Bool in
                if user.objectId! == person.objectId! {
                    userIndexToUpdate = people.firstIndex(of: user)!
                    return true
                }
                return false
            }) {
                if !(person.value(forKey: "blockedUsers") as! [String]).contains(PFUser.current()!.username!) {
                    addPerson(object: object)
                }
            } else {
                if (person.value(forKey: "blockedUsers") as! [String]).contains(PFUser.current()!.username!) {
                    deletePersonImmediately(person: person)
                } else {
                    if let indexToUpdate = userIndexToUpdate {
                        people.remove(at: indexToUpdate)
                        usernames.remove(at: indexToUpdate)
                        pics.remove(at: indexToUpdate)
                        names.remove(at: indexToUpdate)
                        lasts.remove(at: indexToUpdate)
                        distances.remove(at: indexToUpdate)
                        ages.remove(at: indexToUpdate)
                        genders.remove(at: indexToUpdate)
                        bios.remove(at: indexToUpdate)
                        schools.remove(at: indexToUpdate)
                        addedPicsArrays.remove(at: indexToUpdate)
                        socialMediaAccountsArrays.remove(at: indexToUpdate)
                        
                        people.insert(person, at: indexToUpdate)
                        if useLocationToLoadDistances {
                            if let location = person.value(forKey: "location") as? PFGeoPoint {
                                let distance = myLocation.distanceInMiles(to: location)
                                let distanceAwayRounded = round(10.0 * distance) / 10.0
                                distances.insert(distanceAwayRounded, at: 0)
                            } else {
                                distances.insert(nil, at: indexToUpdate)
                            }
                        } else {
                            distances.insert(nil, at: indexToUpdate)
                        }
                        let pic = person.value(forKey: "pic") as! PFFile
                        var pic2 = Data()
                        do {
                            pic2 = try pic.getData()
                        } catch {
                            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        pics.insert(UIImage(data: pic2)!, at: indexToUpdate)
                        let name = person.value(forKey: "name") as! String
                        names.insert(name, at: indexToUpdate)
                        let last = person.value(forKey: "lastName") as! String
                        lasts.insert(last, at: indexToUpdate)
                        var gender = "male"
                        let genderBool = person.value(forKey: "gender") as! Bool
                        if (genderBool) {
                            gender = "male"
                        } else {
                            gender = "female"
                        }
                        genders.insert(gender, at: indexToUpdate)
                        let bio = person.value(forKey: "bio") as! String
                        bios.insert(bio, at: indexToUpdate)
                        let age = person.value(forKey: "age") as! Int
                        ages.insert(age, at: indexToUpdate)
                        let username = person.username!
                        usernames.insert(username, at: indexToUpdate)
                        
                        let photoFiles = person.value(forKey: "addedPics") as! [PFFile]
                        
                        var photos:[UIImage] = []
                        
                        for photoFile in photoFiles {
                            var pic2 = Data()
                            do {
                                pic2 = try photoFile.getData()
                            } catch {
                                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            let photo = UIImage(data: pic2)!
                            
                            photos.append(photo)
                        }
                        
                        addedPicsArrays.insert(photos, at: indexToUpdate)
                        
                        if let school = person.value(forKey: "school") as? String {
                            schools.insert(school, at: indexToUpdate)
                        } else {
                            schools.insert(nil, at: indexToUpdate)
                        }
                        
                        if let socialMediaAccounts = person.value(forKey: "socialMedia") as? [String] {
                            socialMediaAccountsArrays.insert(socialMediaAccounts, at: indexToUpdate)
                        }
                        DispatchQueue.main.async {
                            self.tableView.numberOfRows(inSection: 0)
                            self.tableView.reloadRows(at: [IndexPath(row: indexToUpdate, section: 0)], with: .automatic)
                        }
                        
                        // Create a background task
                        /*
                        childContext.perform {
                            // Perform tasks in a background queue
                            self.setPeopleCoreData() // set up the database for the new game
                        }
 */
 
                    }
                }
            }
        }
    }
    
    func addPersonImmediately(person: PFUser) {
        var indexToUse = 0
        
        if useLocationToLoadDistances {
            var testPeople:[PFUser] = [person]
            testPeople.append(contentsOf: people.sorted(by: { (user1, user2) -> Bool in
                var distance1 = 0.0
                var distance2 = 0.0
                if let location1 = user1.value(forKey: "location") as? PFGeoPoint {
                    if let location2 = user2.value(forKey: "location") as? PFGeoPoint {
                        distance1 = location1.distanceInMiles(to: myLocation)
                        distance2 = location2.distanceInMiles(to: myLocation)
                    } else {
                        return true
                    }
                } else {
                    return false
                }
                
                if distance1 < distance2 {
                    return true
                } else {
                    return false
                }
            }))
            indexToUse = testPeople.firstIndex(of: person)!
        }
        
        people.insert(person, at: indexToUse)
        if useLocationToLoadDistances {
            if let location = person.value(forKey: "location") as? PFGeoPoint {
                let distance = myLocation.distanceInMiles(to: location)
                let distanceAwayRounded = round(10.0 * distance) / 10.0
                distances.insert(distanceAwayRounded, at: indexToUse)
            } else {
                distances.insert(nil, at: indexToUse)
            }
        }
        let pic = person.value(forKey: "pic") as! PFFile
        var pic2 = Data()
        do {
            pic2 = try pic.getData()
        } catch {
            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        self.noPeopleLabel.textColor = UIColor.clear
        self.goToSettingsLabel.textColor = UIColor.clear
        
        pics.insert(UIImage(data: pic2)!, at: indexToUse)
        let name = person.value(forKey: "name") as! String
        names.insert(name, at: indexToUse)
        let last = person.value(forKey: "lastName") as! String
        lasts.insert(last, at: indexToUse)
        var gender = "male"
        let genderBool = person.value(forKey: "gender") as! Bool
        if (genderBool) {
            gender = "male"
        } else {
            gender = "female"
        }
        genders.insert(gender, at: indexToUse)
        let bio = person.value(forKey: "bio") as! String
        bios.insert(bio, at: indexToUse)
        let age = person.value(forKey: "age") as! Int
        ages.insert(age, at: indexToUse)
        let username = person.username!
        usernames.insert(username, at: indexToUse)
        
        let photoFiles = person.value(forKey: "addedPics") as! [PFFile]
        
        var photos:[UIImage] = []
        
        for photoFile in photoFiles {
            var pic2 = Data()
            do {
                pic2 = try photoFile.getData()
            } catch {
                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let photo = UIImage(data: pic2)!
            
            photos.append(photo)
        }
        
        addedPicsArrays.insert(photos, at: indexToUse)
        
        if let school = person.value(forKey: "school") as? String {
            schools.insert(school, at: indexToUse)
        } else {
            schools.insert(nil, at: indexToUse)
        }
        
        if let socialMediaAccounts = person.value(forKey: "socialMedia") as? [String] {
            socialMediaAccountsArrays.insert(socialMediaAccounts, at: indexToUse)
        }
        DispatchQueue.main.async {
            self.tableView.numberOfRows(inSection: 0)
            self.tableView.insertRows(at: [IndexPath(row: indexToUse, section: 0)], with: .right)
        }
    }
    
    func deletePersonImmediately(person: PFUser) {
        var indexToDelete:Int?
        for individual in people {
            if individual.objectId! == person.objectId! {
                indexToDelete = people.index(of: individual)!
            }
        }
        if let index = indexToDelete {
            people.remove(at: index)
            usernames.remove(at: index)
            pics.remove(at: index)
            names.remove(at: index)
            lasts.remove(at: index)
            distances.remove(at: index)
            ages.remove(at: index)
            genders.remove(at: index)
            bios.remove(at: index)
            schools.remove(at: index)
            addedPicsArrays.remove(at: index)
            socialMediaAccountsArrays.remove(at: index)
            
            DispatchQueue.main.async {
                self.tableView.numberOfRows(inSection: 0)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
                
                if self.tableView.numberOfRows(inSection: 0) == 0 {
                    self.noPeopleLabel.textColor = UIColor.lightGray
                    self.goToSettingsLabel.textColor = UIColor.lightGray
                }
            }
        }
    }
    
    func setPeopleCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Accounts")
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
        for person in people {
            print("adding person")
            let user = NSEntityDescription.insertNewObject(forEntityName: "Accounts", into: childContext)
            
            user.setValue(person.objectId!, forKey: "objectId")
            
            // Set core data with optional location and school
            
            if let location = person.value(forKey: "location") as? PFGeoPoint {
                user.setValue(location.latitude, forKey: "latitude")
                user.setValue(location.longitude, forKey: "longitude")
            }
            
            user.setValue(NSData(data: UIImageJPEGRepresentation(pics[count], 0.5)!), forKey: "profilePic")
            user.setValue(names[count], forKey: "firstName")
            user.setValue(lasts[count], forKey: "lastName")
            if genders[count] == "male" {
                user.setValue(true, forKey: "gender")
            } else {
                user.setValue(false, forKey: "gender")
            }
            user.setValue(ages[count], forKey: "age")
            user.setValue(bios[count], forKey: "bio")
            user.setValue(usernames[count], forKey: "username")
            var coreDataPhotos:[NSData] = []
            
            for photoFile in addedPicsArrays[count] {
                let pic2 = UIImageJPEGRepresentation(photoFile, 0.5)!
                coreDataPhotos.append(NSData(data: pic2))
            }
            user.setValue(coreDataPhotos, forKey: "addedPics")
            
            if let school = schools[count] {
                user.setValue(school, forKey: "school")
            }
            user.setValue(socialMediaAccountsArrays[count], forKey: "socialMedia")
            user.setValue(count, forKey: "sortNum")
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
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double(Float.leastNormalMagnitude)))
        
        self.tableView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        self.tableView.reloadData()
        
        if shouldReloadPeople {
            shouldReloadPeople = false
            
            startLoadingAnimation()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            self.loadPeople()
        }
        if !offline {
            if people.count == 0 {
                if peopleHasDoneInitialLoad {
                    noPeopleLabel.textColor = UIColor.lightGray
                    goToSettingsLabel.textColor = UIColor.lightGray
                }
            } else {
                noPeopleLabel.textColor = UIColor.clear
                goToSettingsLabel.textColor = UIColor.clear
            }
        } else {
            noPeopleLabel.text = "You are offline"
            noPeopleLabel.textColor = UIColor.lightGray
            goToSettingsLabel.textColor = UIColor.clear
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        print("requesting wheninuseauthorization")
        self.locationManager.requestWhenInUseAuthorization()
        if openedFromMainScreen {
            openedFromMainScreen = false
            self.locationManager.requestLocation()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    @objc func settings() {
        self.performSegue(withIdentifier: "settings", sender: self)
    }
    
    @objc func search() {
        self.performSegue(withIdentifier: "search", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        fromNotifications = false
        shouldShowRateButton = true
        
        let userNumber = indexPath.row
        
        userToDisplay = people[userNumber]
        
        picToDisplay = pics[userNumber]
        
        nameToDisplay = names[userNumber]
        
        lastToDisplay = lasts[userNumber]
        
        if distances[userNumber] != nil {
            distanceToDisplay = distances[userNumber]
        } else {
            distanceToDisplay = nil
        }
        
        ageToDisplay = ages[userNumber]
        
        genderToDisplay = genders[userNumber]
        
        if schools[userNumber] != nil {
            schoolToDisplay = schools[userNumber]
        } else {
            schoolToDisplay = nil
        }
        
        bioToDisplay = bios[userNumber]
        
        usernameToDisplay = usernames[userNumber]
        
        addedPicsArrayToDisplay.removeAll()
        
        addedPicsArrayToDisplay = addedPicsArrays[userNumber]
        
        socialMediaAccountsArrayToDisplay = socialMediaAccountsArrays[userNumber]
        
        self.performSegue(withIdentifier: "profile", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath); cell.selectionStyle = .none
        print("index \(indexPath.row)")
        
        (cell.viewWithTag(2) as! UIImageView).image = pics[indexPath.row]
        (cell.viewWithTag(2) as! UIImageView).layer.masksToBounds = true
        (cell.viewWithTag(2) as! UIImageView).layer.cornerRadius = (cell.viewWithTag(2) as! UIImageView).frame.width/2
        (cell.viewWithTag(2) as! UIImageView).layer.borderColor = UIColor.black.cgColor
        (cell.viewWithTag(2) as! UIImageView).layer.borderWidth = 1.0
        (cell.viewWithTag(3) as! UILabel).text = "\(names[indexPath.row]) \(lasts[indexPath.row])"
        if distances[indexPath.row] != nil && schools[indexPath.row] != nil {
            (cell.viewWithTag(5) as! UILabel).text = "\(distances[indexPath.row]!) mi, \(schools[indexPath.row]!)"
        } else if schools[indexPath.row] != "" && schools[indexPath.row] != nil {
            (cell.viewWithTag(5) as! UILabel).text = "\(schools[indexPath.row]!)"
        } else if distances[indexPath.row] != nil {
            (cell.viewWithTag(5) as! UILabel).text = "\(distances[indexPath.row]!) mi, \(bios[indexPath.row])"
        } else {
            (cell.viewWithTag(5) as! UILabel).text = "\(bios[indexPath.row])"
        }
        
        return cell
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        } else {
            PFUser.current()!.fetchInBackground { (user, error) in
                if error == nil {
                    self.loadPeople()
                } else {
                    if error!.localizedDescription.contains("offline") {
                        self.stopLoadingAnimation()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        offline = true
                        self.noPeopleLabel.text = "You are offline"
                        self.noPeopleLabel.textColor = UIColor.lightGray
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let place = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            UserDefaults.standard.setValue(place.latitude, forKey: "myLocationLat")
            UserDefaults.standard.setValue(place.longitude, forKey: "myLocationLong")
            myLocation = place
            useLocationToLoadDistances = true
            PFUser.current()?.setValue(place, forKey: "location")
            PFUser.current()?.saveInBackground()
            PFUser.current()!.fetchInBackground { (user, error) in
                if error == nil {
                    self.loadPeople()
                } else {
                    if error!.localizedDescription.contains("offline") {
                        self.stopLoadingAnimation()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        offline = true
                        self.noPeopleLabel.text = "You are offline"
                        self.noPeopleLabel.textColor = UIColor.lightGray
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        PFUser.current()!.fetchInBackground { (user, error) in
            if error == nil {
                self.loadPeople()
            } else {
                if error!.localizedDescription.contains("offline") {
                    self.stopLoadingAnimation()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    offline = true
                    self.noPeopleLabel.text = "You are offline"
                    self.noPeopleLabel.textColor = UIColor.lightGray
                }
            }
        }
        let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func registerForPushNotifications() {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                guard granted else { return }
                print("happening 1")
                self.getNotificationSettings()
            }
        }
    }
    
    func getNotificationSettings() {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    print("happening 2")
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func updateBadges(badge: PFObject) {
        DispatchQueue.main.async {
            let notificationsBadge = badge.value(forKey: "notificationsBadge") as! Int
            if notificationsBadge != 0 {
                self.tabBarController!.tabBar.items![1].badgeValue = "\(notificationsBadge)"
            }
            let messagesBadge = badge.value(forKey: "messagesBadge") as! Int
            if messagesBadge != 0 {
                self.tabBarController!.tabBar.items![2].badgeValue = "\(messagesBadge)"
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.noPeopleLabel.textColor = UIColor.clear
        self.goToSettingsLabel.textColor = UIColor.clear
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
