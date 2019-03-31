//
//  MailTableViewCell.swift
//  exarea
//
//  Created by Soroush on 12/16/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class MailTableViewCell: UITableViewCell {
    
    @IBOutlet private var labelContent: UILabel!
    @IBOutlet private var labelDate: UILabel!
    
    func update(data: Mail) {
        self.labelDate.text = data.modifiedDate
        self.labelContent.text = data.content
    }
}
