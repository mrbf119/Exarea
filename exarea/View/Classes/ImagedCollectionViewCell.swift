//
//  ImageCollectionViewCell.swift
//  exarea
//
//  Created by Soroush on 12/16/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Kingfisher

protocol Imaged {
    var imageURL: URL? { get }
}

class ImagedCollectionViewCell: ShadowableCollectionCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var buttonTrash: UIButton!
    
    weak var delegate: DeletableCollectionViewCellDelegate?
    
    var isDeletable: Bool = false {
        didSet {
            self.buttonTrash?.isHidden = !self.isDeletable
        }
    }
    
    func update(with data: Imaged) {
        if let url = data.imageURL {
            let resource = ImageResource(downloadURL: url)
            self.imageView.kf.setImage(with: resource)
            self.imageView.kf.indicatorType = .activity
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.cornerRadius = 7
        self.imageView.clipsToBounds = true
        self.buttonTrash?.isHidden = !self.isDeletable
    }
    
    @IBAction private func trashButtonClicked() {
        self.delegate?.deleteButtonTappedFor(self)
    }
}
