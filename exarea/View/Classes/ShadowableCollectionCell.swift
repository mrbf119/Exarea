//
//  ShadowableCollectionCell.swift
//  exarea
//
//  Created by Soroush on 1/14/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import UIKit

class ShadowableCollectionCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    
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
