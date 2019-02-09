//
//  FairCollectionCell.swift
//  exarea
//
//  Created by Soroush on 11/1/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Kingfisher
import ImageSlideshow
import Floaty

protocol ImageTitled {
    var imageURL: URL? { get }
    var description: String { get }
}

class SlideShowHeaderView: UICollectionReusableView {
    @IBOutlet var slideShow: ImageSlideshow!
}

class ImageTitledCollectionCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    
    func makeShadowed() {
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 7
        self.clipsToBounds = false
        self.layer.shadowRadius = 3
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    func update(with data: ImageTitled) {
        if let url = data.imageURL {
            let resource = ImageResource(downloadURL: url)
            self.imageView.kf.setImage(with: resource)
            self.imageView.kf.indicatorType = .activity
        }
        self.titleLabel.text = data.description
    }
}
