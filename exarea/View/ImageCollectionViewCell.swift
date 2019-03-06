//
//  ImageCollectionViewCell.swift
//  exarea
//
//  Created by Soroush on 12/16/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.cornerRadius = 7
        self.imageView.clipsToBounds = true
    }
    
    func makeShadowed() {
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 7
        self.clipsToBounds = false
        self.layer.shadowRadius = 3
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}
