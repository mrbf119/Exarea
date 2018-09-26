//
//  SplashViewController.swift
//  exarea
//
//  Created by Soroush on 7/4/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class SplashViewController: UIViewController {
    
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var signUpButton: UIButton!
    @IBOutlet private var forgotPassButton: UIButton!
    
    @IBOutlet private var phoneNumberTextField: SkyFloatingLabelTextField!
    @IBOutlet private var passwordTextField: SkyFloatingLabelTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    private func configUI() {
        self.loginButton.makeTamtomStyle()
        self.signUpButton.makeTamtomStyle()
        self.forgotPassButton.makeUnderlined()
        self.phoneNumberTextField.isLTRLanguage = false
        self.phoneNumberTextField.titleFont = UIFont.iranSans
        self.phoneNumberTextField.setTitleVisible(false)
        self.passwordTextField.isLTRLanguage = false
        self.passwordTextField.titleFont = UIFont.iranSans
    }
    
    
}

