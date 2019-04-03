//
//  Extensions.swift
//  exarea
//
//  Created by Soroush on 7/4/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Alamofire
import SwiftMessages

extension SwiftMessages {
    
    static func toastError(content: String? = nil) {
        let generalError = "عملیات با مشکل مواجه شد."
        self.toast(content: content ?? generalError , theme: .error)
    }
    
    static func toast(content: String, theme: Theme = .success) {
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(theme)
        view.bodyLabel?.font = UIFont.iranSans.withSize(17)
        view.configureDropShadow()
        view.configureContent(body: content)
        view.layoutMarginAdditions = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        SwiftMessages.show(view: view)
    }
}

extension Notification {
    static let logout = Notification(name: .init("exarea.logout"))
}

extension UIView {
    func rounded() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    func bordered(width: CGFloat = 2, color: UIColor = .mainYellowColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
}

public extension Collection {
    
    public subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Collection where Index == Int {
    
    public func indices(where condition: (Element) throws -> Bool) rethrows -> [Index]? {
        var indicies: [Index] = []
        for (index, value) in lazy.enumerated() where try condition(value) {
            indicies.append(index)
        }
        return indicies.isEmpty ? nil : indicies
    }
}

public extension UINavigationBar {
    
    public func setTitleFont(_ font: UIFont, color: UIColor = .black) {
        var attrs = [NSAttributedString.Key: Any]()
        attrs[.font] = font
        attrs[.foregroundColor] = color
        titleTextAttributes = attrs
    }
    
    public func makeTransparent(withTint tint: UIColor) {
        isTranslucent = true
        backgroundColor = .clear
        barTintColor = .clear
        setBackgroundImage(UIImage(), for: .default)
        tintColor = tint
        titleTextAttributes = [.foregroundColor: tint]
        shadowImage = UIImage()
    }
    
    public func setColors(background: UIColor, text: UIColor) {
        isTranslucent = false
        backgroundColor = background
        barTintColor = background
        setBackgroundImage(UIImage(), for: .default)
        tintColor = text
        titleTextAttributes = [.foregroundColor: text]
    }
}

extension UIDevice {
    static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

extension UIFont {
    static let iranSans = UIFont(name: "IRANSansMobileFaNum", size: 15)!
    static let iranSansEnglish = UIFont(name: "IRANSansMobile", size: 15)!
    static let segoeUIBold = UIFont(name: "SegoeUI-Bold", size: 15)!
    static let segoeUI = UIFont(name: "SegoeUI", size: 15)!
}

extension UIColor {
    static let mainYellowColor = UIColor(hex: 0xfdd400)!
    static let mainBlueColor = UIColor(hex: 0x1a2035)!
    static var borderGrey = UIColor(hex: 0xC0C1C0)!
    
    func as1ptImage() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 3))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx?.fill(CGRect(x: 0, y: 0, width: 1, height: 3))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
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
    
    func makeUnderlined(color: UIColor? = nil, fontSize: CGFloat? = nil) {
        let attrs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : self.titleLabel!.font.withSize(fontSize ?? self.titleLabel!.font.pointSize),
            NSAttributedString.Key.foregroundColor : color ?? self.currentTitleColor,
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
    
    enum ValidationResult {
        case success
        case failure(ValidationFilter)
        
        var isSuccess: Bool {
            if case .success = self {
                return true
            } else {
                return false
            }
        }
        
        var failedFilter: ValidationFilter? {
            if case .failure(let filter) = self {
                return filter
            } else {
                return nil
            }
        }
    }
    
    func checking(_ validations: [ValidationFilter]) -> ValidationResult {
        let sorted = validations.sorted(by: { $0.sortIndex < $1.sortIndex })
        if let filter = sorted.first(where: { $0.notPasses(string: self)}) {
            return .failure(filter)
        }
        return .success
    }
    
    enum ValidationFilter {
        
        static func ==(lhs: ValidationFilter, rhs: ValidationFilter) -> Bool {
            return lhs.sortIndex == rhs.sortIndex
        }
        
        case notEmpty
        case minChars(Int)
        case maxChars(Int)
        case exactChars(Int)
        case isNumber
        case isPhoneNumber
        case charset(CharacterSet, setDec: String)
        case rangeChars(Int, Int) 
        
        fileprivate var sortIndex: Int {
            switch self {
            case .notEmpty:      return 0
            case .minChars:      return 1
            case .maxChars:      return 2
            case .exactChars:    return 3
            case .isNumber:      return 4
            case .isPhoneNumber: return 5
            case .charset:       return 6
            case .rangeChars:    return 7
            }
        }
        
        func notPasses(string: String) -> Bool {
            switch self {
            case .notEmpty:                return string == ""
            case .maxChars(let max):       return string.count > max
            case .minChars(let min):       return string.count < min
            case .exactChars(let exact):   return string.count != exact
            case .isPhoneNumber:           return !string.isPhoneNumber
            case .isNumber:                return !string.isNumber
            case .charset(let set, _):
                let subset = CharacterSet(charactersIn: string)
                return !set.isSuperset(of: subset)
            case .rangeChars(let min, let max):
                return !(string.count <= max && string.count >= min)
            }
        }
        
        fileprivate func errorMessage(textInputName: String) -> String {
            switch self {
            case .notEmpty:
                return "لطفا " + textInputName + " را وارد کنید"
            case .maxChars(let max):
                return textInputName + " نباید بیشتر از" + " \(max) " + "کاراکتر داشته باشد"
            case .minChars(let min):
                return textInputName + " نباید کمتر از" + " \(min) " + "کاراکتر داشته باشد"
            case .isNumber:
                return textInputName + " باید فقط شامل عدد باشد"
            case .isPhoneNumber, .exactChars:
                return "لطفا " + textInputName + " صحیح وارد کنید"
            case .exactChars(let exact):
                return textInputName + " باید" + " \(exact) " + "کاراکتر داشته باشد"
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
    
    var englishNumbers: String {
        return self
            .replacingOccurrences(of: "٠", with: "0").replacingOccurrences(of: "۰", with: "0")
            .replacingOccurrences(of: "١", with: "1").replacingOccurrences(of: "۱", with: "1")
            .replacingOccurrences(of: "٢", with: "2").replacingOccurrences(of: "۲", with: "2")
            .replacingOccurrences(of: "٣", with: "3").replacingOccurrences(of: "۳", with: "3")
            .replacingOccurrences(of: "٤", with: "4").replacingOccurrences(of: "۴", with: "4")
            .replacingOccurrences(of: "٥", with: "5").replacingOccurrences(of: "۵", with: "5")
            .replacingOccurrences(of: "٦", with: "6").replacingOccurrences(of: "۶", with: "6")
            .replacingOccurrences(of: "٧", with: "7").replacingOccurrences(of: "۷", with: "7")
            .replacingOccurrences(of: "٨", with: "8").replacingOccurrences(of: "۸", with: "8")
            .replacingOccurrences(of: "٩", with: "9").replacingOccurrences(of: "۹", with: "9")
    }
}
