//
//  Extensions.swift
//  exarea
//
//  Created by Soroush on 7/4/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

extension UIFont {
    static let iranSans = UIFont(name: "IRANSans", size: 15)!
}

extension UIButton {
    func makeTamtomStyle() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.borderColor = UIColor(named: "color-font")?.cgColor
        self.layer.borderWidth = 2
    }
    
    func makeUnderlined() {
        let attrs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont.iranSans.withSize(12),
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.underlineStyle : 1]
        
        let attributedString = NSMutableAttributedString(string: "رمز عبور خود را فراموش کرده‌ام", attributes: attrs)
        
        UIView.setAnimationsEnabled(false)
        self.setAttributedTitle(attributedString, for: .normal)
        self.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
}

enum LinePosition {
    case bottom, top
}

extension UITextField {
    func setPlaceHolder(color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    func setUnderLine(height: CGFloat, color: UIColor) {
        
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: height)
        self.addSubview(border)
        self.translatesAutoresizingMaskIntoConstraints = false
        border.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        border.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        border.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        border.heightAnchor.constraint(equalToConstant: height).isActive = true
//        border.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        border.setContentHuggingPriority(.init(rawValue: 100), for: .horizontal)
    }
}
