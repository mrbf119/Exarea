//
//  NotePreviewViewController.swift
//  exarea
//
//  Created by Soroush on 12/16/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class NotePreviewViewController: UIViewController {
    
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var textViewDescription: UITextView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    var note: Note!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelTitle.text = self.note.title
        self.textViewDescription.text = self.note.description
        self.textViewDescription.font = UIFont.iranSans.withSize(17)
        self.textViewDescription.textAlignment = .right
    }
}
