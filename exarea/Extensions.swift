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

extension UIColor {
    static let mainYellowColor = UIColor(hex: 0xfdd400)!
    static let mainBlueColor = UIColor(hex: 0x1a2035)!
}

extension UIColor {
    
    
    public convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0 && red <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
    
    public convenience init?(hex: Int, transparency: CGFloat = 1) {
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        self.init(red: red, green: green, blue: blue, transparency: trans)
    }
}

extension UIButton {
    func rounded() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.borderColor = UIColor.mainYellowColor.cgColor
        self.layer.borderWidth = 2
    }
    
    func makeUnderlined() {
        let attrs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont.iranSans.withSize(self.titleLabel!.font.pointSize),
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
