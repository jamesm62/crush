//
//  Settings.swift
//  rate
//
//  Created by James McGivern on 1/1/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

class Settings: UITableViewController {

    @IBOutlet var school: UILabel!
    @IBOutlet var gender: UILabel!
    @IBOutlet var age: UILabel!
    @IBOutlet var searchRadius: UILabel!
    
    @IBOutlet var cell1: UITableViewCell!
    @IBOutlet var cell2: UITableViewCell!
    @IBOutlet var cell3: UITableViewCell!
    @IBOutlet var cell4: UITableViewCell!
    
    override func viewDidLoad() {
        cell1.accessoryType = .disclosureIndicator
        cell2.accessoryType = .disclosureIndicator
        cell3.accessoryType = .disclosureIndicator
        cell4.accessoryType = .disclosureIndicator
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "pickSchools", sender: self)
        } else if indexPath.row == 1 {
            self.performSegue(withIdentifier: "searchRadius", sender: self)
        } else if indexPath.row == 2 {
            self.performSegue(withIdentifier: "pickGenders", sender: self)
        } else if indexPath.row == 3 {
            self.performSegue(withIdentifier: "agePreference", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        UIApplication.shared.endIgnoringInteractionEvents()
        
        if let schools = PFUser.current()?.value(forKey: "showSchools") as? [String] {
            if schools.count > 1 {
                self.school.text = "\(schools.count) schools"
            } else if schools.count == 1 {
                self.school.text = "\(schools[0])"
            } else {
                self.school.text = "All schools"
            }
        }
        if let genderPreference = PFUser.current()?.value(forKey: "genderPreference") as? String {
            self.gender.text = genderPreference
        }
        
        if let agePreference = PFUser.current()?.value(forKey: "agePreference") as? [Int] {
            self.age.text = "\(agePreference[0])-\(agePreference[1])"
        }
        
        if let radius = PFUser.current()?.value(forKey: "searchRadius") as? Int {
            self.searchRadius.text = "\(radius) miles"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}
