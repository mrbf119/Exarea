//
//  AudioCollectionViewCell.swift
//  exarea
//
//  Created by Soroush on 12/15/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

protocol EditableCollectionViewCellDelegate: class {
    func editButtonTappedFor(_ cell: UICollectionViewCell)
}

protocol DeletableCollectionViewCellDelegate: class {
    func deleteButtonTappedFor(_ cell: UICollectionViewCell)
}

protocol PlayableCollectionViewCellDelegate: class {
    func playButtonTappedFor(_ cell: UICollectionViewCell)
}

class AudioCollectionViewCell: ShadowableCollectionCell {
    
    @IBOutlet private var btnPlay: UIButton!
    @IBOutlet private var lblTime: UILabel!
    
    weak var delegate: (PlayableCollectionViewCellDelegate & DeletableCollectionViewCellDelegate)?
    
    @IBAction private func playButtonClicked() {
        self.delegate?.playButtonTappedFor(self)
    }
    
    @IBAction private func deleteButtonClicked() {
        self.delegate?.deleteButtonTappedFor(self)
    }
   
    func setTime(min: Int, sec: Int) {
        self.lblTime.text = "0\(min):" +  (sec < 10 ? "0\(sec)" : "\(sec)")
        self.lblTime.sizeToFit()
    }
    
    func configForPlayingState() {
        self.btnPlay.setImage(#imageLiteral(resourceName: "icon-pause-white-100"), for: .normal)
    }
    
    func configForStopState() {
        self.btnPlay.setImage(#imageLiteral(resourceName: "icon-play-filled-white-100"), for: .normal)
        self.lblTime.text = "00:00"
    }
    
    func configForPauseState() {
        self.btnPlay.setImage(#imageLiteral(resourceName: "icon-play-filled-white-100"), for: .normal)
    }
}
