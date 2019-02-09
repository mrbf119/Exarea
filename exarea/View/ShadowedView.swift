//
//  ShadowedView.swift
//  exarea
//
//  Created by Soroush on 11/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ShadowedView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    @IBOutlet private var contentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.backgroundColor = .clear
        
    }
}
