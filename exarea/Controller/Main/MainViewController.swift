//
//  MainViewController.swift
//  exarea
//
//  Created by Soroush on 10/27/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

protocol TabBarViewControllerChild {
    func reloadScreen()
}

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setColors(background: .mainBlueColor, text: .mainYellowColor)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.selectedIndex = 2
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let child = self.viewControllers?[self.selectedIndex] as? TabBarViewControllerChild {
            child.reloadScreen()
        }
    }
    
    
}
