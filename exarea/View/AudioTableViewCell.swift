//
//  AudioTableViewCell.swift
//  exarea
//
//  Created by Soroush on 12/15/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelDescription: UILabel!
    
    func update(with note: Note) {
        self.labelTitle.text = note.title
        self.labelDescription.text = note.description
    }
}

protocol AudioCellDelegate: class {
    func playButtonTappedFor(_ cell: AudioTableViewCell)
}

class AudioTableViewCell: UITableViewCell {
    
    @IBOutlet private var btnPlay: UIButton!
    @IBOutlet private var lblTime: UILabel!
    
    weak var delegate: AudioCellDelegate?
    
    @IBAction private func playButtonClicked() {
        self.delegate?.playButtonTappedFor(self)
    }
   
    func setTime(min: Int, sec: Int) {
        self.lblTime.text = "0\(min):" +  (sec < 10 ? "0\(sec)" : "\(sec)")
        self.lblTime.sizeToFit()
    }
    
    func configForPlayingState() {
        self.btnPlay.setImage(#imageLiteral(resourceName: "icon-stop-filled-white-100"), for: .normal)
    }
    
    func configForStopState() {
        self.btnPlay.setImage(#imageLiteral(resourceName: "icon-play-filled-white-100"), for: .normal)
        self.lblTime.text = "00:00"
    }
    
    func configForPauseState() {
        self.btnPlay.setImage(#imageLiteral(resourceName: "icon-play-filled-white-100"), for: .normal)
    }
}
