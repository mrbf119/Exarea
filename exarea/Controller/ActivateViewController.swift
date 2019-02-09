//
//  ActivateViewController.swift
//  exarea
//
//  Created by Soroush on 11/8/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ActivateViewController: UIViewController {
    
    @IBOutlet private var activationCodeTextField: SkyFloatingLabelTextField!
    @IBOutlet private var resendCodeButton: UIButton!
    @IBOutlet private var activateButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var centerView: UIView!
    
    var userID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    private func configUI() {
        self.activateButton.rounded()
        self.cancelButton.rounded()
        self.activationCodeTextField.titleFont = UIFont.iranSans.withSize(13)
        self.activationCodeTextField.isLTRLanguage = false
        self.activationCodeTextField.textAlignment = .center
        self.activationCodeTextField.selectedTitle = ""
        self.activationCodeTextField.title = ""
        self.resendCodeButton.makeUnderlined()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.activationCodeTextField.resignFirstResponder()
        if touches.first?.view !== self.centerView {
            self.didTapCancelButton()
        }
    }
    
    private func validate() -> String? {
        let code = self.activationCodeTextField.text!.englishNumbers
        if let failedFilter = code.passes([.notEmpty, .exactChars(5)]).failedFilter {
            self.activationCodeTextField.shake()
            self.activationCodeTextField.errorMessage = failedFilter == .notEmpty ? "لطفا شماره کد فعال سازی را وارد کنید" : "لطفا کد فعال سازی صحیح وارد کنید"
            return nil
        }
        return code
    }
    
    private func removeErrors() {
        self.activationCodeTextField.errorMessage = ""
    }
    
    @IBAction private func didTapActivateButton() {
        guard let code = self.validate() else { return }
        let form = ActivateForm.init(userID: self.userID, accountActivationCode: code)
        Account.activate(with: form) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "unwindToLoginVC", sender: nil)
        }
    }
    
    @IBAction private func didTapCancelButton() {
        self.dismiss(animated: true)
    }
}

extension ActivateViewController: UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.removeErrors()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let finalText = NSString(string: textField.text!).replacingCharacters(in: range, with: string).englishNumbers
        guard
            CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: finalText)),
            finalText.count < 6
        else { return false }
        return true
    }
}
