//
//  CustomNavigationController.swift
//  Bebras
//
//  Created by Soroush on 17/8/1397 AP.
//  Copyright © 1396 gandom. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    private var defaultBgImage: UIImage?
    private var defaultShadowImage: UIImage?
    private var defaultBgColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.semanticContentAttribute = .forceRightToLeft
        self.defaultBgImage = self.navigationBar.backgroundImage(for: .default)
        self.defaultShadowImage = UIColor.mainYellowColor.as1ptImage()
        self.defaultBgColor = self.navigationBar.backgroundColor
        self.setDefaultSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setDefaultSettings() {
        self.navigationBar.setBackgroundImage(self.defaultBgImage, for: .default)
        self.navigationBar.shadowImage = UIColor.mainYellowColor.as1ptImage()
        self.navigationBar.backgroundColor = self.defaultBgColor
        self.navigationBar.barTintColor = .white
        self.navigationBar.isTranslucent = true
    }
    
    func clear() {
        self.navigationBar.makeTransparent(withTint: .mainYellowColor)
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.viewControllers.last
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let button = UIBarButtonItem()
        button.title = ""
        self.viewControllers.last?.navigationItem.backBarButtonItem = button
        super.pushViewController(viewController, animated: animated)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        let button = UIBarButtonItem()
        button.title = ""
        (viewControllers[safe: viewControllers.count - 2] ?? viewControllers.first)?.navigationItem.backBarButtonItem = button
        super.setViewControllers(viewControllers, animated: true)
    }
    
}
