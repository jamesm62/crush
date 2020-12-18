//
//  Terms.swift
//  Crush
//
//  Created by James McGivern on 1/7/19.
//  Copyright © 2019 Rate. All rights reserved.
//

import UIKit

class Terms: UITableViewController {

    var right = UIBarButtonItem()
    @IBOutlet var termsLabel: UILabel!
    
    override func viewDidLoad() {
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        
        self.tableView.estimatedRowHeight = 600.0
        
        right = UIBarButtonItem(title: "I Agree", style: .done, target: self, action: #selector(Terms.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
    }
    
    @objc func done() {
        self.performSegue(withIdentifier: "map", sender: self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
