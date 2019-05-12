//
//  ShadowedView.swift
//  exarea
//
//  Created by Soroush on 11/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ShadowedView: UIView {
    
    @IBOutlet var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.backgroundColor = .clear
        
    }
}

class BorderedTextView: UITextView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    private func setup() {
        self.layer.cornerRadius = 7
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.borderGrey.cgColor
    }
}
