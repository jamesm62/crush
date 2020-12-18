//
//  ChangePhotosLibrary.swift
//  rate
//
//  Created by James McGivern on 3/16/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import Parse
import CoreData

private let reuseIdentifier = "Cell"

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class ChangePhotosLibrary: UICollectionViewController {
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    var right = UIBarButtonItem()
    
    var photo = UIImage()
    
    // MARK: UIViewController / Lifecycle
    
    override func viewDidLoad() {
        self.collectionView?.allowsSelection = true
        self.collectionView?.allowsMultipleSelection = false
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        // If we get here without a segue, it's because we're visible at app launch,
        // so match the behavior of segue from the default "All Photos" view.
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.includeAllBurstAssets = true
            allPhotosOptions.includeHiddenAssets = true
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        
        if isChat {
            right = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(ChangePhotosCamera.done))
            right.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem = right
            right.isEnabled = false
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateItemSize()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateItemSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let asset = fetchResult.object(at: indexPath.item)
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        options.resizeMode = .exact
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill, options: options, resultHandler: { image, _ in
            var tmpImg = UIImage()
            if image!.size.width < image!.size.height {
                UIGraphicsBeginImageContextWithOptions(
                    CGSize(width:image!.size.width, height:image!.size.width),
                    false, 0)
                image!.draw(at:CGPoint(x: 0, y: -(image!.size.height-image!.size.width)/2))
                tmpImg = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            } else {
                UIGraphicsBeginImageContextWithOptions(
                    CGSize(width:image!.size.height, height:image!.size.height),
                    false, 0)
                image!.draw(at:CGPoint(x: -(image!.size.width-image!.size.height)/2, y: 0))
                tmpImg = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }
            
            if isChat {
                self.photo = tmpImg
                cell?.layer.borderWidth = 3.0
                cell?.layer.borderColor = UIColor.blue.cgColor
                self.right.isEnabled = true
            } else {
                if isProfilePic {
                    myPic = tmpImg
                } else {
                    myAddedPicsArray.append(tmpImg)
                    let capturedFile = PFFile(data: UIImageJPEGRepresentation(tmpImg, 0.5)!)!
                    if file == nil {
                        file = capturedFile
                        shouldUseFile = true
                    } else {
                        shouldUseFile = false
                    }
                    myAddedPicsArrayFiles.append(capturedFile)
                }
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0.0
    }
    
    func addPhotoToCoreData(chat: PFObject) {
        let data = [
            "badge" : "Increment",
            "alert" : ["body" : "Sent a photo", "title": "\(PFUser.current()!.value(forKey: "name") as! String) \(PFUser.current()!.value(forKey: "lastName") as! String)"]
            ] as [String : Any]
        let request = [
            "data" : data, "userId" : otherChatPerson.objectId!
            ] as [String : Any]
        
        PFCloud.callFunction(inBackground: "push", withParameters: request as [NSObject : AnyObject])
        
        /*
        
        let coreDataChat = NSEntityDescription.insertNewObject(forEntityName: "Chats", into: childContext)
        
        coreDataChat.setValue(chat.objectId!, forKey: "objectId")
        
        coreDataChat.setValue(NSData(data: UIImageJPEGRepresentation(self.photo, 0.5)!), forKey: "photo")
 */
        
        let from = PFUser.current()!
        let to = otherChatPerson
        
        let query = PFQuery(className: "Badges")
        query.whereKey("userId", equalTo: to.objectId!)
        
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
        
        coreDataChat.setValue(from.objectId!, forKey: "fromId")
        coreDataChat.setValue(from.value(forKey: "name") as! String, forKey: "fromName")
        coreDataChat.setValue(from.value(forKey: "lastName") as! String, forKey: "fromLast")
        do {
            let fromPic = from.value(forKey: "pic") as! PFFile
            let data = try fromPic.getData()
            coreDataChat.setValue(NSData(data: data), forKey: "fromPic")
        } catch {
            print("Could not retrieve profilePic from core data")
        }
        
        coreDataChat.setValue(to.objectId!, forKey: "toId")
        coreDataChat.setValue(to.value(forKey: "name") as! String, forKey: "toName")
        coreDataChat.setValue(to.value(forKey: "lastName") as! String, forKey: "toLast")
        do {
            let toPic = to.value(forKey: "pic") as! PFFile
            let data = try toPic.getData()
            coreDataChat.setValue(NSData(data: data), forKey: "toPic")
        } catch {
            print("Could not retrieve profilePic from core data")
        }
        coreDataChat.setValue(allChats.count, forKey: "sortNum")
        
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
 */
    }
    
    @objc func done() {
        if isChat {
            UIApplication.shared.beginIgnoringInteractionEvents()
            let chat = PFObject(className: "Messages")
            chat.setValue(PFUser.current()!, forKey: "from")
            chat.setValue(otherChatPerson, forKey: "to")
            chat.setValue(false, forKey: "read")
            
            let image = PFFile(data: UIImageJPEGRepresentation(self.photo, 0.5)!)
            chat.setValue(image, forKey: "photo")
            
            chat.acl?.hasPublicReadAccess = true
            chat.acl?.hasPublicWriteAccess = true
            
            chat.saveInBackground { (success, error) in
                if success {
                    allChats.insert(chat, at: 0)
                    chats.insert(chat, at: 0)
                    shouldReloadChat = true
                    /*
                    childContext.perform {
                        self.addPhotoToCoreData(chat: chat)
                    }
 */
                    
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let alert = UIAlertController(title: "Oops", message: "Couldn't send message", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    private func updateItemSize() {
        
        let viewWidth = view.bounds.size.width
        
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
    
    // MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                            for: indexPath) as? ChangePhotosGridCell
            else { fatalError("unexpected cell in collection view") }
        
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        options.resizeMode = .exact
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill, options: options, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.thumbnailImage = image
            }
        })
        
        return cell
        
    }
    
    // MARK: UIScrollView
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        options.resizeMode = .exact
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill, options: options)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill, options: options)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
}

// MARK: PHPhotoLibraryChangeObserver
extension ChangePhotosLibrary: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, !changed.isEmpty {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves ({ (fromIndex, toIndex) in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    })
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
    }
}
