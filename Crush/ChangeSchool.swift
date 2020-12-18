//
//  ChangeSchool.swift
//  rate
//
//  Created by James McGivern on 2/28/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

var schoolNamesForChangingSchool:[String] = []

class ChangeSchool: UITableViewController {
    override func viewDidLoad() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let query = PFUser.query()
        
        query!.selectKeys(["school"])
        query!.limit = 1000
        
        query!.findObjectsInBackground { (schools, error) in
            if error == nil {
                for school in schools! {
                    if let schoolName = school.value(forKey: "school") as? String {
                        if !schoolNamesForChangingSchool.contains(schoolName), schoolName != "" {
                            schoolNamesForChangingSchool.append(schoolName)
                        }
                    }
                }
                schoolNamesForChangingSchool.sort()
                self.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if popIt {
            popIt = false
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func done() {
        self.performSegue(withIdentifier: "map", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 1 {
            let cell = self.tableView.cellForRow(at: indexPath)
            let school = cell!.textLabel!.text!
            
            let showSchools = PFUser.current()!.value(forKey: "showSchools") as! [String]
            
            if !showSchools.contains(school) {
                PFUser.current()!.add(school, forKey: "showSchools")
            }
            
            PFUser.current()!.saveInBackground { (success, error) in
                if success {
                    mySchool = school
                    UserDefaults.standard.setValue(school, forKey: "school")
                    
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else if indexPath.row == 1 {
            self.performSegue(withIdentifier: "addSchool", sender: self)
        } else if indexPath.row == 0 {
            PFUser.current()!.setValue("", forKey: "school")
            
            PFUser.current()!.saveInBackground { (success, error) in
                if success {
                    mySchool = ""
                    UserDefaults.standard.setValue("", forKey: "school")
                    
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "  Choose your school"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoolNamesForChangingSchool.count+2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row > 1 {
            print(indexPath.row)
            cell.textLabel?.text = schoolNamesForChangingSchool[indexPath.row-2]
        } else if indexPath.row == 1 {
            cell.textLabel?.textColor = UIColor.blue
            cell.textLabel?.text = "Add your school"
        } else if indexPath.row == 0 {
            cell.textLabel?.textColor = UIColor.blue
            cell.textLabel?.text = "No school"
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
