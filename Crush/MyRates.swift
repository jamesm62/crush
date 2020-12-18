//
//  MyRates.swift
//  Crush
//
//  Created by James McGivern on 6/14/18.
//  Copyright © 2018 Crush. All rights reserved.
//

import UIKit
import Parse
import CoreData

var rateValues:[Int] = []
var rates:[PFObject] = []
var ratePics:[UIImage] = []
var rateFirsts:[String] = []
var rateLasts:[String] = []

var shouldLoadCoreData = true

var loadedMyRates = false

class MyRates: UITableViewController {
    
    var uniqueRates:[Int] = []
    
    var loadingAnimationView = UIImageView()
    
    var noRatesLabel = UILabel()
    var ratePeopleLabel = UILabel()

    override func viewDidLoad() {
        self.tableView.bounces = false
        
        noRatesLabel.isUserInteractionEnabled = false
        ratePeopleLabel.isUserInteractionEnabled = false
        
        self.noRatesLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 40.0))
        self.ratePeopleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width-40, height: 120.0))
        self.noRatesLabel.center = self.tableView.center
        self.ratePeopleLabel.center = self.tableView.center
        self.noRatesLabel.center.y -= 40
        self.ratePeopleLabel.center.y += 40
        self.noRatesLabel.textAlignment = .center
        self.ratePeopleLabel.textAlignment = .center
        self.noRatesLabel.textColor = UIColor.clear
        self.ratePeopleLabel.textColor = UIColor.clear
        self.noRatesLabel.font = UIFont.systemFont(ofSize: 25)
        self.ratePeopleLabel.font = UIFont.systemFont(ofSize: 21)
        self.noRatesLabel.numberOfLines = 0
        self.ratePeopleLabel.numberOfLines = 0
        self.noRatesLabel.text = "No rates yet"
        self.ratePeopleLabel.text = "Rate people by selecting the button in the top right corner of the their profile"
        
        self.navigationController!.view.insertSubview(self.noRatesLabel, belowSubview: self.navigationController!.navigationBar)
        self.navigationController!.view.insertSubview(self.ratePeopleLabel, belowSubview: self.navigationController!.navigationBar)
        
        self.tableView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        if !shouldLoadCoreData {
            // Create a background task
            /*
             childContext.perform {
             // Perform tasks in a background queue
             self.setMyRatesCoreData() // set up the database for the new game
             }
             */
        }
        if !loadedMyRates {
            if !offline {
                loadedMyRates = true
                
                startLoadingAnimation()
                UIApplication.shared.beginIgnoringInteractionEvents()
                
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
                        
                        if rates.count == 0 {
                            self.noRatesLabel.textColor = UIColor.lightGray
                            self.ratePeopleLabel.textColor = UIColor.lightGray
                        } else {
                            self.noRatesLabel.textColor = UIColor.clear
                            self.ratePeopleLabel.textColor = UIColor.clear
                        }
                        myRatesHasDoneInitialLoad = true
                        
                        self.tableView.reloadData()
                        shouldLoadCoreData = false
                        
                        // Create a background task
                        /*
                         childContext.perform {
                         // Perform tasks in a background queue
                         self.setMyRatesCoreData() // set up the database for the new game
                         }
                         */
                        self.stopLoadingAnimation()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    } else {
                        self.stopLoadingAnimation()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                noRatesLabel.text = "You are offline"
                noRatesLabel.textColor = UIColor.lightGray
            }
        }
        
        /*
        
        if shouldLoadCoreData {
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double(Float.leastNormalMagnitude)))
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rates")
            
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
                return (object1.value(forKey: "sortNum") as! Int) > (object2.value(forKey: "sortNum") as! Int)
            }
            rates.removeAll()
            ratePics.removeAll()
            rateFirsts.removeAll()
            rateLasts.removeAll()
            rateValues.removeAll()
            if result.count > 0 {
                for rate in result.reversed() {
                    let pic = UIImage(data: rate.value(forKey: "pic") as! Data)!
                    let first = rate.value(forKey: "first") as! String
                    let last = rate.value(forKey: "last") as! String
                    let interest = rate.value(forKey: "interest") as! Int
                    
                    ratePics.append(pic)
                    rateFirsts.append(first)
                    rateLasts.append(last)
                    rateValues.append(interest)
                    
                    let newRate = PFObject(className: "Rates")
                    
                    let to = PFUser()
                    to.setValue(PFFile(data: rate.value(forKey: "pic") as! Data), forKey: "pic")
                    to.setValue(first, forKey: "name")
                    to.setValue(last, forKey: "lastName")
                    
                    newRate.setValue(to, forKey: "to")
                    
                    newRate.setValue(interest, forKey: "interestLevel")
                    
                    rates.append(newRate)
                }
                self.tableView.reloadData()
            }
        }
 
 */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.navigationController == nil || !self.navigationController!.viewControllers.contains(self) {
            self.noRatesLabel.textColor = UIColor.clear
            self.ratePeopleLabel.textColor = UIColor.clear
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !offline {
            if rates.count == 0 {
                if myRatesHasDoneInitialLoad {
                    self.noRatesLabel.textColor = UIColor.lightGray
                    self.ratePeopleLabel.textColor = UIColor.lightGray
                }
            } else {
                self.noRatesLabel.textColor = UIColor.clear
                self.ratePeopleLabel.textColor = UIColor.clear
            }
        } else {
            noRatesLabel.text = "You are offline"
            noRatesLabel.textColor = UIColor.lightGray
            ratePeopleLabel.textColor = UIColor.clear
        }
        self.tableView.reloadData()
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
    
    func setMyRatesCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Rates")
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
        for rate in rates {
            let cdRate = NSEntityDescription.insertNewObject(forEntityName: "Rates", into: childContext)
            
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 31
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = "LOL"
        
        let sectionTitleIndex = uniqueRates[section]
        
        switch(sectionTitleIndex) {
        case 0: title = "Would start a relationship"
        case 1: title = "Would go on a date"
        case 2: title = "Would be more than friends"
        case 3: title = "Would hang out"
        case 4: title = "Would get to know"
        case 5: title = "Would be friends"
        case 6: title = "Would meet"
        case 7: title = "Not interested"
            
        default: title = "LOL"
        }
        return title
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        uniqueRates.removeAll()
        for rateValue in rateValues {
            if !uniqueRates.contains(rateValue) {
                uniqueRates.append(rateValue)
            }
        }
        
        return uniqueRates.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        for rateValue in rateValues {
            if rateValue == uniqueRates[section] {
                count += 1
            }
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let targetRateValue = uniqueRates[indexPath.section]
        
        var indexOfSection = 0
        
        for rateValue in rateValues {
            if rateValue == targetRateValue {
                indexOfSection = rateValues.index(of: rateValue)!
            }
        }
        
        let indexOfRate = indexOfSection+indexPath.row
        
        (cell.viewWithTag(1) as! UIImageView).image = ratePics[indexOfRate]
        (cell.viewWithTag(1) as! UIImageView).layer.masksToBounds = true
        (cell.viewWithTag(1) as! UIImageView).layer.cornerRadius = (cell.viewWithTag(1) as! UIImageView).frame.width/2
        (cell.viewWithTag(1) as! UIImageView).layer.borderColor = UIColor.black.cgColor
        (cell.viewWithTag(1) as! UIImageView).layer.borderWidth = 1.0
        
        print(rateFirsts[indexOfRate])
        print(rateLasts[indexOfRate])
        (cell.viewWithTag(2) as! UILabel).text = "\(rateFirsts[indexOfRate]) \(rateLasts[indexOfRate])"
        
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetRateValue = uniqueRates[indexPath.section]
        
        var indexOfSection = 0
        
        var setIndexOfSection = false
        
        if targetRateValue != 0 {
            for rateValue in rateValues {
                if Int(rateValue) == targetRateValue {
                    if !setIndexOfSection {
                        indexOfSection = rateValues.index(of: rateValue)!
                        setIndexOfSection = true
                    }
                }
            }
        } else {
            for rateValue in rateValues {
                if Int(rateValue) == 0 || Int(rateValue) == 1 || Int(rateValue) == 2 {
                    if !setIndexOfSection {
                        indexOfSection = rateValues.index(of: rateValue)!
                        setIndexOfSection = true
                    }
                }
            }
        }
        
        let indexOfRate = indexOfSection+indexPath.row
        
        myRateToModify = rates[indexOfRate]
        fromMyRates = true
        
        picForModifyingRate = ratePics[indexOfRate]
        nameForModifyingRate = rateFirsts[indexOfRate]
        lastForModifyingRate = rateLasts[indexOfRate]
        
        self.performSegue(withIdentifier: "rate", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.noRatesLabel.textColor = UIColor.clear
        self.ratePeopleLabel.textColor = UIColor.clear
    }
}
