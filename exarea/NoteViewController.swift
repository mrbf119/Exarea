//
//  NoteViewController.swift
//  exarea
//
//  Created by Soroush on 12/9/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

protocol NoteViewContorolerDelegate: class {
    func noteVC(_ noteVC: NoteViewController, didSubmitTitle title: String, andDescription description: String?)
}

class NoteViewController: UIViewController {
    
    @IBOutlet private var buttonCancel: UIButton!
    @IBOutlet private var buttonSubmit: UIButton!

    @IBOutlet private var textFieldTitle: UITextField!
    @IBOutlet private var textViewDescription: UITextView!
    
    
    weak var delegate: NoteViewContorolerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view === self.view {
            self.view.endEditing(true)
        }
    }
    
    private func configUI() {
        self.buttonCancel.rounded()
        self.buttonSubmit.rounded()
    }
    
    func isValid() -> Bool {
        return !self.textFieldTitle.text!.isEmpty
    }
    
    @IBAction private func submit() {
        guard self.isValid() else { return }
        self.delegate?.noteVC(self, didSubmitTitle: self.textFieldTitle.text!, andDescription: self.textViewDescription.text)
    }
    
    @IBAction private func cancel() {
        self.dismiss(animated: true)
    }
}
