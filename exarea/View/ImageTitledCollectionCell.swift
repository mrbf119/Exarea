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
    var textToShow: String { get }
}

class SlideShowHeaderView: UICollectionReusableView {
    @IBOutlet var slideShow: ImageSlideshow!
}

class ImageTitledCollectionCell: ImageCollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    func update(with data: ImageTitled) {
        if let url = data.imageURL {
            let resource = ImageResource(downloadURL: url)
            self.imageView.kf.setImage(with: resource)
            self.imageView.kf.indicatorType = .activity
        }
        self.titleLabel.text = data.textToShow
    }
}
