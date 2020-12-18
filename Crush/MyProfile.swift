//
//  MyProfile.swift
//  rate
//
//  Created by James McGivern on 1/23/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse
import CoreData

var isMyProfile = false
var myAddedPicsArrayFiles:[PFFile] = []

class MyProfile: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var details: UILabel!
    @IBOutlet var school: UILabel!
    @IBOutlet var bio: UILabel!
    @IBOutlet var addedPhotos: UICollectionView!
    
    var loadingAnimationView = UIImageView()
    
    override func viewDidLoad() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        startLoadingAnimation()
        
        self.loadFromUserDefaults()
        
        if !justMadeAccount && !offline {
            let pic = PFUser.current()!.value(forKey: "pic") as! PFFile
            var pic2 = Data()
            do {
                pic2 = try pic.getData()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            UserDefaults.standard.setValue(NSData(data: pic2), forKey: "profilePic")
            myPic = UIImage(data: pic2)!
            UserDefaults.standard.setValue(PFUser.current()!.value(forKey: "name") as! String, forKey: "name")
            myName = PFUser.current()!.value(forKey: "name") as! String
            UserDefaults.standard.setValue(PFUser.current()!.value(forKey: "lastName") as! String, forKey: "lastName")
            myLast = PFUser.current()!.value(forKey: "lastName") as! String
            var gender = "female"
            if (PFUser.current()!.value(forKey: "gender") as! Bool) {
                gender = "male"
            }
            UserDefaults.standard.setValue(PFUser.current()!.value(forKey: "gender") as! Bool, forKey: "gender")
            myGender = gender
            UserDefaults.standard.setValue(PFUser.current()!.value(forKey: "bio") as! String, forKey: "bio")
            myBio = PFUser.current()!.value(forKey: "bio") as! String
            UserDefaults.standard.setValue(PFUser.current()!.value(forKey: "age") as! Int, forKey: "age")
            myAge = PFUser.current()!.value(forKey: "age") as! Int
            UserDefaults.standard.setValue(PFUser.current()!.username!, forKey: "username")
            myUsername = PFUser.current()!.username!
            
            let photoFiles = PFUser.current()!.value(forKey: "addedPics") as! [PFFile]
            myAddedPicsArrayFiles = photoFiles
            
            myAddedPicsArray.removeAll()
            
            var defaultPicsArray:[NSData] = []
            
            for photoFile in photoFiles {
                var pic2 = Data()
                do {
                    pic2 = try photoFile.getData()
                    defaultPicsArray.append(NSData(data: pic2))
                } catch {
                    let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                let photo = UIImage(data: pic2)!
                
                myAddedPicsArray.append(photo)
            }
            
            UserDefaults.standard.setValue(defaultPicsArray, forKey: "addedPics")
            
            if let meSchool = PFUser.current()!.value(forKey: "school") as? String {
                UserDefaults.standard.setValue(meSchool, forKey: "school")
                mySchool = meSchool
            } else {
                mySchool = "No School"
            }
            
            if let meSocialMediaAccounts = PFUser.current()!.value(forKey: "socialMedia") as? [String] {
                UserDefaults.standard.setValue(meSocialMediaAccounts, forKey: "socialMedia")
                mySocialMediaAccounts = meSocialMediaAccounts
            }
            
            isMyProfile = true
            
            self.navigationItem.title = myUsername
            
            self.profilePic.image = myPic
            
            self.name.text = "\(myName) \(myLast)"
            
            self.details.text = "Age \(myAge), \(myGender)"
            
            self.school.text = mySchool
            
            self.bio.text = myBio
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            backItem.tintColor = UIColor.black
            self.navigationItem.backBarButtonItem = backItem
            
            self.update()
            self.stopLoadingAnimation()
            UIApplication.shared.endIgnoringInteractionEvents()
        } else {
            isMyProfile = true
            
            self.navigationItem.title = myUsername
            
            self.profilePic.image = myPic
            
            self.name.text = "\(myName) \(myLast)"
            
            self.details.text = "Age \(myAge), \(myGender)"
            
            self.school.text = mySchool
            
            self.bio.text = myBio
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            backItem.tintColor = UIColor.black
            self.navigationItem.backBarButtonItem = backItem
            
            self.update()
            
            
            UserDefaults.standard.setValue(NSData(data: UIImageJPEGRepresentation(myPic!, 0.5)!), forKey: "profilePic")
            UserDefaults.standard.setValue(myName, forKey: "name")
            UserDefaults.standard.setValue(myLast, forKey: "lastName")
            UserDefaults.standard.setValue(myGender == "male", forKey: "gender")
            UserDefaults.standard.setValue(myBio, forKey: "bio")
            UserDefaults.standard.setValue(myAge, forKey: "age")
            UserDefaults.standard.setValue(myUsername, forKey: "username")
            var myAddedPicsArrayData:[NSData] = []
            for myAddedPic in myAddedPicsArray {
                myAddedPicsArrayData.append(NSData(data: UIImageJPEGRepresentation(myAddedPic, 0.5)!))
            }
            UserDefaults.standard.setValue(myAddedPicsArrayData, forKey: "addedPics")
            if mySchool != "No School" {
                UserDefaults.standard.setValue(mySchool, forKey: "school")
            }
            UserDefaults.standard.setValue(mySocialMediaAccounts, forKey: "socialMedia")
            
            self.stopLoadingAnimation()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        /*
        var tempRates:[PFObject] = []
        var tempRatePics:[UIImage] = []
        var tempRateFirsts:[String] = []
        var tempRateLasts:[String] = []
        var tempRateValues:[Int] = []
        
        let ratesQuery = PFQuery(className: "Rates")
        ratesQuery.whereKey("from", equalTo: PFUser.current()!)
        ratesQuery.limit = 1000
        
        ratesQuery.findObjectsInBackground { (unsortedRates, error) in
            print("here 1")
            if var myRates = unsortedRates {
                myRates.sort(by: { (object1, object2) -> Bool in
                    return (object1.value(forKey: "interestLevel") as! Int) <= (object2.value(forKey: "interestLevel") as! Int)
                })
                
                for rate in myRates {
                    tempRates.append(rate)
                    let to = rate.value(forKey: "to") as! PFUser
                    
                    do {
                        try to.fetchIfNeeded()
                    } catch {
                        let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    do {
                        tempRatePics.append(UIImage(data: try (to.value(forKey: "pic") as! PFFile).getData())!)
                    } catch {
                        let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    tempRateFirsts.append(to.value(forKey: "name") as! String)
                    tempRateLasts.append(to.value(forKey: "lastName") as! String)
                    tempRateValues.append((rate.value(forKey: "interestLevel") as! NSNumber).intValue)
                }
                
                rates = tempRates
                ratePics = tempRatePics
                rateFirsts = tempRateFirsts
                rateLasts = tempRateLasts
                rateValues = tempRateValues
                
                shouldLoadCoreData = false
                
                // Create a background task
                /*
                childContext.perform {
                    // Perform tasks in a background queue
                    self.setMyRatesCoreData() // set up the database for the new game
                }
 */
            } else {
                let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
 */
    }
    
    func setMyRatesCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Rates")
        request.returnsObjectsAsFaults = false
        
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
        var count = 0
        for rate in rates {
            let cdRate = NSEntityDescription.insertNewObject(forEntityName: "Rates", into: managedContext!)
            
            cdRate.setValue(rate.objectId!, forKey: "objectId")
            
            let to = rate.value(forKey: "to") as! PFUser
            
            do {
                try to.fetchIfNeeded()
            } catch {
                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            do {
                cdRate.setValue(NSData(data: try (to.value(forKey: "pic") as! PFFile).getData()), forKey: "pic")
            } catch {
                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            cdRate.setValue(to.value(forKey: "name") as! String, forKey: "first")
            cdRate.setValue(to.value(forKey: "lastName") as! String, forKey: "last")
            cdRate.setValue((rate.value(forKey: "interestLevel") as! NSNumber).doubleValue, forKey: "interest")
            cdRate.setValue(count, forKey: "sortNum")
            count += 1
        }
        
        do {
            try managedContext?.save()
        } catch {
            let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func startLoadingAnimation() {
        loadingAnimationView = UIImageView()
        loadingAnimationView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-50, height: (self.view.frame.width-50)*0.73)
        loadingAnimationView.center = self.view.center
        
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
        isMyProfile = true
        
        self.navigationItem.title = myUsername
        
        self.profilePic.image = myPic
        
        self.name.text = "\(myName) \(myLast)"
        
        self.details.text = "Age \(myAge), \(myGender)"
        
        self.school.text = mySchool
        
        self.bio.text = myBio
        
        self.addedPhotos.reloadData()
    }
    
    func loadFromUserDefaults() {
        var btn = UIButton(type: UIButtonType.system)
        var fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 25)!]
        var title = NSAttributedString(string: (String(describing: NSString(utf8String: "\u{E804}")!)), attributes: fontStyle)
        btn.setAttributedTitle(title, for: UIControlState.normal)
        btn.tintColor = UIColor.black
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        btn.addTarget(self, action: #selector(MyProfile.settings), for: UIControlEvents.touchUpInside)
        let right = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem = right
        
        btn = UIButton(type: UIButtonType.system)
        fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 27)!]
        title = NSAttributedString(string: (String(describing: NSString(utf8String: "\u{E80C}")!)), attributes: fontStyle)
        btn.setAttributedTitle(title, for: UIControlState.normal)
        btn.tintColor = UIColor.black
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(MyProfile.myRates), for: UIControlEvents.touchUpInside)
        let left = UIBarButtonItem(customView: btn)
        self.navigationItem.leftBarButtonItem = left
        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderColor = UIColor.black.cgColor
        self.profilePic.layer.borderWidth = 2.0
        
        profilePic.isUserInteractionEnabled = true
        let tapped = UITapGestureRecognizer(target: self, action: #selector(Profile.tapped))
        profilePic.addGestureRecognizer(tapped)
        
        isMyProfile = true
        
        if let uname = UserDefaults.standard.value(forKey: "username") as? String {
            myUsername = uname
            self.navigationItem.title = uname
        }
        
        if let proPic = UserDefaults.standard.value(forKey: "profilePic") as? NSData {
            myPic = UIImage(data: proPic as Data)!
            self.profilePic.image = UIImage(data: proPic as Data)!
        }
        
        if let firstName = UserDefaults.standard.value(forKey: "name") as? String, let lastName = UserDefaults.standard.value(forKey: "lastName") as? String {
            myName = firstName
            myLast = lastName
            self.name.text = "\(firstName) \(lastName)"
        }
        
        if let age = UserDefaults.standard.value(forKey: "age") as? Int, let gender = UserDefaults.standard.value(forKey: "gender") as? Bool {
            myAge = age
            if gender {
                myGender = "male"
            } else {
                myGender = "female"
            }
            self.details.text = "Age \(age), \(myGender)"
        }
        
        if let scho = UserDefaults.standard.value(forKey: "school") as? String {
            mySchool = scho
            self.school.text = mySchool
        } else {
            mySchool = "No School"
            self.school.text = mySchool
        }
        
        if let descript = UserDefaults.standard.value(forKey: "bio") as? String {
            myBio = descript
            self.bio.text = descript
        }
        
        if let addedDatas = UserDefaults.standard.value(forKey: "addedPics") as? [NSData] {
            var addedPhotos:[UIImage] = []
            for addedData in addedDatas {
                addedPhotos.append(UIImage(data: addedData as Data)!)
            }
            myAddedPicsArray = addedPhotos
            self.update()
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        self.navigationItem.backBarButtonItem = backItem
    }
    
    @objc func myRates() {
        self.performSegue(withIdentifier: "myRates", sender: self)
    }
    
    @objc func settings() {
        self.performSegue(withIdentifier: "settings", sender: self)
    }
    
    @objc func tapped() {
        displayProfilePic = true
        
        self.performSegue(withIdentifier: "viewImage", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = addedPhotos.cellForItem(at: indexPath)
        displayProfilePic = false
        photoNumber = cell!.tag - 2
        
        self.performSegue(withIdentifier: "viewImage", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myAddedPicsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = addedPhotos.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.tag = indexPath.item+2
        
        let pic = myAddedPicsArray[indexPath.item]
        
        (cell.viewWithTag(1) as! UIImageView).image = pic
        
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
        
        self.addedPhotos.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
