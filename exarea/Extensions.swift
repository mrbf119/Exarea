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
        
        let attributedString = NSMutableAttributedString(string: self.titleLabel!.text!, attributes: attrs)
        
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
}

extension String {
    func check(if validations: [ValidationFilter], textInputName: String) -> String? {
        let sorted = validations.sorted(by: { $0.sortIndex < $1.sortIndex })
        guard let filter = sorted.first(where: {$0.appliesOn(string: self)}) else {
            return nil
        }
        return filter.errorMessage(textInputName: textInputName)
    }
    
    
    func check(if validations: [ValidationFilter]) -> Bool {
        let sorted = validations.sorted(by: { $0.sortIndex < $1.sortIndex })
        return sorted.contains { $0.appliesOn(string: self) }
    }
    
    enum ValidationFilter {
        case notEmpty
        case minChars(Int)
        case maxChars(Int)
        case exactChars(Int)
        case beNumber
        case bePhoneNumber
        case charset(CharacterSet, setDec: String)
        case rangeChars(Int, Int)
        
        var sortIndex: Int {
            switch self {
            case .notEmpty:      return 0
            case .minChars:      return 1
            case .maxChars:      return 2
            case .exactChars:    return 3
            case .beNumber:      return 4
            case .bePhoneNumber: return 5
            case .charset:       return 6
            case .rangeChars:      return 7
            }
        }
        
        func appliesOn(string: String) -> Bool {
            switch self {
            case .notEmpty:                return string != ""
            case .maxChars(let max):       return string.count < max
            case .minChars(let min):       return string.count > min
            case .exactChars(let exact):   return string.count == exact
            case .bePhoneNumber:           return string.isPhoneNumber
            case .beNumber:                return string.isNumber
            case .charset(let set, _):
                let subset = CharacterSet(charactersIn: string)
                return set.isSuperset(of: subset)
            case .rangeChars(let min, let max):
                return string.count <= max || string.count >= min
            }
        }
        
        fileprivate func errorMessage(textInputName: String) -> String {
            switch self {
            case .notEmpty:
                return textInputName + " نباید خالی باشد"
            case .maxChars(let max):
                return textInputName + " نباید بیشتر از" + " \(max) " + "کاراکتر داشته باشد"
            case .minChars(let min):
                return textInputName + " نباید کمتر از" + " \(min) " + "کاراکتر داشته باشد"
            case .exactChars(let exact):
                return textInputName + " باید" + " \(exact) " + "کاراکتر داشته باشد"
            case .beNumber:
                return textInputName + " باید فقط شامل عدد باشد"
            case .bePhoneNumber:
                return textInputName + " را به درستی وارد کنید"
            case .charset(_, let desc):
                return textInputName + " باید فقط شامل " + desc + " باشد"
            case .rangeChars(let min, let max):
                var string = textInputName + " باید "
                if max - min == 1 {
                    string += "\(min)" + " یا " + "\(max)"
                } else {
                    string += "بین " + "\(min)" + " تا " + "\(max)"
                }
                string += " کاراکتر داشته باشد"
                return string
            }
        }
    }
    
    public var isPhoneNumber: Bool {
        let regex = try! NSRegularExpression(pattern: "^09[0-9]{9}$", options: [.caseInsensitive])
        return regex.firstMatch(in: self, options:[], range: NSMakeRange(0, utf16.count)) != nil
    }
    
    public var isNumber: Bool {
        let regex = try! NSRegularExpression(pattern: "^[0-9]*$", options: [.caseInsensitive])
        return regex.firstMatch(in: self, options:[], range: NSMakeRange(0, utf16.count)) != nil
    }
    
    public var isFarsi: Bool {
        let alphabet = "ابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهی"
        var b = true
        for char in self {
            b = b && alphabet.contains(String(char))
            guard b == true else { return false }
        }
        return true
    }
}
