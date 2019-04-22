//
//  FairCollectionCell.swift
//  exarea
//
//  Created by Soroush on 11/1/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Kingfisher

protocol ImageTitled: Imaged {
    var textToShow: String { get }
}

class ImageTitledCollectionCell: ImagedCollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    func update(with data: ImageTitled) {
        super.update(with: data)
        self.titleLabel.text = data.textToShow
    }
}
