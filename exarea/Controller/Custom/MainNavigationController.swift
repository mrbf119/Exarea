//
//  MainNavigationController.swift
//  Bebras
//
//  Created by Soroush on 17/8/1397 AP.
//  Copyright © 1396 gandom. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    private var defaultBgImage: UIImage?
    private var defaultShadowImage: UIImage?
    private var defaultBgColor: UIColor?
    private var defaultDefaultTintColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.logout), name: Notification.logout.name, object: nil)
        self.view.semanticContentAttribute = .forceRightToLeft
        self.defaultBgImage = self.navigationBar.backgroundImage(for: .default)
        self.defaultShadowImage = UIColor.mainYellowColor.as1ptImage()
        self.defaultBgColor = self.navigationBar.backgroundColor
        self.defaultDefaultTintColor = self.navigationBar.barTintColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc private func logout() {
        let homeVC = UIStoryboard(name: "Login", bundle: .main).instantiateViewController(withIdentifier: "LoginOptionsVC")
        self.setViewControllers([homeVC], animated: true)
    }
    
    func setDefaultSettings() {
        self.navigationBar.setBackgroundImage(self.defaultBgImage, for: .default)
        self.navigationBar.shadowImage = UIColor.mainYellowColor.as1ptImage()
        self.navigationBar.backgroundColor = self.defaultBgColor
        self.navigationBar.barTintColor = self.defaultDefaultTintColor
        self.navigationBar.isTranslucent = false
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
