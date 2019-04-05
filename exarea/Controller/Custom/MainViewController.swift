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
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.toaster = Toaster.default
        self.navigationController?.navigationBar.setColors(background: .mainBlueColor, text: .mainYellowColor)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.backButton = UIBarButtonItem(image: UIImage(named: "icon-back-75"), style: .done, target: self, action: #selector(self.backButtonClicked))
        self.selectedIndex = 2
        self.setTitleFor(index: self.selectedIndex)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let vc = self.viewControllers?[self.selectedIndex], let child = vc as? Reloadable {
            child.reloadScreen(animated: false)
        }
        if let index = self.tabBar.items?.lastIndex(where: {  $0 === item }) {
            self.setTitleFor(index: index)
        }
    }
    
    @objc private func backButtonClicked() {
        if let vc = self.viewControllers?[self.selectedIndex], let child = vc as? Reloadable {
            child.reloadScreen(animated: self.viewControllers?[self.selectedIndex] === vc)
        }
    }
    
    private func setTitleFor(index: Int) {
        self.title = ["پسندیده‌ها","بارکد خوان","EXAREA","پیام ها","پروفایل"][index]
        self.navigationController?.navigationBar.titleTextAttributes =
            [.foregroundColor: UIColor.mainYellowColor,
             .font: index != 2 ? UIFont.iranSans.withSize(20) : UIFont.segoeUIBold.withSize(20)]
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
    
    
    @IBAction private func searchButtonClicked() {
        self.performSegue(withIdentifier: "toSearchVC", sender: nil)
    }
    
    @IBAction private func menuButtonClicked() {
        self.performSegue(withIdentifier: "toMenuVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SearchViewController {
            vc.delegate = self
        } else if let nav = segue.destination as? UINavigationController, let vc = nav.viewControllers.first as? MenuViewController {
            vc.transitionDelegate = self
        }
    }
    
}

extension MainViewController: SearchVCDelegate {
    
    func searchViewController(_ searchVC: SearchViewController, didSelectBooth booth: Booth) {
        if let currentVC = self.viewControllers?[self.selectedIndex] as? UINavigationController {
            let boothVC = UIStoryboard.init(name: "Booth", bundle: .main).instantiateViewController(withIdentifier: "BoothDetailsVC") as! BoothDetailsViewController
            boothVC.booth = booth
            currentVC.setViewControllers([currentVC.viewControllers.first!, boothVC], animated: true)
        }
    }
}

extension MainViewController: TransitionDelegate {
    
    func viewController(_ viewController: UIViewController, didSelectVCWithID id: String) {
        if let currentVC = self.viewControllers?[self.selectedIndex] as? UINavigationController {
            let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: id)
            currentVC.setViewControllers([currentVC.viewControllers.first!, vc], animated: true)
        }
    }
}
