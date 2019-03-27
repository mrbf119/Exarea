//
//  NoteTableViewCell.swift
//  exarea
//
//  Created by Soroush on 1/8/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import UIKit

typealias EditableDeletableTableViewCell = EditableTableViewCellDelegate & DeletableTableViewCellDelegate

class NoteTableViewCell: UITableViewCell {
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelDescription: UILabel!
    
    weak var delegate: EditableDeletableTableViewCell?
    
    func update(with note: Note) {
        self.labelTitle.text = note.title
        self.labelDescription.text = note.content
    }
    
    @IBAction private func deleteButtonClicked() {
        self.delegate?.deleteButtonTappedFor(self)
    }
    
    @IBAction private func editButtonClicked() {
        self.delegate?.editButtonTappedFor(self)
    }
}
