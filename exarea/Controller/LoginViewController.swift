//
//  LoginViewController.swift
//  exarea
//
//  Created by Soroush on 7/4/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var forgotPassButton: UIButton!
    
    @IBOutlet private var phoneNumberTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private var passwordTextField: SkyFloatingLabelTextFieldWithIcon!
    
    @IBOutlet private var segmentControl: UISegmentedControl!
    @IBOutlet private var segmentSection: UIView!
    
    @IBOutlet var stackCenterYConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    
    var isInLoginMode = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private var centerYDiff = 0
    
    
    //MARK: - VC Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startObserveKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endObserveKeyboard()
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
        
        self.phoneNumberTextField.isLTRLanguage = false
        
        self.passwordTextField.titleFont = UIFont.iranSans
        self.passwordTextField.isLTRLanguage = false
        self.passwordTextField.iconImageView.superview!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.togglePassword)))
        
        if self.isInLoginMode {
            self.segmentSection.isHidden = true
        } else {
            self.segmentControl.setTitleTextAttributes([.font: UIFont.iranSans], for: .normal)
            self.forgotPassButton.isHidden = true
        }
    }
    
    private func startObserveKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didShowKeyboard(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func endObserveKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func didShowKeyboard(_ notif: NSNotification) {
        if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let stack = self.stackCenterYConstraint.firstItem as? UIView {
            let passFrame = stack.convert(self.passwordTextField.frame, to: self.view)
            let diff = frame.origin.y - (passFrame.origin.y + passFrame.height)
            if diff < 0 {
                self.stackCenterYConstraint.constant += diff - 10
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc private func willHideKeyboard() {
        self.stackCenterYConstraint.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func didTapLoginButton() {
        guard let form = self.validateForm() else { return }
        Account.login(with: form) { error in
            
        }
    }
    
    @objc private func togglePassword() {
        if self.passwordTextField.isSecureTextEntry {
            self.passwordTextField.iconImage = UIImage(named: "icon-eye-hide")
            self.passwordTextField.isSecureTextEntry = false
            self.passwordTextField.font = nil
            self.passwordTextField.font = UIFont.iranSans
        } else {
            self.passwordTextField.iconImage = UIImage(named: "icon-eye-show")
            self.passwordTextField.isSecureTextEntry = true
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
        return LoginForm(userName: phoneNumber, password: password)
    }
    
    private func removeErrors() {
        self.phoneNumberTextField.errorMessage = ""
        self.passwordTextField.errorMessage = ""
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.removeErrors()
        if textField === self.passwordTextField, textField.text!.isEmpty  {
            self.passwordTextField.iconImage = UIImage(named: "icon-eye-show")
            self.passwordTextField.iconImageView.isUserInteractionEnabled = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === self.passwordTextField && textField.text!.isEmpty  {
            self.passwordTextField.iconImage = UIImage(named: "icon-lock-90")
            self.passwordTextField.iconImageView.isUserInteractionEnabled = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === self.phoneNumberTextField {
            let finalText = NSString(string: textField.text!).replacingCharacters(in: range, with: string).englishNumbers
            guard finalText.count <= 11 else { return false }
        }
        return true
    }
}
