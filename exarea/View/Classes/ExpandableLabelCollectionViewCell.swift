//
//  ExpandableLabelCollectionViewCell.swift
//  exarea
//
//  Created by Soroush on 1/19/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import UIKit

extension UILabel {
    var maxLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}

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
    
    func setDescription(string: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .justified
        paragraph.baseWritingDirection = .rightToLeft
        paragraph.lineBreakMode = .byTruncatingTail
        let attrString = NSAttributedString(string: string, attributes: [.font: UIFont.iranSans,
                                                                         .paragraphStyle: paragraph,
                                                                         .foregroundColor: UIColor.black])
        self.label.attributedText = attrString
        self.label.numberOfLines = self.isExtended ? 0 : 3
        
        self.buttonMore.isHidden = self.label.maxLines < 3
    }
    
    func extend() {
        self.label.numberOfLines = 0
        self.isExtended = true
        self.setButtonTitle()
    }
    
    func collapse() {
        self.label.numberOfLines = 3
        self.isExtended = false
        self.setButtonTitle()
    }
    
    @IBAction private func didTapMoreButton() {
        self.isExtended ? self.collapse() : self.extend()
        self.delegate?.expandableCell(self, didChangeState: self.isExtended)
    }
}
