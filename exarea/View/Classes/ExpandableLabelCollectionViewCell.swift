//
//  ExpandableLabelCollectionViewCell.swift
//  exarea
//
//  Created by Soroush on 1/19/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import UIKit

protocol ExpandableLabelCollectionViewCellDelegate: class {
    func expandableCell(_ cell: ExpandableLabelCollectionViewCell, didChangeState isExtened: Bool)
}

class ExpandableLabelCollectionViewCell: ShadowableCollectionCell {
    
    @IBOutlet var label: UILabel!
    @IBOutlet private var buttonMore: UIButton!
    
    private(set) var isExtended = false
    weak var delegate: ExpandableLabelCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setButtonTitle()
    }
    
    private func setButtonTitle() {
        let title = self.isExtended ? "کمتر" : "بیشتر"
        self.buttonMore.setTitle(title, for: .normal)
    }
    
    @IBAction private func didTapMoreButton() {
        self.label.numberOfLines = self.isExtended ? 3 : 0
        self.isExtended = !self.isExtended
        self.setButtonTitle()
        self.delegate?.expandableCell(self, didChangeState: self.isExtended)
    }
}
