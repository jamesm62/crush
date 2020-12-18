//
//  Search.swift
//  rate
//
//  Created by James McGivern on 1/5/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

var searchPeople:[PFUser] = []
var searchUsernames:[String] = []
var searchPics:[UIImage] = []
var searchNames:[String] = []
var searchLasts:[String] = []
var searchFullNames:[String] = []
var searchDistances:[Double?] = []
var searchAges:[Int] = []
var searchGenders:[String] = []
var searchBios:[String] = []
var searchSchools:[String?] = []
var searchAddedPicsArrays:[[UIImage]] = []
var searchSocialMediaAccountsArrays:[[String]] = []

class Search: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var searchUserNumber = 0

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var query = PFUser.query()
    
    var keyboardHeight = CGFloat(0.0)
    var shouldUseKeyboardHeight = false
    
    override func viewDidLoad() {
        self.tableView.bounces = false
        
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
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        query?.cancel()
        if let search = searchBar.text {
            if search == "" {
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
                self.tableView.reloadData()
            } else {
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
                query = PFUser.query()
                query?.whereKey("fullName", hasPrefix: search.lowercased())
                query?.whereKey("username", notEqualTo: PFUser.current()!.username!)
                query?.limit = 20
                query?.findObjectsInBackground(block: { (objects, error) in
                    if var users = objects as? [PFUser] {
                        for check in users {
                            if (check.value(forKey: "blockedUsers") as! [String]).contains(PFUser.current()!.username!) {
                                users.remove(at: users.firstIndex(of: check)!)
                            }
                        }
                        var unsortedPeople:[PFUser] = []
                        unsortedPeople.append(contentsOf: users)
                        searchPeople = unsortedPeople.sorted(by: { (user1, user2) -> Bool in
                            let index1 = (user1.value(forKey: "fullName") as! String).range(of: search.lowercased())!.lowerBound
                            let index2 = (user2.value(forKey: "fullName") as! String).range(of: search.lowercased())!.lowerBound
                            return index1.encodedOffset < index2.encodedOffset
                        })
                        for person in searchPeople {
                            if useLocationToLoadDistances {
                                if let otherLocation = person.value(forKey: "location") as? PFGeoPoint {
                                    let distance = myLocation.distanceInMiles(to: otherLocation)
                                    let distanceAwayRounded = round(10.0 * distance) / 10.0
                                    searchDistances.append(distanceAwayRounded)
                                } else {
                                    searchDistances.append(nil)
                                }
                            } else {
                                searchDistances.append(nil)
                            }
                            let pic = person.value(forKey: "pic") as! PFFile
                            var pic2 = Data()
                            do {
                                pic2 = try pic.getData()
                            } catch {
                                let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            searchPics.append(UIImage(data: pic2)!)
                            searchNames.append(person.value(forKey: "name") as! String)
                            searchLasts.append(person.value(forKey: "lastName") as! String)
                            var gender = "male"
                            if (person.value(forKey: "gender") as! Bool) {
                                gender = "male"
                            } else {
                                gender = "female"
                            }
                            searchGenders.append(gender)
                            searchBios.append(person.value(forKey: "bio") as! String)
                            searchAges.append(person.value(forKey: "age") as! Int)
                            searchUsernames.append(person.username!)
                            
                            
                            let photoFiles = person.value(forKey: "addedPics") as! [PFFile]
                            
                            searchAddedPicsArrays.append([])
                            
                            for photoFile in photoFiles {
                                var pic2 = Data()
                                do {
                                    pic2 = try photoFile.getData()
                                } catch {
                                    let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                                let photo = UIImage(data: pic2)!
                                
                                searchAddedPicsArrays[searchAddedPicsArrays.count-1].append(photo)
                            }
                            
                            if let school = person.value(forKey: "school") as? String {
                                searchSchools.append(school)
                            } else {
                                searchSchools.append(nil)
                            }
                            
                            if let socialMediaAccounts = person.value(forKey: "socialMedia") as? [String] {
                                searchSocialMediaAccountsArrays.append(socialMediaAccounts)
                            } else {
                                searchSocialMediaAccountsArrays.append([])
                            }
                        }
                        self.tableView.reloadData()
                    }
                })
            }
        } else {
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
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double(Float.leastNormalMagnitude)))
        
        self.tableView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        searchBar.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        searchUserNumber = indexPath.row
        
        userToDisplay = searchPeople[searchUserNumber]
        
        picToDisplay = searchPics[searchUserNumber]
        
        nameToDisplay = searchNames[searchUserNumber]
        
        lastToDisplay = searchLasts[searchUserNumber]
        
        if searchDistances[searchUserNumber] != nil {
            distanceToDisplay = searchDistances[searchUserNumber]!
        } else {
            distanceToDisplay = nil
        }
        
        ageToDisplay = searchAges[searchUserNumber]
        
        genderToDisplay = searchGenders[searchUserNumber]
        
        if searchSchools[searchUserNumber] != nil {
            schoolToDisplay = searchSchools[searchUserNumber]!
        } else {
            schoolToDisplay = nil
        }
        
        bioToDisplay = searchBios[searchUserNumber]
        
        usernameToDisplay = searchUsernames[searchUserNumber]
        
        addedPicsArrayToDisplay.removeAll()
        
        addedPicsArrayToDisplay = searchAddedPicsArrays[searchUserNumber]
        
        socialMediaAccountsArrayToDisplay = searchSocialMediaAccountsArrays[searchUserNumber]
        
        self.performSegue(withIdentifier: "profile", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchPeople.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("reloading")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath); cell.selectionStyle = .none
        
        (cell.viewWithTag(2) as! UIImageView).image = searchPics[indexPath.row]
        (cell.viewWithTag(2) as! UIImageView).layer.masksToBounds = true
        (cell.viewWithTag(2) as! UIImageView).layer.cornerRadius = (cell.viewWithTag(2) as! UIImageView).frame.width/2
        (cell.viewWithTag(2) as! UIImageView).layer.borderColor = UIColor.black.cgColor
        (cell.viewWithTag(2) as! UIImageView).layer.borderWidth = 1.0
        (cell.viewWithTag(3) as! UILabel).text = "\(searchNames[indexPath.row]) \(searchLasts[indexPath.row])"
        if searchDistances[indexPath.row] != nil && searchSchools[indexPath.row] != nil {
            (cell.viewWithTag(5) as! UILabel).text = "\(searchDistances[indexPath.row]!) mi, \(searchSchools[indexPath.row]!)"
        } else if searchSchools[indexPath.row] != nil {
            (cell.viewWithTag(5) as! UILabel).text = "\(searchSchools[indexPath.row]!)"
        } else if searchDistances[indexPath.row] != nil {
            (cell.viewWithTag(5) as! UILabel).text = "\(searchDistances[indexPath.row]!) mi, \(searchBios[indexPath.row])"
        } else {
            (cell.viewWithTag(5) as! UILabel).text = "\(searchBios[indexPath.row])"
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
