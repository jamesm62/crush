//
//  School.swift
//  rate
//
//  Created by James McGivern on 12/31/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit
import Parse

var schoolNamesForSignUp:[String] = []

class School: UITableViewController {
    var right = UIBarButtonItem()

    override func viewDidLoad() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let query = PFUser.query()
        
        query!.selectKeys(["school"])
        query!.limit = 1000
        
        query!.findObjectsInBackground { (schools, error) in
            if error == nil {
                for school in schools! {
                    if let schoolName = school.value(forKey: "school") as? String {
                        if !schoolNamesForSignUp.contains(schoolName), schoolName != "" {
                            schoolNamesForSignUp.append(schoolName)
                        }
                    }
                }
                schoolNamesForSignUp.sort()
                self.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
        self.navigationItem.title = ""
        
        right = UIBarButtonItem(title: "Skip", style: .done, target: self, action: #selector(School.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
    
    @objc func done() {
        self.performSegue(withIdentifier: "socialMedia", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let cell = self.tableView.cellForRow(at: indexPath)
            school = cell!.textLabel!.text!
            self.performSegue(withIdentifier: "socialMedia", sender: self)
        } else {
            self.performSegue(withIdentifier: "addSchool", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "    Choose your school"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoolNamesForSignUp.count+1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row != 0 {
            cell.textLabel?.text = schoolNamesForSignUp[indexPath.row-1]
        } else {
            cell.textLabel?.textColor = UIColor.blue
            cell.textLabel?.text = "Add your school"
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
