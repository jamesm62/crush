//
//  ChangeAddedPhotosCell.swift
//  rate
//
//  Created by James McGivern on 3/9/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit

class ChangeAddedPhotosCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImage = nil
    }
}
