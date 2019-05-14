//
//  EmbededViewController.swift
//  exarea
//
//  Created by Soroush on 11/20/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class EmbededViewController: UINavigationController {
    
    fileprivate var duringPushAnimation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true
        interactivePopGestureRecognizer?.delegate = self
    }
    
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        delegate = self
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
    }
    
    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        (self.tabBarController as? MainViewController)?.addBackButton()
        self.duringPushAnimation = true
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
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        self.duringPushAnimation = true
        super.setViewControllers(viewControllers, animated: animated)
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


extension EmbededViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let nav = navigationController as? EmbededViewController else { return }
        
        nav.duringPushAnimation = false
    }
}

extension EmbededViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true // default value
        }
        
        let result = viewControllers.count > 1 && duringPushAnimation == false
        print(result)
        return result
    }
}
