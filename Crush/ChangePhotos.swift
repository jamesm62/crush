//
//  ChangePhotos.swift
//  rate
//
//  Created by James McGivern on 3/9/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Parse

var file:PFFile? = nil
var shouldUseFile = false

class ChangePhotos: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var chooseProfilePic: UIButton!
    @IBOutlet var addMorePhotos: UIButton!
    @IBOutlet var addedPhotos: UICollectionView!
    
    var originalProfilePic = UIImage()
    var originalAddedPics:[UIImage] = []
    
    var right = UIBarButtonItem()
    var left = UIBarButtonItem()
    
    var loadingAnimationView = UIImageView()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(ChangePhotos.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        left = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(ChangePhotos.cancel))
        left.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = left
        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderColor = UIColor.black.cgColor
        self.profilePic.layer.borderWidth = 2.0
        
        chooseProfilePic.layer.cornerRadius = chooseProfilePic.frame.height/2
        addMorePhotos.layer.cornerRadius = addMorePhotos.frame.height/2
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ChangePhotos.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.profilePic.addGestureRecognizer(recognizer)
        
        profilePic.isUserInteractionEnabled = true
        
        originalProfilePic = myPic!
        originalAddedPics = myAddedPicsArray
    }
    
    @objc func touched() {
        displayProfilePic = true
        self.performSegue(withIdentifier: "viewProfile", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profilePic.image = myPic
        update()
        addedPhotos.dataSource = self
        addedPhotos.delegate = self
        addedPhotos.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewImage" {
            displayProfilePic = false
            let cell = sender as! ChangeAddedPhotosCell
            photoNumber = cell.value(forKey: "tag") as! Int
        }
    }
    
    @IBAction func addMorePhotos(_ sender: Any) {
        isProfilePic = false
        let alert = UIAlertController(title: "Profile", message: "How would you like to get your photo?", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "camera", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "pick", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = addMorePhotos
        self.present(alert, animated: true, completion: nil)
    }
    
    func startLoadingAnimation() {
        loadingAnimationView = UIImageView()
        loadingAnimationView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-50, height: (self.view.frame.width-50)*0.73)
        loadingAnimationView.center = self.view.center
        
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
    
    @objc func done() {
        startLoadingAnimation()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        var didOneChange = false
        var changedProfilePic = false
        var changedAddedPhotos = false
        if myPic != originalProfilePic {
            profilePic.image = myPic
            let myPicData = UIImageJPEGRepresentation(myPic!, 0.5)!
            UserDefaults.standard.setValue(myPicData, forKey: "profilePic")
            PFUser.current()!.setValue(PFFile(data: UIImageJPEGRepresentation(myPic!, 0.5)!), forKey: "pic")
            didOneChange = true
            changedProfilePic = true
        }
        if myAddedPicsArray != originalAddedPics {
            var defaultPicsArray:[Data] = []
            
            for photoFile in myAddedPicsArray {
                defaultPicsArray.append(UIImageJPEGRepresentation(photoFile, 0.5)!)
            }
            UserDefaults.standard.setValue(defaultPicsArray, forKey: "addedPics")
            
            if shouldUseFile {
                PFUser.current()!.add(file!, forKey: "addedPics")
            } else {
                var myAddedPicsData:[PFFile] = []
                
                for myAddedPic in myAddedPicsArray {
                    myAddedPicsData.append(PFFile(data: UIImageJPEGRepresentation(myAddedPic, 0.5)!)!)
                }
                PFUser.current()!.setValue(myAddedPicsData, forKey: "addedPics")
            }
            didOneChange = true
            changedAddedPhotos = true
        }
        
        if didOneChange {
            print(PFUser.current()!.value(forKey: "addedPics"))
            PFUser.current()!.saveInBackground(block: { (success, error) in
                if success {
                    print("success")
                    print(PFUser.current()!.value(forKey: "addedPics"))
                    let badgeQuery = PFQuery(className: "Badges")
                    
                    badgeQuery.whereKey("userId", equalTo: PFUser.current()!.objectId!)
                    
                    badgeQuery.getFirstObjectInBackground { (badge, error) in
                        if error == nil {
                            if badge != nil {
                                if changedProfilePic {
                                    badge?.setValue(0, forKey: "profilePicReports")
                                }
                                if changedAddedPhotos {
                                    var newReports:[Int] = []
                                    var oldReports = badge?.value(forKey: "reports") as! [Int]
                                    for i in 0 ..< myAddedPicsArray.count {
                                        if self.originalAddedPics.contains(myAddedPicsArray[i]) {
                                            newReports.append(oldReports[self.originalAddedPics.firstIndex(of: myAddedPicsArray[i])!])
                                        } else {
                                            newReports.append(0)
                                        }
                                    }
                                    badge?.setValue(newReports, forKey: "reports")
                                }
                                badge?.saveInBackground()
                            }
                        }
                    }
                    self.stopLoadingAnimation()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.stopLoadingAnimation()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            stopLoadingAnimation()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func cancel() {
        myPic = originalProfilePic
        myAddedPicsArray = originalAddedPics
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chooseProfilePic(_ sender: Any) {
        isProfilePic = true
        isChat = false
        let alert = UIAlertController(title: "Profile", message: "How would you like to get your photo?", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "camera", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "pick", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = chooseProfilePic
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myAddedPicsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = myAddedPicsArray[indexPath.item]
        
        // Dequeue a AddedPhotosCell.
        guard let cell = addedPhotos.dequeueReusableCell(withReuseIdentifier: "cell",
                                                         for: indexPath) as? ChangeAddedPhotosCell
            else { fatalError("unexpected cell in collection view") }
        
        cell.thumbnailImage = asset
        
        cell.setValue(indexPath.item, forKey: "tag")
        
        return cell
    }
    
    public func update() {
        let viewWidth = UIScreen.main.bounds.width
        
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = addedPhotos.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
