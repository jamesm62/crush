//
//  Messages.swift
//  rate
//
//  Created by James McGivern on 4/20/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse
import CoreData
import ParseLiveQuery

var allChats:[PFObject] = []

var mainChats:[PFObject] = []

var chatID = ""

class Messages: UITableViewController {
    
    var subscription: Subscription<PFObject>?
    
    var query1 = PFQuery(className: "Messages")
    var query2 = PFQuery(className: "Messages")
    
    var shouldSort = false
    
    var loadingAnimationView = UIImageView()
    
    var right = UIBarButtonItem()
    
    var noMessagesLabel = UILabel()
    var startConversationLabel = UILabel()
    
    override func viewDidLoad() {
        if !offline {
            startLoadingAnimation()
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        
        noMessagesLabel.isUserInteractionEnabled = false
        startConversationLabel.isUserInteractionEnabled = false
        
        self.noMessagesLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 40.0))
        self.startConversationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 60.0))
        self.noMessagesLabel.center = self.tableView.center
        self.startConversationLabel.center = self.tableView.center
        self.noMessagesLabel.center.y -= 20
        self.startConversationLabel.center.y += 20
        self.noMessagesLabel.textAlignment = .center
        self.startConversationLabel.textAlignment = .center
        self.noMessagesLabel.textColor = UIColor.clear
        self.startConversationLabel.textColor = UIColor.clear
        self.noMessagesLabel.font = UIFont.systemFont(ofSize: 25)
        self.startConversationLabel.font = UIFont.systemFont(ofSize: 21)
        self.noMessagesLabel.numberOfLines = 0
        self.startConversationLabel.numberOfLines = 0
        self.noMessagesLabel.text = "No messages"
        self.startConversationLabel.text = "Start a convo with the plus sign"
        
        self.navigationController!.view.insertSubview(self.noMessagesLabel, belowSubview: self.navigationController!.navigationBar)
        self.navigationController!.view.insertSubview(self.startConversationLabel, belowSubview: self.navigationController!.navigationBar)
        
        if !offline {
            loadChats()
        } else {
            noMessagesLabel.text = "You are offline"
            noMessagesLabel.textColor = UIColor.lightGray
        }
        
        right = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(Messages.addConvo))
        right.tintColor = UIColor.black
        
        self.navigationItem.rightBarButtonItem = right
        
        self.navigationItem.title = "Chats"
        
        self.tableView.backgroundColor = UIColor(white: 1, alpha: 1)
        
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double(Float.leastNormalMagnitude)))
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double(Float.leastNormalMagnitude)))
        self.tableView.separatorStyle = .singleLine
        
        /*
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chats")
        
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
        
        allChats.removeAll()
        mainChats.removeAll()
        chats.removeAll()
        result.reverse()
        
        if result.count > 0 {
            var otherObjectIDs:[String] = []
            for chat in result {
                let fromId = chat.value(forKey: "fromId") as! String
                let fromName = chat.value(forKey: "fromName") as! String
                let fromLast = chat.value(forKey: "fromLast") as! String
                let fromPic = chat.value(forKey: "fromPic") as! Data
                
                let toId = chat.value(forKey: "toId") as! String
                let toName = chat.value(forKey: "toName") as! String
                let toLast = chat.value(forKey: "toLast") as! String
                let toPic = chat.value(forKey: "toPic") as! Data
                
                let newChat = PFObject(className: "Messages")
                
                let fromUser = PFUser()
                let toUser = PFUser()
                
                fromUser.objectId = fromId
                fromUser["name"] = fromName
                fromUser["lastName"] = fromLast
                fromUser["pic"] = PFFile(data: fromPic)
                
                toUser.objectId = toId
                toUser["name"] = toName
                toUser["lastName"] = toLast
                toUser["pic"] = PFFile(data: toPic)
                
                newChat["from"] = fromUser
                newChat["to"] = toUser
                
                newChat["read"] = true
                
                if let message = chat.value(forKey: "message") as? String {
                    print("message: \(message)")
                    newChat.setValue(message, forKey: "message")
                } else {
                    let photo = chat.value(forKey: "photo") as! Data
                    print("photo: \(photo)")
                    newChat.setValue(PFFile(data: photo), forKey: "photo")
                }
                
                allChats.append(newChat)
                
                var objectId = ""
                if fromId == PFUser.current()!.objectId! {
                    objectId = toId
                } else {
                    objectId = fromId
                }
                
                if !otherObjectIDs.contains(objectId) {
                    otherObjectIDs.append(objectId)
                    mainChats.append(newChat)
                }
            }
            self.tableView.reloadData()
        }
 */
    }
    
    @objc func addConvo() {
        self.performSegue(withIdentifier: "addConvo", sender: self)
    }
    
    func loadChats() {
        var tempAllChats:[PFObject] = []
        var tempMainChats:[PFObject] = []
        
        var otherObjectIDs:[String] = []
        
        query1 = PFQuery(className: "Messages")
        query1.whereKey("from", equalTo: PFUser.current()!)
        
        query2 = PFQuery(className: "Messages")
        query2.whereKey("to", equalTo: PFUser.current()!)
        
        let mainQuery = PFQuery.orQuery(withSubqueries: [query1, query2])
        mainQuery.limit = 1000
        
        mainQuery.findObjectsInBackground { (messagesList, error) in
            print("found chats")
            if error == nil {
                tempAllChats = messagesList!
                tempAllChats.sort(by: { (chat1, chat2) -> Bool in
                    if chat1.createdAt!.compare(chat2.createdAt!) == ComparisonResult.orderedDescending {
                        return true
                    } else {
                        return false
                    }
                })
                let messages = tempAllChats
                print("messages: \(messages)")
                for message in messages {
                    var objectId = ""
                    if (message.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
                        objectId = (message.value(forKey: "to") as! PFUser).objectId!
                    } else {
                        objectId = (message.value(forKey: "from") as! PFUser).objectId!
                    }
                    
                    if !otherObjectIDs.contains(objectId) {
                        otherObjectIDs.append(objectId)
                        tempMainChats.append(message)
                    }
                }
                
                allChats = tempAllChats
                mainChats = tempMainChats
                self.shouldSort = true
                
                if mainChats.count == 0 {
                    self.noMessagesLabel.textColor = UIColor.lightGray
                    self.startConversationLabel.textColor = UIColor.lightGray
                } else {
                    self.noMessagesLabel.textColor = UIColor.clear
                    self.startConversationLabel.textColor = UIColor.clear
                }
                messagesHasDoneInitialLoad = true
                
                self.tableView.reloadData()
                
                print("making subscription")
                
                self.subscription = client.subscribe(self.query2)
                
                self.subscription!.handleEvent({ (_, event) in
                    if shouldUpdate {
                        switch event {
                        case .created(let object):
                            print("add message")
                            self.addMessage(object: object)
                        case .deleted(let object):
                            print("delete message")
                            self.deleteMessage(object: object)
                        default:
                            break
                        }
                    }
                })
                
                self.stopLoadingAnimation()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                // Create a background task
                /*
                childContext.perform {
                    // Perform tasks in a background queue
                    self.setChatsCoreData() // set up the database for the new game
                }
 */
            } else {
                self.stopLoadingAnimation()
                UIApplication.shared.endIgnoringInteractionEvents()
                let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func addMessage(object: PFObject) {
        print(allChats)
        self.noMessagesLabel.textColor = UIColor.clear
        self.startConversationLabel.textColor = UIColor.clear
        
        allChats.insert(object, at: 0)
        allChats.sort(by: { (chat1, chat2) -> Bool in
            if chat1.createdAt!.compare(chat2.createdAt!) == ComparisonResult.orderedDescending {
                return true
            } else {
                return false
            }
        })
        print(allChats)
        var otherObjectIDs:[String] = []
        mainChats.removeAll()
        let messages = allChats
        for message in messages {
            var objectId = ""
            if (message.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
                objectId = (message.value(forKey: "to") as! PFUser).objectId!
            } else {
                objectId = (message.value(forKey: "from") as! PFUser).objectId!
            }
            
            if !otherObjectIDs.contains(objectId) {
                otherObjectIDs.append(objectId)
                mainChats.append(message)
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.tabBarController!.selectedIndex != 2 {
                if self.tabBarController!.tabBar.items![2].badgeValue == nil {
                    self.tabBarController!.tabBar.items![2].badgeValue = "1"
                } else {
                    let currentBadgeValue = Int(self.tabBarController!.tabBar.items![2].badgeValue!)!
                    self.tabBarController!.tabBar.items![2].badgeValue = "\(currentBadgeValue + 1)"
                }
            }
        }
        
        // Create a background task
        /*
        childContext.perform {
            // Perform tasks in a background queue
            self.setChatsCoreData() // set up the database for the new game
        }
 */
    }
    
    func deleteMessage(object: PFObject) {
        for allChat in allChats {
            if allChat.objectId! == object.objectId! {
                allChats.remove(at: allChats.index(of: allChat)!)
            }
        }
        allChats.sort(by: { (alert1, alert2) -> Bool in
            if alert1.createdAt!.compare(alert2.createdAt!) == ComparisonResult.orderedDescending {
                return true
            } else {
                return false
            }
        })
        var otherObjectIDs:[String] = []
        mainChats.removeAll()
        let messages = allChats.reversed()
        for message in messages {
            var objectId = ""
            if (message.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
                objectId = (message.value(forKey: "to") as! PFUser).objectId!
            } else {
                objectId = (message.value(forKey: "from") as! PFUser).objectId!
            }
            
            if !otherObjectIDs.contains(objectId) {
                otherObjectIDs.append(objectId)
                mainChats.append(message)
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.tabBarController!.selectedIndex != 2 {
                if self.tabBarController!.tabBar.items![2].badgeValue == "1" {
                    self.tabBarController!.tabBar.items![2].badgeValue = nil
                } else {
                    if self.tabBarController!.tabBar.items![2].badgeValue != nil {
                        let currentBadgeValue = Int(self.tabBarController!.tabBar.items![2].badgeValue!)!
                        self.tabBarController!.tabBar.items![2].badgeValue = "\(currentBadgeValue - 1)"
                    }
                }
            }
        }
        
        // Create a background task
        /*
        childContext.perform {
            // Perform tasks in a background queue
            self.setChatsCoreData() // set up the database for the new game
        }
 */
    }
    
    func updateMessage(object: PFObject) {
        for chat in allChats {
            if object.objectId! == chat.objectId! {
                allChats[allChats.index(of: chat)!] = object
            }
        }
        var otherObjectIDs:[String] = []
        mainChats.removeAll()
        let messages = allChats.reversed()
        for message in messages {
            var objectId = ""
            if (message.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
                objectId = (message.value(forKey: "to") as! PFUser).objectId!
            } else {
                objectId = (message.value(forKey: "from") as! PFUser).objectId!
            }
            
            if !otherObjectIDs.contains(objectId) {
                otherObjectIDs.append(objectId)
                mainChats.append(message)
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        // Create a background task
        /*
        childContext.perform {
            // Perform tasks in a background queue
            self.setChatsCoreData() // set up the database for the new game
        }
 */
    }
    
    func setChatsCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chats")
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
        
        for message in allChats.reversed() {
            let chat = NSEntityDescription.insertNewObject(forEntityName: "Chats", into: childContext)
            
            print("testing")
            
            chat.setValue(message.objectId!, forKey: "objectId")
            print("here 1")
            if let text = message.value(forKey: "message") as? String {
                print("here 1.1")
                chat.setValue(text, forKey: "message")
            } else if let photo = message.value(forKey: "photo") as? PFFile {
                print("here 1.2")
                do {
                    print("here 1.3")
                    chat.setValue(NSData(data: try photo.getData()), forKey: "photo")
                } catch {
                    print("Could not load photo")
                }
            }
            print("here 2")
            
            let from = message.value(forKey: "from") as! PFUser
            let to = message.value(forKey: "to") as! PFUser
            
            print("here 3")
            do {
                try from.fetchIfNeeded()
                try to.fetchIfNeeded()
            } catch {
                print("Could not fetch user")
            }
            
            print("here 4")
            
            chat.setValue(from.objectId!, forKey: "fromId")
            chat.setValue(from.value(forKey: "name") as! String, forKey: "fromName")
            chat.setValue(from.value(forKey: "lastName") as! String, forKey: "fromLast")
            do {
                let fromPic = from.value(forKey: "pic") as! PFFile
                let data = try fromPic.getData()
                chat.setValue(NSData(data: data), forKey: "fromPic")
            } catch {
                print("Could not retrieve profilePic from core data")
            }
            print("here 5")
            
            chat.setValue(to.objectId!, forKey: "toId")
            chat.setValue(to.value(forKey: "name") as! String, forKey: "toName")
            chat.setValue(to.value(forKey: "lastName") as! String, forKey: "toLast")
            do {
                let toPic = to.value(forKey: "pic") as! PFFile
                let data = try toPic.getData()
                chat.setValue(NSData(data: data), forKey: "toPic")
            } catch {
                print("Could not retrieve profilePic from core data")
            }
            chat.setValue(count, forKey: "sortNum")
            print("got here")
            
            count += 1
        }
        
        print("almost end of core data")
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
        
        print("end of core data")
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
        query2 = PFQuery(className: "Messages")
        query2.whereKey("to", equalTo: PFUser.current()!)
        self.subscription = client.subscribe(self.query2)
        
        self.subscription!.handleEvent({ (_, event) in
            if shouldUpdate {
                switch event {
                case .created(let object):
                    print("add message")
                    self.addMessage(object: object)
                case .deleted(let object):
                    print("delete message")
                    self.deleteMessage(object: object)
                default:
                    break
                }
            }
        })
        if shouldSort {
            allChats.sort(by: { (chat1, chat2) -> Bool in
                if chat1.createdAt!.compare(chat2.createdAt!) == ComparisonResult.orderedDescending {
                    return true
                } else {
                    return false
                }
            })
        }
        var otherObjectIDs:[String] = []
        mainChats.removeAll()
        let messages = allChats
        for message in messages {
            var objectId = ""
            if (message.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
                objectId = (message.value(forKey: "to") as! PFUser).objectId!
            } else {
                objectId = (message.value(forKey: "from") as! PFUser).objectId!
            }
            
            if !otherObjectIDs.contains(objectId) {
                otherObjectIDs.append(objectId)
                mainChats.append(message)
            }
        }
        self.tableView.reloadData()
        
        if !offline {
            if mainChats.count == 0 {
                if messagesHasDoneInitialLoad {
                    self.noMessagesLabel.textColor = UIColor.lightGray
                    self.startConversationLabel.textColor = UIColor.lightGray
                }
            } else {
                self.noMessagesLabel.textColor = UIColor.clear
                self.startConversationLabel.textColor = UIColor.clear
            }
        } else {
            noMessagesLabel.text = "You are offline"
            noMessagesLabel.textColor = UIColor.lightGray
            startConversationLabel.textColor = UIColor.clear
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row")
        let chat = mainChats[indexPath.row]
        print("start")
        if (chat.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
            chatID = (chat.value(forKey: "to") as! PFUser).objectId!
        } else {
            chatID = (chat.value(forKey: "from") as! PFUser).objectId!
        }
        print("finish")
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        self.navigationItem.backBarButtonItem = backItem
        print("set back button")
        shouldUseChatUserAccount = false
        print("set shouldUseChatUserAccount")
        chats.removeAll()
        client.unsubscribe(query1)
        client.unsubscribe(query2)
        print("doing segue")
        self.performSegue(withIdentifier: "chat", sender: self)
        print("worked")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.noMessagesLabel.textColor = UIColor.clear
        self.startConversationLabel.textColor = UIColor.clear
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mainChats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath); cell.selectionStyle = .none
        let chat = mainChats[indexPath.row]
        if let msg = chat.value(forKey: "message") as? String {
            print(msg)
        }
        var user = PFUser()
        if (chat.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
            user = chat.value(forKey: "to") as! PFUser
        } else {
            user = chat.value(forKey: "from") as! PFUser
        }
        do {
            try user.fetchIfNeeded()
        } catch {
            let alert = UIAlertController(title: "Oops", message: "Couldn't fetch messages", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        cell.accessoryType = .disclosureIndicator
        (cell.viewWithTag(1) as! UIImageView).layer.cornerRadius = (cell.viewWithTag(1) as! UIImageView).frame.height/2
        (cell.viewWithTag(1) as! UIImageView).layer.masksToBounds = true
        (cell.viewWithTag(1) as! UIImageView).layer.borderColor = UIColor.black.cgColor
        (cell.viewWithTag(1) as! UIImageView).layer.borderWidth = 1.0
        let pic = user.value(forKey: "pic") as! PFFile
        var pic2 = Data()
        do {
            pic2 = try pic.getData()
        } catch {
            let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        (cell.viewWithTag(1) as! UIImageView).image = UIImage(data: pic2)!
        (cell.viewWithTag(2) as! UILabel).text = "\(user.value(forKey: "name") as! String) \(user.value(forKey: "lastName") as! String)"
        if let message = chat.value(forKey: "message") as? String {
            (cell.viewWithTag(3) as! UILabel).text = message
        } else {
            (cell.viewWithTag(3) as! UILabel).text = "Sent a photo"
        }
        if (chat.value(forKey: "to") as! PFUser).objectId! == PFUser.current()!.objectId! {
            if !(chat.value(forKey: "read") as! Bool) {
                print("doing this rn")
                (cell.viewWithTag(3) as! UILabel).font = UIFont.boldSystemFont(ofSize: 14.0)
                (cell.viewWithTag(3) as! UILabel).textColor = UIColor.black
                (cell.viewWithTag(2) as! UILabel).font = UIFont.boldSystemFont(ofSize: 17.0)
            } else {
                (cell.viewWithTag(3) as! UILabel).font = UIFont.systemFont(ofSize: 14.0)
                (cell.viewWithTag(3) as! UILabel).textColor = UIColor(red: 0.69, green: 0.69, blue: 0.69, alpha: 1.0)
                (cell.viewWithTag(2) as! UILabel).font = UIFont.systemFont(ofSize: 17.0)
            }
        } else {
            (cell.viewWithTag(3) as! UILabel).font = UIFont.systemFont(ofSize: 14.0)
            (cell.viewWithTag(3) as! UILabel).textColor = UIColor(red: 0.69, green: 0.69, blue: 0.69, alpha: 1.0)
            (cell.viewWithTag(2) as! UILabel).font = UIFont.systemFont(ofSize: 17.0)
        }
        
        return cell
    }
}
