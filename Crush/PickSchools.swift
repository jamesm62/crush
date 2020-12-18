//
//  PickSchools.swift
//  rate
//
//  Created by James McGivern on 1/2/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class PickSchools: UITableViewController {
    
    var schoolNames:[String] = []
    
    var right = UIBarButtonItem()
    
    var showSchools:[String] = []

    override func viewDidLoad() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        for showSchool in PFUser.current()!.value(forKey: "showSchools") as! [String] {
            if !showSchools.contains(showSchool) {
                showSchools.append(showSchool)
            }
        }
        let query = PFUser.query()
        
        query!.selectKeys(["school"])
        query!.limit = 1000
        
        query!.findObjectsInBackground { (objects, error) in
            if let schools = objects {
                for school in schools {
                    if let schoolName = school.value(forKey: "school") as? String {
                        if !self.schoolNames.contains(schoolName) && schoolName != "" {
                            self.schoolNames.append(schoolName)
                        }
                    }
                }
                self.schoolNames.sort()
                for showSchool in self.showSchools {
                    if !self.schoolNames.contains(showSchool) {
                        self.showSchools.remove(at: self.showSchools.firstIndex(of: showSchool)!)
                    }
                }
                self.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
                let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        right = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(Register.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
    }
    
    @objc func done() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        PFUser.current()?.setValue(showSchools, forKey: "showSchools")
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if success {
                shouldReloadPeople = true
                UIApplication.shared.endIgnoringInteractionEvents()
                self.navigationController?.popViewController(animated: true)
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
                let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        if cell!.accessoryType == .none {
            showSchools.append(cell!.textLabel!.text!)
            cell!.accessoryType = .checkmark
        } else {
            showSchools.remove(at: showSchools.index(of: cell!.textLabel!.text!)!)
            cell!.accessoryType = .none
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoolNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = schoolNames[indexPath.row]
        if (PFUser.current()?.value(forKey: "showSchools") as! [String]).contains(schoolNames[indexPath.row]) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
