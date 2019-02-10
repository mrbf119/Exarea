//
//  MainViewController.swift
//  exarea
//
//  Created by Soroush on 10/27/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

protocol Reloadable {
    func reloadScreen(animated: Bool)
}

class MainViewController: UITabBarController {
    
    private var backButton: UIBarButtonItem!
    
    private var lastSelectedIndex: Int = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setColors(background: .mainBlueColor, text: .mainYellowColor)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.selectedIndex = self.lastSelectedIndex
        self.backButton = UIBarButtonItem(image: UIImage(named: "icon-back-75"), style: .done, target: self, action: #selector(self.backButtonClicked))
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let vc = self.viewControllers?[self.lastSelectedIndex], let child = vc as? Reloadable {
            child.reloadScreen(animated: self.viewControllers?[self.selectedIndex] === vc)
        }
        self.lastSelectedIndex = self.selectedIndex
    }
    
    @objc private func backButtonClicked() {
        if let vc = self.viewControllers?[self.lastSelectedIndex], let child = vc as? Reloadable {
            child.reloadScreen(animated: self.viewControllers?[self.selectedIndex] === vc)
        }
    }
    
    func addBackButton() {
        if self.navigationItem.leftBarButtonItem !== self.backButton {
            self.navigationItem.setLeftBarButtonItems([self.backButton, self.navigationItem.leftBarButtonItem!], animated: true)
        }
    }
    
    func removeBackButton() {
        if self.navigationItem.leftBarButtonItem === self.backButton {
            self.navigationItem.setLeftBarButtonItems([self.navigationItem.leftBarButtonItems!.last!], animated: true)
        }
    }
}
