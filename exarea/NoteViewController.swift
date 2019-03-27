//
//  NoteViewController.swift
//  exarea
//
//  Created by Soroush on 12/9/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

protocol NoteViewControllerDelegate: class {
    func noteVC(_ noteVC: NoteViewController, didSubmitTitle title: String, andContent content: String?)
    func noteVC(_ noteVC: NoteViewController, didEdit note: Note)
}

class NoteViewController: UIViewController {
    
    @IBOutlet private var buttonCancel: UIButton!
    @IBOutlet private var buttonSubmit: UIButton!

    @IBOutlet private var textFieldTitle: UITextField!
    @IBOutlet private var textViewDescription: UITextView!
    
    
    var note: Note?
    weak var delegate: NoteViewControllerDelegate?
    
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
        self.textFieldTitle.text = self.note?.title
        self.textViewDescription.text = self.note?.content
    }
    
    private func isValid() -> Bool {
        return !self.textFieldTitle.text!.isEmpty
    }
    
    @IBAction private func submit() {
        guard self.isValid() else { return }
        
        if var note = self.note {
            note.title = self.textFieldTitle.text!
            note.content = self.textViewDescription.text
            self.delegate?.noteVC(self, didEdit: note)
        } else {
            self.delegate?.noteVC(self, didSubmitTitle: self.textFieldTitle.text!, andContent: self.textViewDescription.text)
        }
    }
    
    @IBAction private func cancel() {
        self.dismiss(animated: true)
    }
}
