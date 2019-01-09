//
//  LoginViewController.swift
//  exarea
//
//  Created by Soroush on 7/4/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var forgotPassButton: UIButton!
    
    @IBOutlet private var phoneNumberTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private var passwordTextField: SkyFloatingLabelTextFieldWithIcon!
    
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
        
//        self.passwordTextField.icon
    }
    
    @IBAction private func didTapLoginButton() {
        guard let form = self.validateForm() else { return }
        User.login(with: form) { error in
            
        }
    }
    
    private func validateForm() -> LoginForm? {
        
        let phoneNumber = self.phoneNumberTextField.text!.englishNumbers
        let password = self.passwordTextField.text!
        
        if let failedFilter = phoneNumber.passes([.notEmpty, .exactChars(11), .isPhoneNumber]).failedFilter {
            self.phoneNumberTextField.shake()
            self.phoneNumberTextField.errorMessage = failedFilter == .notEmpty ? "لطفا شماره تلفن خود را وارد کنید" : "لطفا شماره تلفن صحیح وارد کنید"
            return nil
        }
        
        if !password.passes([.notEmpty]).isSuccess {
            self.passwordTextField.shake()
            self.passwordTextField.errorMessage = "لطفا کلمه عبور خود را وارد کنید"
            return nil
        }
        return LoginForm(phoneNumber: phoneNumber, password: password)
    }
    
    private func removeErrors() {
        self.phoneNumberTextField.errorMessage = ""
        self.passwordTextField.errorMessage = ""
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.removeErrors()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === self.phoneNumberTextField {
            let finalText = NSString(string: textField.text!).replacingCharacters(in: range, with: string).englishNumbers
            guard finalText.count <= 11 else { return false }
        }
        return true
    }
    
}


