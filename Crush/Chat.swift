//
//  Chat.swift
//  rate
//
//  Created by James McGivern on 4/21/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse
import CoreData
import ParseLiveQuery

import UIKit

var chats:[PFObject] = []

var shouldReloadChat = false

var chatPhotoToView = UIImage()

class Chat: UITableViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var shouldExecute = true
    
    var messageCellHeight = CGFloat(39.0)
    
    var user = PFUser()
    
    var subscription1: Subscription<PFObject>?
    var subscription2: Subscription<PFObject>?
    
    var query1 = PFQuery(className: "Messages")
    var query2 = PFQuery(className: "Messages")
    
    var keyboardHeight:CGFloat = 0.0
    var shouldUseKeyboardHeight = false
    
    var firstTimeOpeningChat = true
    
    var chatCount = 0
    
    var messageTextField:ChatTextView? = nil
    
    override func viewDidLoad() {
        self.tableView.bounces = false
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        self.tableView.allowsSelection = false
        if shouldUseChatUserAccount {
            self.user = chatUserAccount
            for chat in allChats {
                if (chat.value(forKey: "from") as! PFUser).objectId! == self.user.objectId! || (chat.value(forKey: "to") as! PFUser).objectId! == self.user.objectId! {
                    chats.append(chat)
                }
            }
            
            self.navigationItem.title = "\(self.user.value(forKey: "name") as! String) \(self.user.value(forKey: "lastName") as! String)"
            
            self.tableView.separatorStyle = .none
        } else {
            for chat in allChats {
                if (chat.value(forKey: "from") as! PFUser).objectId! == chatID || (chat.value(forKey: "to") as! PFUser).objectId! == chatID {
                    chats.append(chat)
                }
            }
            let chat = chats[0]
            if (chat.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
                user = chat.value(forKey: "to") as! PFUser
            } else {
                user = chat.value(forKey: "from") as! PFUser
            }
            do {
                try user.fetchIfNeeded()
            } catch {
                let alert = UIAlertController(title: "Oops", message: "Couldn't fetch user", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            self.navigationItem.title = "\(user.value(forKey: "name") as! String) \(user.value(forKey: "lastName") as! String)"
            
            self.tableView.separatorStyle = .none
        }
        
        chatCount = chats.count + 1
        
        self.tableView.reloadData()
        
        registerForNotification()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(Chat.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        recognizer.delegate = self
        self.view.addGestureRecognizer(recognizer)
        
        query1.whereKey("from", equalTo: self.user)
        query2.whereKey("to", equalTo: self.user)
        
        subscription1 = client.subscribe(query1)
        
        subscription1!.handleEvent({ (_, event) in
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
        
        subscription2 = client.subscribe(query2)
        
        subscription2!.handleEvent({ (_, event) in
            if shouldUpdate {
                switch event {
                case .updated(let object):
                    print("update message")
                    print("Object: \(object)")
                    self.updateMessage(object: object)
                default:
                    break
                }
            }
        })
        self.tableView.contentInset.top = -abs(navBarHeight-tabBarHeight)
        self.tableView.contentInset.bottom = abs(navBarHeight-tabBarHeight)
        self.tableView.scrollIndicatorInsets.top = -abs(navBarHeight-tabBarHeight)
        self.tableView.scrollIndicatorInsets.bottom = abs(navBarHeight-tabBarHeight)
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
        
        for message in allChats {
            let chat = NSEntityDescription.insertNewObject(forEntityName: "Chats", into: childContext)
            
            print("testing")
            
            chat.setValue(message.objectId!, forKey: "objectId")
            
            if let text = message.value(forKey: "message") as? String {
                chat.setValue(text, forKey: "message")
            } else if let photo = message.value(forKey: "photo") as? PFFile {
                do {
                    chat.setValue(NSData(data: try photo.getData()), forKey: "photo")
                } catch {
                    print("Could not load photo")
                }
            }
            
            let from = message.value(forKey: "from") as! PFUser
            let to = message.value(forKey: "to") as! PFUser
            do {
                try from.fetchIfNeeded()
                try to.fetchIfNeeded()
            } catch {
                print("Could not fetch user")
            }
            
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
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        if shouldReloadChat {
            shouldReloadChat = false
            self.tableView.numberOfRows(inSection: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .bottom)
            chatCount += 1
            self.tableView.endUpdates()
            if chats.count > 1 {
                print("here 2")
                self.tableView.numberOfRows(inSection: 0)
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: UITableViewRowAnimation.none)
            }
        }
    }
    
    func addMessage(object: PFObject) {
        if (object.value(forKey: "to") as! PFUser).objectId! == PFUser.current()!.objectId! {
            chats.insert(object, at: 0)
            allChats.insert(object, at: 0)
            DispatchQueue.main.async {
                self.tableView.numberOfRows(inSection: 0)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .bottom)
                self.chatCount += 1
                self.tableView.endUpdates()
                if chats.count > 1 {
                    print("here 2")
                    self.tableView.numberOfRows(inSection: 0)
                    self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: UITableViewRowAnimation.none)
                }
                self.updateContentInset()
            }
            /*
            childContext.perform {
                // Perform tasks in a background queue
                self.setChatsCoreData() // set up the database for the new game
            }
 */
        }
    }
    
    func deleteMessage(object: PFObject) {
        if (object.value(forKey: "to") as! PFUser).objectId! == PFUser.current()!.objectId! {
            for chat in chats {
                if chat.objectId! == object.objectId! {
                    let indexToDelete = chats.index(of: chat)!
                    chats.remove(at: indexToDelete)
                    DispatchQueue.main.async {
                        self.tableView.numberOfRows(inSection: 0)
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [IndexPath(row: indexToDelete+1, section: 0)], with: .right)
                        self.chatCount -= 1
                        self.tableView.endUpdates()
                        self.updateContentInset()
                    }
                }
            }
            for allChat in allChats {
                if allChat.objectId! == object.objectId! {
                    allChats.remove(at: allChats.index(of: allChat)!)
                }
            }
            /*
            childContext.perform {
                // Perform tasks in a background queue
                self.setChatsCoreData()
            }
 */
        }
    }
    
    func updateMessage(object: PFObject) {
        if (object.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
            for chat in chats {
                if object.objectId! == chat.objectId! {
                    if object.value(forKey: "read") as! Bool != chat.value(forKey: "read") as! Bool {
                        if chats.index(of: chat)! == 0 {
                            print(object)
                            chats[0] = object
                            for chat in allChats {
                                if object.objectId! == chat.objectId! {
                                    allChats[allChats.index(of: chat)!] = object
                                }
                            }
                            
                            if !shouldReloadChat {
                                DispatchQueue.main.async {
                                    self.tableView.numberOfRows(inSection: 0)
                                    print("reloading row 1")
                                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                                    print(chats)
                                }
                            }
                            /*
                            childContext.perform {
                                // Perform tasks in a background queue
                                self.setChatsCoreData()
                            }
 */
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.navigationController == nil || !self.navigationController!.viewControllers.contains(self) {
            client.unsubscribe(self.query1)
            client.unsubscribe(self.query2)
            chats.removeAll()
            if self.messageTextField != nil {
                if self.messageTextField!.isFirstResponder {
                    self.messageTextField!.resignFirstResponder()
                }
            }
        }
    }
    
    @objc func touched() {
        self.view.endEditing(true)
    }
    
    func registerForNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { [unowned self] notification in
            print("keyboardWillShow")
            self.keyboardWillShow(notification)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { [unowned self] notification in
            print("keyboardWillHide")
            self.keyboardWillHide(notification)
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        var keyboardHeight: CGFloat = 0.0
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        self.keyboardHeight = keyboardHeight
        shouldUseKeyboardHeight = true
        self.updateContentInset()
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0.0
        shouldUseKeyboardHeight = false
        self.updateContentInset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatCount
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return messageCellHeight
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func updateContentInset() {
        var newContentInset = tableView.contentInset
        
        if self.shouldUseKeyboardHeight {
            newContentInset.top = -abs(navBarHeight-tabBarHeight) + keyboardHeight - tabBarHeight
            newContentInset.bottom = abs(navBarHeight-tabBarHeight) - self.tableView.frame.height + messageCellHeight + UIApplication.shared.statusBarFrame.height
            //newContentInset.bottom = abs(navBarHeight-tabBarHeight) - keyboardHeight + tabBarHeight - self.tableView.contentSize.height
        } else {
            newContentInset.top = -abs(navBarHeight-tabBarHeight)
            newContentInset.bottom = abs(navBarHeight-tabBarHeight)
        }
        
        self.tableView.contentInset = newContentInset
        self.tableView.scrollIndicatorInsets.top = newContentInset.top + messageCellHeight
        self.tableView.scrollIndicatorInsets.bottom = newContentInset.bottom
        
        for visibleCell in self.tableView.visibleCells {
            if visibleCell.reuseIdentifier == "typeText" {
                (visibleCell.viewWithTag(1) as! ChatTextView).becomeFirstResponder()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("changing messageCellHeight")
        messageCellHeight = (object as! UITextView).contentSize.height+10
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "me")!
        if indexPath.row != 0 {
            let chat = chats[indexPath.row-1]
            if (chat.value(forKey: "to") as! PFUser).objectId! == PFUser.current()!.objectId! && !(chat.value(forKey: "read") as! Bool) {
                chat.setValue(true, forKey: "read")
                
                chat.saveInBackground()
            }
            if let message = chat.value(forKey: "message") as? String {
                if (chat.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
                    cell = tableView.dequeueReusableCell(withIdentifier: "me")!
                    
                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(Chat.removeMessage(sender:)))
                    longPressRecognizer.delegate = self
                    (cell.viewWithTag(1) as! UILabel).isUserInteractionEnabled = true
                    (cell.viewWithTag(1) as! UILabel).addGestureRecognizer(longPressRecognizer)
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "person")!
                }
                
                (cell.viewWithTag(1) as! UILabel).text = message
                (cell.viewWithTag(1) as! UILabel).preferredMaxLayoutWidth = UIScreen.main.bounds.width*(3/4)
                (cell.viewWithTag(1) as! UILabel).layer.cornerRadius = 5
                (cell.viewWithTag(1) as! UILabel).layer.masksToBounds = true
            } else {
                if (chat.value(forKey: "from") as! PFUser).objectId! == PFUser.current()!.objectId! {
                    cell = tableView.dequeueReusableCell(withIdentifier: "mePhoto")!
                    
                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(Chat.removeMessage(sender:)))
                    longPressRecognizer.delegate = self
                    (cell.viewWithTag(1) as! UIImageView).isUserInteractionEnabled = true
                    (cell.viewWithTag(1) as! UIImageView).addGestureRecognizer(longPressRecognizer)
                    
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Chat.viewPhoto(sender:)))
                    tapGestureRecognizer.delegate = self
                    (cell.viewWithTag(1) as! UIImageView).isUserInteractionEnabled = true
                    (cell.viewWithTag(1) as! UIImageView).addGestureRecognizer(tapGestureRecognizer)
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "personPhoto")!
                    
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Chat.viewPhoto(sender:)))
                    tapGestureRecognizer.delegate = self
                    (cell.viewWithTag(1) as! UIImageView).isUserInteractionEnabled = true
                    (cell.viewWithTag(1) as! UIImageView).addGestureRecognizer(tapGestureRecognizer)
                }
                let pic = chat.value(forKey: "photo") as! PFFile
                var pic2 = Data()
                do {
                    pic2 = try pic.getData()
                } catch {
                    let alert = UIAlertController(title: "Oops", message: "Couldn't get picture data", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                let image = UIImage(data: pic2)!
                print(image.size.width)
                print(image.size.height)
                (cell.viewWithTag(1) as! UIImageView).image = image
                (cell.viewWithTag(1) as! UIImageView).layer.masksToBounds = true
                (cell.viewWithTag(1) as! UIImageView).layer.cornerRadius = 7
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "typeText")!
            
            let fontStyle = [NSAttributedStringKey.font: UIFont(name: "fontello", size: 23)!]
            let title = NSAttributedString(string: (String(describing: NSString(utf8String: "\u{E801}")!)), attributes: fontStyle)
            
            (cell.viewWithTag(1) as! ChatTextView).text = ""
            (cell.viewWithTag(1) as! ChatTextView).placeholder = "Type a message"
            self.messageTextField = cell.viewWithTag(1) as! ChatTextView
            
            (cell.viewWithTag(2) as! UIButton).setAttributedTitle(title, for: UIControlState.normal)
            (cell.viewWithTag(2) as! UIButton).titleEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
            (cell.viewWithTag(2) as! UIButton).tintColor = UIColor.black
            
            (cell.viewWithTag(3) as! UIButton).titleEdgeInsets = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
            (cell.viewWithTag(3) as! UIButton).addTarget(self, action: #selector(Chat.send), for: .touchUpInside)
            (cell.viewWithTag(2) as! UIButton).addTarget(self, action: #selector(Chat.photo(sender:)), for: .touchUpInside)
            self.messageCellHeight = cell.frame.height
            (cell.viewWithTag(1) as! ChatTextView).addObserver(self, forKeyPath: "contentSize", options: [.new, .prior], context: nil)
            (cell.viewWithTag(1) as! ChatTextView).layer.borderWidth = 1
            (cell.viewWithTag(1) as! ChatTextView).layer.borderColor = UIColor.lightGray.cgColor
            (cell.viewWithTag(1) as! ChatTextView).layer.cornerRadius = 5
            (cell.viewWithTag(1) as! ChatTextView).textContainerInset.top = 7
            (cell.viewWithTag(1) as! ChatTextView).textContainerInset.bottom = 4
            cell.layer.borderWidth = 1
            (cell.viewWithTag(1) as! ChatTextView).layer.borderColor = UIColor(white: 0.90, alpha: 255.0).cgColor
            cell.layer.borderColor = UIColor(white: 0.92, alpha: 255.0).cgColor
            
            if firstTimeOpeningChat {
                firstTimeOpeningChat = false
                (cell.viewWithTag(1) as! ChatTextView).becomeFirstResponder()
            }
        }
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        if cell.reuseIdentifier! == "me" || cell.reuseIdentifier! == "mePhoto" {
            (cell.viewWithTag(2) as! UILabel).isHidden = true
            if indexPath.row == 1 {
                (cell.viewWithTag(2) as! UILabel).isHidden = !(chats[0].value(forKey: "read") as! Bool)
            }
        }
        return cell
    }
    
    @objc func viewPhoto(sender: UITapGestureRecognizer) {
        chatPhotoToView = ((sender.view!.superview!.superview! as! UITableViewCell).viewWithTag(1) as! UIImageView).image!
        isChatPhoto = true
        
        self.performSegue(withIdentifier: "viewPhoto", sender: self)
    }
    
    func addMessageToCoreData(chat: PFObject, text: String) {
        print("after setting core data and pushing notification")
        
        let chatObject = NSEntityDescription.insertNewObject(forEntityName: "Chats", into: childContext)
        chatObject.setValue(text, forKey: "message")
        
        let from = PFUser.current()!
        let to = self.user
        
        chatObject.setValue(from.objectId!, forKey: "fromId")
        chatObject.setValue(from.value(forKey: "name") as! String, forKey: "fromName")
        chatObject.setValue(from.value(forKey: "lastName") as! String, forKey: "fromLast")
        do {
            let fromPic = from.value(forKey: "pic") as! PFFile
            let data = try fromPic.getData()
            chatObject.setValue(NSData(data: data), forKey: "fromPic")
        } catch {
            print("Could not retrieve profilePic from core data")
        }
        
        chatObject.setValue(to.objectId!, forKey: "toId")
        chatObject.setValue(to.value(forKey: "name") as! String, forKey: "toName")
        chatObject.setValue(to.value(forKey: "lastName") as! String, forKey: "toLast")
        do {
            let toPic = to.value(forKey: "pic") as! PFFile
            let data = try toPic.getData()
            chatObject.setValue(NSData(data: data), forKey: "toPic")
        } catch {
            print("Could not retrieve profilePic from core data")
        }
        chatObject.setValue(allChats.count-1, forKey: "sortNum")
        chatObject.setValue(chat.objectId!, forKey: "objectId")
        
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
    
    func removeMessageFromCoreData(chat: PFObject) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chats")
        request.returnsObjectsAsFaults = false
        do {
            let anyResults = try childContext.fetch(request)
            if anyResults.count > 0 {
                var sortNumOfResultToDelete:Int?
                if let results = anyResults as? [NSManagedObject] {
                    for result in results {
                        if result.value(forKey: "objectId") as! String == chat.objectId! {
                            sortNumOfResultToDelete = result.value(forKey: "sortNum") as! Int
                            childContext.delete(result)
                        }
                    }
                    if let sortNum = sortNumOfResultToDelete {
                        for result in results {
                            if result.value(forKey: "sortNum") as! Int > sortNum {
                                result.setValue((result.value(forKey: "sortNum") as! Int)-1, forKey: "sortNum")
                            }
                        }
                    }
                }
            }
        } catch {
            print("There has been an error")
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
    
    @objc func removeMessage(sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Message", message: "Do you want to remove this message?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            let chatIndex = self.tableView.indexPath(for: sender.view!.superview!.superview! as! UITableViewCell)!.row
            let chat = chats[chatIndex-1]
            chat.deleteInBackground { (success, error) in
                if success {
                    allChats.remove(at: allChats.index(of: chat)!)
                    chats.remove(at: chatIndex-1)
                    
                    self.tableView.numberOfRows(inSection: 0)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [IndexPath(row: chatIndex, section: 0)], with: .right)
                    self.chatCount -= 1
                    self.tableView.endUpdates()
                    if chatIndex == 1 {
                        self.tableView.numberOfRows(inSection: 0)
                        self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.none)
                    }
                    /*
                    childContext.perform {
                        self.removeMessageFromCoreData(chat: chat)
                    }
 */
                } else {
                    let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func photo(sender: UIButton) {
        if !(self.user.value(forKey: "blockedUsers") as! [String]).contains(PFUser.current()!.username!) {
            isChat = true
            otherChatPerson = self.user
            let alert = UIAlertController(title: "Profile", message: "How would you like to get your photo?", preferredStyle: UIAlertControllerStyle.actionSheet)
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "camera", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "pick", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.popoverPresentationController?.sourceView = sender
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Oops", message: "You cannot send chats to this user because he/she has blocked you", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func send(sender: UIButton) {
        if !(self.user.value(forKey: "blockedUsers") as! [String]).contains(PFUser.current()!.username!) {
            UIApplication.shared.beginIgnoringInteractionEvents()
            let cell = sender.superview!.superview as! UITableViewCell
            let textView = cell.viewWithTag(1) as! ChatTextView
            let text = textView.text!
            let trimmedString = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedString.count > 0 {
                let chat = PFObject(className: "Messages")
                chat.setValue(PFUser.current()!, forKey: "from")
                chat.setValue(self.user, forKey: "to")
                chat.setValue(false, forKey: "read")
                
                chat.setValue(trimmedString, forKey: "message")
                
                chat.acl?.hasPublicReadAccess = true
                chat.acl?.hasPublicWriteAccess = true
                
                print("before saving")
                
                chat.saveInBackground { (success, error) in
                    if success {
                        print("after saving")
                        chats.insert(chat, at: 0)
                        allChats.insert(chat, at: 0)
                        
                        var shouldReloadMessageCell = false
                        
                        if self.messageCellHeight != 39.0 {
                            self.messageCellHeight = 39.0
                            shouldReloadMessageCell = true
                        }
                        
                        print("happening now")
                        self.tableView.numberOfRows(inSection: 0)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.top)
                        self.chatCount += 1
                        self.tableView.endUpdates()
                        if chats.count > 1 {
                            print(self.tableView.numberOfRows(inSection: 0))
                            if shouldReloadMessageCell {
                                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0), IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
                                self.updateContentInset()
                            } else {
                                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: UITableViewRowAnimation.none)
                            }
                        }
                        
                        textView.text = ""
                        textView.placeholder = "Type a message"
                        
                        let data = [
                            "badge" : "Increment",
                            "alert" : ["body" : text, "title": "\(PFUser.current()!.value(forKey: "name") as! String) \(PFUser.current()!.value(forKey: "lastName") as! String)"]
                            ] as [String : Any]
                        let request = [
                            "data" : data, "userId" : self.user.objectId!
                            ] as [String : Any]
                        
                        PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
                        
                        let query = PFQuery(className: "Badges")
                        query.whereKey("userId", equalTo: self.user.objectId!)
                        
                        query.getFirstObjectInBackground { (badge, error) in
                            if error == nil {
                                if badge != nil {
                                    var messagesBadge = badge!.value(forKey: "messagesBadge") as! Int
                                    messagesBadge += 1
                                    
                                    badge!.setValue(messagesBadge, forKey: "messagesBadge")
                                    
                                    badge!.saveInBackground()
                                }
                            }
                        }
                        /*
                        childContext.perform {
                            self.addMessageToCoreData(chat: chat, text: trimmedString)
                        }
 */
                        UIApplication.shared.endIgnoringInteractionEvents()
                    } else {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title: "Oops", message: "Couldn't send message", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "Oops", message: "You cannot send chats to this user because he/she has blocked you", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
