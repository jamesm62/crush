//
//  ZipCode.swift
//  rate
//
//  Created by James McGivern on 12/15/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit
import MapKit
import Parse

var justMadeAccount = false

class Location: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var updatingLocationLabel: UILabel!
    
    var saveLocation = false
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func done() {
        updatingLocationLabel.text = "Creating profile..."
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        var addedPicsData:[PFFile] = []
        
        for addedPic in addedPics {
            addedPicsData.append(PFFile(data: UIImageJPEGRepresentation(addedPic, 0.5)!)!)
        }
        
        let newUser = PFUser()
        
        newUser.username = username
        newUser.password = pass
        newUser["name"] = name
        newUser["lastName"] = last
        newUser["fullName"] = "\(name.lowercased()) \(last.lowercased())"
        newUser["age"] = age
        newUser["gender"] = gender
        newUser["pic"] = PFFile(data: UIImageJPEGRepresentation(pic, 0.5)!)
        newUser["addedPics"] = addedPicsData
        if let scho = school {
            newUser["school"] = scho
        }
        newUser["showSchools"] = []
        newUser["bio"] = descrip
        if saveLocation {
            newUser["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
        }
        newUser["genderPreference"] = "both"
        /*
        if age > 20 {
            newUser["agePreference"] = [age-3, age+3]
        } else {
            newUser["agePreference"] = [18, age+3]
        }
 */
        newUser["agePreference"] = [18, 70]
        newUser["searchRadius"] = 10
        newUser["socialMedia"] = socialMediaAccounts
        newUser["blockedUsers"] = []
        
        newUser.acl?.hasPublicWriteAccess = true
        newUser.acl?.hasPublicReadAccess = true
        
        newUser.signUpInBackground(block: { (success, error) in
            if success {
                let badge = PFObject(className: "Badges")
                badge.setValue(newUser.objectId!, forKey: "userId")
                badge.setValue(0, forKey: "notificationsBadge")
                badge.setValue(0, forKey: "messagesBadge")
                var reports = [Int]()
                for _ in addedPics {
                    reports.append(0)
                }
                badge["reports"] = reports
                badge["profilePicReports"] = 0
                badge.acl?.hasPublicReadAccess = true
                badge.acl?.hasPublicWriteAccess = true
                badge.saveInBackground()
                if self.saveLocation {
                    useLocationToLoadDistances = true
                } else {
                    useLocationToLoadDistances = false
                }
                shouldUpdate = true
                
                // justMadeAccount and set "my" variables
                
                justMadeAccount = true
                
                myUser = newUser
                myUsername = username.lowercased()
                myPic = pic
                myName = name
                myLast = last
                myAge = age
                myGender = "female"
                if gender {
                    myGender = "male"
                }
                myBio = descrip
                if school != nil {
                    mySchool = school!
                } else {
                    mySchool = "No School"
                }
                myAddedPicsArray = addedPics
                mySocialMediaAccounts = socialMediaAccounts
                
                UIApplication.shared.endIgnoringInteractionEvents()
                let storyboard = UIStoryboard(name: "App", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "App") as UIViewController
                self.present(vc, animated: true, completion: nil)
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
                if let err = error {
                    let alert = UIAlertController(title: "Oops", message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updatingLocationLabel.text = "Updating location..."
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        } else {
            useLocationToLoadDistances = false
            
            saveLocation = false
            
            done()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.20, 0.20)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            map.setRegion(region, animated: true)
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            
            saveLocation = true
            
            done()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
