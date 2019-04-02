//
//  ServerFileTableViewCell.swift
//  exarea
//
//  Created by Soroush on 1/13/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import UIKit

protocol DownloadableTableViewCellDelegate: class {
    func downloadButtonTappedFor(_ cell: UITableViewCell)
}


class ServerFileTableViewCell: UITableViewCell {
    
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelState: UILabel!
    @IBOutlet private var stackDownload: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stackDownload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapDownloadButton)))
    }
    
    weak var delegate: DownloadableTableViewCellDelegate?
    
    func config(state: BoothFileWrapper.State) {
        self.labelState.text = state.title
    }
    
    @objc private func didTapDownloadButton() {
        self.delegate?.downloadButtonTappedFor(self)
    }
}
