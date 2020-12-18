//
//  Photos.swift
//  rate
//
//  Created by James McGivern on 12/8/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit

var isProfilePic = true

var photoNumber = 0

var displayProfilePic = false

class Photos: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var addMorePhotos: UIButton!
    @IBOutlet var addedPhotos: UICollectionView!
    @IBOutlet var chooseProfilePic: UIButton!
    
    var right = UIBarButtonItem()
    
    override func viewDidLoad() {
        right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(Photos.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderColor = UIColor.black.cgColor
        self.profilePic.layer.borderWidth = 2.0
        
        addMorePhotos.layer.cornerRadius = addMorePhotos.frame.height/2
        chooseProfilePic.layer.cornerRadius = chooseProfilePic.frame.height/2
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(Photos.touched))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.profilePic.addGestureRecognizer(recognizer)
        
        profilePic.isUserInteractionEnabled = true
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(addedPics)
        right.isEnabled = true
    }
    
    @objc func touched() {
        displayProfilePic = true
        self.performSegue(withIdentifier: "viewProfile", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profilePic.image = pic
        update()
        addedPhotos.dataSource = self
        addedPhotos.delegate = self
        addedPhotos.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewImage" {
            displayProfilePic = false
            let cell = sender as! AddedPhotosCell
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
    
    @objc func done() {
        if profilePic.image == UIImage(named: "profilePic.png")! {
            let alert = UIAlertController(title: "Oops", message: "Please select a profile picture", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if addedPics.count > 8 {
            let alert = UIAlertController(title: "Oops", message: "You can only upload 8 extra photos", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "school", sender: self)
        }
    }
    
    @IBAction func chooseProfilePic(_ sender: Any) {
        isProfilePic = true
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
        return addedPics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = addedPics[indexPath.item]
        
        // Dequeue a AddedPhotosCell.
        guard let cell = addedPhotos.dequeueReusableCell(withReuseIdentifier: "cell",
                                                         for: indexPath) as? AddedPhotosCell
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
