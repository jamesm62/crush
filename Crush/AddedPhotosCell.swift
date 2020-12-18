//
//  AddedPhotosCell.swift
//  rate
//
//  Created by James McGivern on 12/24/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit

class AddedPhotosCell: UICollectionViewCell {
    
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


