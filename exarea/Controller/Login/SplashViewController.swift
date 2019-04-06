//
//  SplashViewController.swift
//  exarea
//
//  Created by Soroush on 11/8/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftMessages

class SplashViewController: UIViewController {
    
    @IBOutlet private var shimmerContentView: UIView!
    @IBOutlet private var loadingIndicator: NVActivityIndicatorView!
    @IBOutlet private var shimmerView: ShimmeringView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.checkUserActivity()
    }
    
    private func configUI() {
        self.view.layer.contents = UIImage(named: "image-background")?.cgImage
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.loadingIndicator.color = .mainYellowColor
        self.loadingIndicator.type = .ballPulse
        
//        self.shimmerView.contentView = self.shimmerContentView
        self.shimmerView.shimmerHighlightLength = 1
        self.shimmerView.shimmerAnimationOpacity = 0.8
        self.shimmerView.center = self.view.center
    }
    
    private func checkUserActivity() {
        self.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let account = Account.current {
                account.loginWithToken { error in
                    guard let error = error else {
                        self.getInfo(for: account)
                        return
                    }
                    self.stopLoading()
                    self.handle(error: error)
                }
            } else { Account.logout() }
        }
    }
    
    private func getInfo(for account: Account) {
        account.getInfo { error in
            guard let error = error else {
                self.goToMainVC()
                return
            }
            self.stopLoading()
            self.handle(error: error)
        }
    }
    
    @IBAction private func retryButtonClicked() {
//        self.hideRetry()
        
    }
    
    private func startLoading() {
        self.loadingIndicator.startAnimating()
        self.shimmerView.isShimmering = true
    }
    
    private func stopLoading() {
        self.loadingIndicator.stopAnimating()
        self.shimmerView.isShimmering = false
    }
    
    private func handle(error: Error) {
        if let retryNeeded = error as? RetryNeededError {
            Toaster.default.toast(error: retryNeeded) {
                self.startLoading()
                self.checkUserActivity()
            }
        }
    }
    
    private func goToMainVC() {
        let homeVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "MainVC")
        self.navigationController?.setViewControllers([homeVC], animated: true)
    }
}
