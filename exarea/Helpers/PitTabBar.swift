//
//  RollingPitTabBar.swift
//  VBRRollingPit
//
//  Created by Viktor Braun on 27.07.2018.
//  Copyright © 2018 Viktor Braun - Software Development. All rights reserved.
//

import UIKit

let pi = CGFloat.pi
let pi2 = CGFloat.pi / 2

extension CGFloat {
    public func toRadians() -> CGFloat {
        return self * CGFloat.pi / 180.0
    }
}

extension UITabBarItem {
    var view: UIView? {
        return self.value(forKey: "view") as? UIView
    }
}

@IBDesignable class PitTabBar: UITabBar {
    
    @IBInspectable public var barBackColor: UIColor = UIColor.white
    @IBInspectable public var barHeight: CGFloat = 65
    
    @IBInspectable public var circleBackColor: UIColor = UIColor.white
    @IBInspectable public var circleRadius: CGFloat = 40
    
    let pitCornerRad: CGFloat = 10
    let pitCircleDistanceOffset: CGFloat = 0
    
    private lazy var circle: CAShapeLayer = {
        let result = CAShapeLayer()
        result.fillColor = self.circleBackColor.cgColor
        result.lineWidth = 4
        result.strokeColor = UIColor.mainYellowColor.cgColor
        return result
    }()
    
    private lazy var backgroundMask : CAShapeLayer = {
        let result = CAShapeLayer()
        result.fillRule = CAShapeLayerFillRule.evenOdd
        return result
    }()
    
    private lazy var background: CAShapeLayer = {
        let result = CAShapeLayer();
        result.fillColor = self.barBackColor.cgColor
        result.mask = self.backgroundMask
        return result
    }()
    
    private var circleXCenter: CGFloat {
        let totalWidth = self.bounds.width
        return totalWidth / 2
    }

    private var barRect: CGRect {
        let h = self.barHeight
        let w = self.bounds.width
        let x = self.bounds.minX
        let y = self.circleRadius
        
        let rect = CGRect(x: x, y: y, width: w, height: h)
        return rect
    }
    
    private var circleRect: CGRect {
        let x = self.circleXCenter - self.circleRadius
        let y = self.barRect.origin.y - self.circleRadius + self.pitCircleDistanceOffset
        let pos = CGPoint(x: x, y: y)
        let result = CGRect(origin: pos, size: CGSize(width: self.circleRadius * 2, height: self.circleRadius * 2))
        return result
    }
    
    private var circlePath: CGPath {
        let result = UIBezierPath(roundedRect: circleRect, cornerRadius: self.circleRect.height / 2);
        return result.cgPath
    }
    
    func createPitMaskPath(rect: CGRect) -> CGMutablePath {
        let x = self.circleXCenter + self.pitCornerRad
        let y = self.barRect.origin.y
        let center = CGPoint(x: x, y: y)
        let maskPath = CGMutablePath()
        maskPath.addRect(rect)
        let pit = self.createPitPath(center: center)
        maskPath.addPath(pit)
        return maskPath
    }
    
    func createPitPath(center : CGPoint) -> CGPath{
        let rad = self.circleRadius + 5
        let x = center.x - rad - pitCornerRad
        let y = center.y
        
        let result = UIBezierPath()
        result.lineWidth = 0
        result.move(to: CGPoint(x: x - 0, y: y + 0))
        
        result.addArc(withCenter: CGPoint(x: (x - pitCornerRad), y: (y + pitCornerRad)), radius: pitCornerRad, startAngle: CGFloat(270).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: true)
        
        result.addArc(withCenter: CGPoint(x: (x + rad), y: (y + pitCornerRad ) ), radius: rad, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: false)
        
        result.addArc(withCenter: CGPoint(x: (x + (rad * 2) + pitCornerRad), y: (y + pitCornerRad) ), radius: pitCornerRad, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(270).toRadians(), clockwise: true)
        
        result.addLine(to: CGPoint(x: x + (pitCornerRad * 2) + (rad * 2), y: y)) // rounding errors correction lines
        result.addLine(to: CGPoint(x: 0, y: 0))
        
        result.close()
        
        return result.cgPath
    }
    
    private func createBackgroundPath() -> CGPath {
        let rect = self.barRect
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y:rect.minY))
        
        path.addArc(withCenter: CGPoint(x: rect.maxX, y: rect.minY), radius: 0, startAngle: 3 * pi2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addArc(withCenter: CGPoint(x: rect.maxX, y: rect.maxY), radius: 0, startAngle: 0, endAngle: pi2, clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addArc(withCenter: CGPoint(x: rect.minX, y: rect.maxY), radius: 0, startAngle: pi2, endAngle: pi, clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addArc(withCenter: CGPoint(x: rect.minX, y: rect.minY), radius: 0, startAngle: pi, endAngle: 3 * pi2, clockwise: true)
        path.close()
        
        return path.cgPath
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = self.barHeight + self.circleRadius
        return sizeThatFits
    }
    
    private func getTabBarItemViews() -> [(item : UITabBarItem, view : UIView)] {
        guard let items = self.items else{ return [] }
        var result : [(item : UITabBarItem, view : UIView)] = []
        for item in items {
            if let v = item.view {
                result.append((item: item, view: v))
            }
        }
        return result
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.background.fillColor = self.barBackColor.cgColor
        self.circle.fillColor = self.circleBackColor.cgColor
        self.layoutElements()
    }
    
    private func layoutElements(){
        self.background.path = self.createBackgroundPath()
        if self.backgroundMask.path == nil {
            self.backgroundMask.path = self.createPitMaskPath(rect: self.bounds)
            self.circle.path = self.circlePath
        }
        self.positionCenterItem()
    }
    
    private func positionCenterItem() {
        
        guard let items = self.items, self.items!.count % 2 != 0 else { return }
        
        let centerItemIndex = (items.count / 2)
        let centerItem = items[centerItemIndex]
        guard let centerItemView = centerItem.view else { return }
        
        centerItemView.bounds.size.width = self.circleRect.width
        centerItemView.bounds.size.height = self.circleRect.height
        centerItemView.center.y = self.circleRect.midY
        
        for item in items {
            if item !== centerItem {
                item.view?.frame.size.height = self.barHeight
                item.view?.frame.origin.y = self.bounds.height - self.barHeight
            }
        }
    }
    
    override func prepareForInterfaceBuilder() {
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
        self.background.fillColor = self.barBackColor.cgColor
        self.circle.fillColor = self.circleBackColor.cgColor
    }
    
    private func setup(){
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
        self.layer.insertSublayer(self.background, at: 0)
        self.layer.insertSublayer(self.circle, at: 0)
        self.tintColor = UIColor.mainYellowColor
        self.items?.forEach({
            $0.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            $0.title = nil
        })
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
}



