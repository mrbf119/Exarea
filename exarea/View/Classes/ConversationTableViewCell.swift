//
//  ConversationTableViewCell.swift
//  exarea
//
//  Created by Soroush on 12/16/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    
    @IBOutlet private var labelRecipientName: UILabel!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelDate: UILabel!
    
    func update(data: Conversation) {
        self.labelRecipientName.text = data.recipientName
        self.labelTitle.text = data.title
        self.labelDate.text = data.modifiedDate
    }
}
