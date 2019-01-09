//
//  LoginViewController.swift
//  exarea
//
//  Created by Soroush on 7/4/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class LoginViewController: UIViewController {
    
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var forgotPassButton: UIButton!
    
    @IBOutlet private var phoneNumberTextField: SkyFloatingLabelTextField!
    @IBOutlet private var passwordTextField: SkyFloatingLabelTextField!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        self.view.layer.contents = UIImage(named: "image-background")?.cgImage
        
        self.loginButton.rounded()
        self.forgotPassButton.makeUnderlined()
        self.phoneNumberTextField.titleFont = UIFont.iranSans
        self.passwordTextField.titleFont = UIFont.iranSans
        self.phoneNumberTextField.isLTRLanguage = false
        self.passwordTextField.isLTRLanguage = false
    }
    
    
}

