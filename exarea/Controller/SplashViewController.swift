//
//  SplashViewController.swift
//  exarea
//
//  Created by Soroush on 11/8/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SplashViewController: UIViewController {
    
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!
    
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
        self.loadingIndicator.startAnimating()
        
        let shimmerView = ShimmeringView(frame: self.centerView.frame)
        self.view.addSubview(shimmerView)
        
        shimmerView.contentView = self.centerView
        shimmerView.isShimmering = true
        shimmerView.shimmerHighlightLength = 1
        shimmerView.shimmerAnimationOpacity = 0.8
        shimmerView.center = self.view.center
    }
    
    private func checkUserActivity() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let account = Account.current {
                account.loginWithToken { error in
                    guard let error = error else {
                        account.getInfo { e in
                            guard let error = e else {
                                self.goToMainVC()
                                return
                            }
                            print(error)
                        }
                        return
                    }
                    print(error)
                }
            } else {
                self.goToLoginOptionsVC()
            }
        }
    }
    
    private func goToLoginOptionsVC() {
        let homeVC = UIStoryboard(name: "Login", bundle: .main).instantiateViewController(withIdentifier: "LoginOptionsVC")
        self.navigationController?.setViewControllers([homeVC], animated: true)
    }
    
    private func goToMainVC() {
        let homeVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "MainVC")
        self.navigationController?.setViewControllers([homeVC], animated: true)
    }
}
