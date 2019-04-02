//
//  EmbededViewController.swift
//  exarea
//
//  Created by Soroush on 11/20/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class EmbededViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        (self.tabBarController as? MainViewController)?.addBackButton()
        super.pushViewController(viewController, animated: true)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        
        if let vc = self.viewControllers.last as? FileFoldersTableViewController, !vc.canNavigateBack() {
            return nil
        } else {
            if self.viewControllers.count < 3 {
                (self.tabBarController as? MainViewController)?.removeBackButton()
            }
            return super.popViewController(animated: animated)
        }
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        (self.tabBarController as? MainViewController)?.removeBackButton()
        return super.popToRootViewController(animated: animated)
    }
}

extension EmbededViewController: Reloadable {
    
    func reloadScreen(animated: Bool = true) {
        if self.viewControllers.count > 1 {
            _ = self.popViewController(animated: animated)
        } else {
            if let root = self.viewControllers.first as? Reloadable {
                root.reloadScreen(animated: animated)
            }
        }
    }
}
