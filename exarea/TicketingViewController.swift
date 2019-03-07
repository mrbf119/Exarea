//
//  TicketingViewController.swift
//  exarea
//
//  Created by Soroush on 11/22/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import SwiftMessages

class TicketingViewController: UIViewController {
    
    @IBOutlet private var textFieldName: SkyFloatingLabelTextField!
    @IBOutlet private var textFieldPhoneNumber: SkyFloatingLabelTextField!
    @IBOutlet private var textFieldTitle: SkyFloatingLabelTextField!
    @IBOutlet private var textFieldType: SkyFloatingLabelTextField!
    @IBOutlet private var textViewContent: UITextView!
    @IBOutlet private var buttonSendTicket: UIButton!
    
    private var boothAccesses = [BoothAccess]()
    private var selectedBoothAccess: BoothAccess! {
        didSet {
            self.textFieldType.text = self.selectedBoothAccess.boothAccessName
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        
        Conversation.getAllBoothAccesses { result in
            switch result {
            case .success(let accesses):
                self.boothAccesses = accesses
                self.selectedBoothAccess = accesses.first
                
            case .failure(let error):
                print(error)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func configUI() {
        
        self.textFieldTitle.isLTRLanguage = false
        self.textFieldName.isLTRLanguage = false
        self.textFieldPhoneNumber.isLTRLanguage = false
        self.textFieldType.isLTRLanguage = false
        
        self.textFieldTitle.titleFont = .iranSansEnglish
        self.textFieldName.titleFont = .iranSansEnglish
        self.textFieldPhoneNumber.titleFont = .iranSansEnglish
        self.textViewContent.font = UIFont.iranSansEnglish.withSize(17)
        self.textViewContent.textAlignment = .right
        self.buttonSendTicket.rounded()
    }
    
    
    @IBAction private func ticketButtonClicked() {
        guard let form = self.validateForm() else { return }
        Conversation.begin(with: form) { result in
            if result.isSuccess {
                self.navigationController?.popViewController(animated: true)
            } else {
                print(result.error!)
            }
        }
    }
    
    private func validateForm() -> TicketForm? {
        
        let name = self.textFieldName.text!
        let phoneNumber = self.textFieldPhoneNumber.text!.englishNumbers
        let title = self.textFieldTitle.text!
        let content = self.textViewContent.text!
        
        if let failedFilter = phoneNumber.checking([.notEmpty, .exactChars(11), .isPhoneNumber]).failedFilter {
            self.textFieldPhoneNumber.shake()
            self.textFieldPhoneNumber.errorMessage = failedFilter == .notEmpty ? "لطفا شماره تلفن خود را وارد کنید" : "لطفا شماره تلفن صحیح وارد کنید"
            return nil
        }
        
        if !name.checking([.notEmpty]).isSuccess {
            self.textFieldName.shake()
            self.textFieldName.errorMessage = "لطفا نام و نام خانوادگی خود را وارد کنید"
            return nil
        }
        
        if !title.checking([.notEmpty]).isSuccess {
            self.textFieldName.shake()
            self.textFieldName.errorMessage = "لطفا عنوان پیام خود را وارد کنید"
            return nil
        }
        
        if !content.checking([.notEmpty]).isSuccess {
            self.textFieldName.shake()
            self.textFieldName.errorMessage = "لطفا متن پیام خود را وارد کنید"
            return nil
        }
        
        return TicketForm(boothAccessID: self.selectedBoothAccess.boothAccessID, title: title, content: content)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PickerViewController {
            vc.delegate = self
        }
    }

}

extension TicketingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.boothAccesses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        let item = self.boothAccesses[row]
        label.text = item.boothAccessName
        label.font = .iranSansEnglish
        label.sizeToFit()
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedBoothAccess = self.boothAccesses[row]
        self.dismiss(animated: true)
    }
}

extension TicketingViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === self.textFieldType {
            self.performSegue(withIdentifier: "toPickerVC", sender: nil)
            self.view.endEditing(true)
            return false
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === self.textFieldPhoneNumber {
            let finalText = NSString(string: textField.text!).replacingCharacters(in: range, with: string).englishNumbers
            guard finalText.count <= 11 else { return false }
        }
        return true
    }
    
}
