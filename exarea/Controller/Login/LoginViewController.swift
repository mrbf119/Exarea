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
    
    //MARK: - Properties
    
    var isInLoginMode = true
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private var centerYDiff = 0
    
    
    //MARK: - VC Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        (self.navigationController as? CustomNavigationController)?.clear()
        
    }
    
    //MARK: Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func configUI() {
        
        self.view.layer.contents = UIImage(named: "image-background")?.cgImage
        
        self.loginButton.rounded()
        self.loginButton.bordered()
        self.forgotPassButton.makeUnderlined()
        
        self.phoneNumberTextField.titleFont = UIFont.iranSans
        self.phoneNumberTextField.isLTRLanguage = false
        
        self.passwordTextField.titleFont = UIFont.iranSans
        self.passwordTextField.isLTRLanguage = false
        self.passwordTextField.iconImageView.isUserInteractionEnabled = true
        self.passwordTextField.iconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.togglePassword)))
        
        if self.isInLoginMode {
            self.segmentSection.isHidden = true
        } else {
            self.segmentControl.setTitleTextAttributes([.font: UIFont.iranSans], for: .normal)
            self.forgotPassButton.isHidden = true
        }
    }
   
    @objc private func togglePassword() {
        if self.passwordTextField.isSecureTextEntry {
            self.passwordTextField.iconImage = UIImage(named: "icon-eye-hide")
            self.passwordTextField.isSecureTextEntry = false
            self.passwordTextField.font = nil
            self.passwordTextField.font = UIFont.iranSansEnglish
        } else {
            self.passwordTextField.iconImage = UIImage(named: "icon-eye-show")
            self.passwordTextField.isSecureTextEntry = true
        }
    }
    
    private func removeErrors() {
        self.phoneNumberTextField.errorMessage = ""
        self.passwordTextField.errorMessage = ""
    }
    
    @IBAction private func didTapLoginButton() {
        guard let form = self.validateForm() else { return }

        if self.isInLoginMode {
            let form = LoginForm(userName: form.user, password: form.pass)
            Account.login(with: form) { error in
                if let error = error {
                    return print(error.localizedDescription)
                }
                self.goToMainVC()
            }
        } else {
            let form = RegisterForm(userName: form.user, password: form.pass, roleID: RegisterForm.Role(self.segmentControl.selectedSegmentIndex)!)
            Account.register(with: form) { result in
                switch result {
                case .success(let userID):
                    self.performSegue(withIdentifier: "toActivateVC", sender: userID)
                case .failure(let error):
                    return print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
        if segue.source is ActivateViewController {
            self.goToMainVC()
        }
    }
    
    private func goToMainVC() {
        let homeVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "MainVC")
        self.navigationController?.setViewControllers([homeVC], animated: true)
    }
    
    private func validateForm() -> (user: String, pass: String)? {
        
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
        return (phoneNumber, password)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ActivateViewController, let userID = sender as? String {
            vc.userID = userID
        }
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
