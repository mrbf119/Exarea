//
//  ShadowableCollectionCell.swift
//  exarea
//
//  Created by Soroush on 1/14/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import Kingfisher

protocol Shadowable where Self: UIView {
    
    var containerView: UIView! { get }
    
    func makeShadowed()
}

extension Shadowable {
    
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

class ShadowableCollectionCell: UICollectionViewCell, Shadowable {
    @IBOutlet var containerView: UIView!
}

class ImageReusableView: UICollectionReusableView, Shadowable  {
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    func update(data: Imaged) {
        if let url = data.imageURL {
            let resource = ImageResource(downloadURL: url)
            self.imageView.kf.setImage(with: resource)
            self.imageView.kf.indicatorType = .activity
        }
    }
}
