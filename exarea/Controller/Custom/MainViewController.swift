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
        self.navigationController?.navigationBar.setColors(background: .mainBlueColor, text: .mainYellowColor)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.backButton = UIBarButtonItem(image: UIImage(named: "icon-back-75"), style: .done, target: self, action: #selector(self.backButtonClicked))
        self.selectedIndex = 2
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let vc = self.viewControllers?[self.selectedIndex], let child = vc as? Reloadable {
            child.reloadScreen(animated: false)
        }
    }
    
    @objc private func backButtonClicked() {
        if let vc = self.viewControllers?[self.selectedIndex], let child = vc as? Reloadable {
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
    
    
    @IBAction private func searchButtonClicked() {
        self.performSegue(withIdentifier: "toSearchVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SearchViewController {
            vc.delegate = self
        }
    }
    
}

extension MainViewController: SearchVCDelegate {
    
    func searchViewController(_ searchVC: SearchViewController, didSelectBooth booth: Booth) {
        if let currentVC = self.viewControllers?[self.selectedIndex] as? UINavigationController {
            let boothVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "BoothDetailsVC") as! BoothDetailsViewController
            boothVC.booth = booth
            currentVC.pushViewController(boothVC, animated: true)
        }
    }
}
