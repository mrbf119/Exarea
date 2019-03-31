//
//  ProfileViewController.swift
//  exarea
//
//  Created by Soroush on 11/20/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet private var textFieldFirstName: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private var textFieldLastName: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private var textFieldEmail: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private var buttonSubmit: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.contents = UIImage(named: "image-background")?.cgImage
        
        self.buttonSubmit.rounded()
        self.buttonSubmit.bordered()
        
        self.textFieldFirstName.titleFont = UIFont.iranSans
        self.textFieldFirstName.isLTRLanguage = false
        
        self.textFieldLastName.titleFont = UIFont.iranSans
        self.textFieldLastName.isLTRLanguage = false
        
        self.textFieldEmail.titleFont = UIFont.iranSans
        self.textFieldEmail.isLTRLanguage = false
        
        
        self.textFieldFirstName.text = Account.current?.firstName
        self.textFieldLastName.text = Account.current?.lastName
        self.textFieldEmail.text = Account.current?.eMailAddress
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
   
    @IBAction func submitButtonClicked() {
        guard self.validateFields() else { return }
        Account.current?.update(with: self.textFieldFirstName.text!, lastName: self.textFieldLastName.text!, email: self.textFieldEmail.text!) { error in
            print(error)
        }
    }
    
    private func validateFields() -> Bool {
        
        let firstName = self.textFieldFirstName.text!
        let lastName = self.textFieldLastName.text!
        
        if !firstName.checking([.notEmpty]).isSuccess {
            self.textFieldFirstName.shake()
            self.textFieldFirstName.errorMessage = "لطفا نام خود را وارد کنید"
            return false
        }
        
        if !lastName.checking([.notEmpty]).isSuccess {
            self.textFieldLastName.shake()
            self.textFieldLastName.errorMessage = "لطفا نام خانوادگی خود را وارد کنید"
            return false
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
