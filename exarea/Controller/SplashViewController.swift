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
        self.view.layer.contents = UIImage(named: "image-background")?.cgImage
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
}
