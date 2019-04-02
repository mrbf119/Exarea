//
//  LocalFilesViewController.swift
//  exarea
//
//  Created by Soroush on 12/15/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import AVFoundation

class LocalFilesViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var booth: Booth!
    
    var files = [File]()
    
    private var imageCellSize: CGFloat { return 120.0  }
    private var imageCellMargin: CGFloat { return floor((self.view.bounds.width - (self.imageCellSize * 2)) / 3 ) }
    
    private var player: AVAudioPlayer!
    private var playingIndexPath: IndexPath!
    private var displayLink: CADisplayLink!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NotePreviewViewController, let note = sender as? NoteFile {
            vc.note = note.converted
        } else if let vc = segue.destination as? NoteViewController, let note = sender as? NoteFile {
            vc.delegate = self
            vc.note = note
        } else if let vc = segue.destination as? PreviewPopupViewController, let details = sender as? (UIImage, String) {
            vc.details = details
            (segue as? MessagesCenteredSegue)?.dimMode = .blur(style: .dark, alpha: 0.5, interactive: true)
        }
    }
    
}

extension LocalFilesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let notes = self.files as? [NoteFile] {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCollectionViewCell
            let item = notes[indexPath.item]
            cell.update(with: item.converted)
            cell.delegate = self
            cell.makeShadowed()
            return cell
        } else if let images = self.files as? [ImageFile] {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
            let image = images[indexPath.item]
            cell.imageView.image = image.converted
            cell.makeShadowed()
            cell.isDeletable = true
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "audioCell", for: indexPath) as! AudioCollectionViewCell
            cell.delegate = self
            if indexPath == self.playingIndexPath {
                if self.player.isPlaying {
                    cell.configForPlayingState()
                } else {
                    cell.configForPauseState()
                }
            } else {
                cell.configForPauseState()
            }
            cell.makeShadowed()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let notes = self.files as? [NoteFile] {
            let note = notes[indexPath.item]
            self.performSegue(withIdentifier: "toNotePreviewVC", sender: note)
        } else if let images = self.files as? [ImageFile] {
            let image = images[indexPath.item]
            let details = (image.converted, "")
            self.performSegue(withIdentifier: "toPeekVC", sender: details)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.files is [ImageFile] ? self.imageCellMargin : 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.files is [ImageFile] ? self.imageCellMargin : 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sideMargin = self.files is [ImageFile] ? self.imageCellMargin : 10
        let topBottomMargin = sideMargin
        return UIEdgeInsets(top: topBottomMargin, left: sideMargin, bottom: topBottomMargin, right: sideMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width =  self.files is [ImageFile] ? self.imageCellSize : self.view.frame.width - 20
        let height = self.files is [ImageFile] ? self.imageCellSize : 60
        return CGSize(width: width, height: height)
    }
}

extension LocalFilesViewController: PlayableCollectionViewCellDelegate {
    
    func playButtonTappedFor(_ cell: UICollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
        
        let audio = self.files[indexPath.item]
        
        guard self.player != nil else {
            self.prepareToPlay(url: audio.url) {
                self.playButtonTappedFor(cell)
            }
            return
        }
        
        if indexPath == self.playingIndexPath {
            if self.player.isPlaying {
                self.player.pause()
                self.displayLink?.invalidate()
                (cell as? AudioCollectionViewCell)?.configForPauseState()
            } else {
                self.player.play()
                (cell as? AudioCollectionViewCell)?.configForPlayingState()
                self.displayLink = CADisplayLink(target: self, selector: #selector(self.refreshPlayerTime))
                self.displayLink?.add(to: .main, forMode: .default)
            }
        } else {
            if let index = self.playingIndexPath, let lastPlayingCell = self.collectionView.cellForItem(at: index) as? AudioCollectionViewCell {
                lastPlayingCell.configForStopState()
            }
            if self.player.isPlaying {
                self.player.stop()
                self.displayLink?.invalidate()
                self.player = nil
                if let lastPlayingCell = self.collectionView.cellForItem(at: indexPath) as? AudioCollectionViewCell {
                    lastPlayingCell.configForStopState()
                }
                self.playButtonTappedFor(cell)
            } else {
                self.prepareToPlay(url: audio.url) {
                    (cell as? AudioCollectionViewCell)?.configForPlayingState()
                    self.player.play()
                    self.playingIndexPath = indexPath
                    self.displayLink = CADisplayLink(target: self, selector: #selector(self.refreshPlayerTime))
                    self.displayLink?.add(to: .main, forMode: .default)
                }
            }
        }
    }
    
    private func prepareToPlay(url: URL, success: ()->()) {
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            success()
        } catch {
            print(error)
        }
    }
    
    @objc func refreshPlayerTime() {
        guard let cell = self.collectionView.cellForItem(at: self.playingIndexPath) as? AudioCollectionViewCell else { return }
        
        if self.player.isPlaying {
            if self.player.currentTime > self.player.duration {
                self.displayLink?.invalidate()
                cell.configForStopState()
            } else {
                let min = Int(self.player.currentTime) / 60
                let second = Int(self.player.currentTime) % 60
                cell.setTime(min: min, sec: second)
            }
        } else {
            self.displayLink?.invalidate()
            cell.configForStopState()
        }
    }
}

extension LocalFilesViewController: EditableCollectionViewCellDelegate, DeletableCollectionViewCellDelegate {
    
    func deleteButtonTappedFor(_ cell: UICollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
        let title = "حذف فایل"
        let message = "آیا از حذف این فایل مطمئن هستید؟"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: "بله", style: .destructive) { _ in
            do {
                let file = self.files[indexPath.item]
                if self.player?.isPlaying ?? false {
                    self.player.stop()
                    self.displayLink.invalidate()
                    self.player = nil
                }
                try self.booth.delete(file: file)
                self.files.remove(at: indexPath.item)
                self.collectionView.deleteItems(at: [indexPath])
            } catch {
                print(error)
            }
        }
        let cancel = UIAlertAction(title: "خیر", style: .cancel) { _ in }
        [yes, cancel].forEach { alert.addAction($0) }
        self.present(alert, animated: true)
    }
    
    func editButtonTappedFor(_ cell: UICollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
        let note = self.files[indexPath.item]
        self.performSegue(withIdentifier: "toNoteVC", sender: note)
    }
}

extension LocalFilesViewController: NoteViewControllerDelegate {
    
    func noteVC(_ noteVC: NoteViewController, didSubmitTitle title: String, andContent content: String?) {
        return
    }
    
    func noteVC(_ noteVC: NoteViewController, didEdit note: NoteFile) {
        self.dismiss(animated: true)
    }
}
