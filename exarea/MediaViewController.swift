//
//  MediaViewController.swift
//  exarea
//
//  Created by Soroush on 12/15/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import AVFoundation

class MediaViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var booth: Booth!
    var audioURLs: [URL]?
    var notes: [Note]?
    private var player: AVAudioPlayer!
    private var playingIndexPath: IndexPath!
    private var displayLink: CADisplayLink!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private var isNote: Bool {
        return self.notes != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NotePreviewViewController, let note = sender as? Note {
            vc.note = note
        } else if let vc = segue.destination as? NoteViewController, let note = sender as? Note {
            vc.delegate = self
            vc.note = note
        }
    }
    
}

extension MediaViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isNote ? self.notes!.count : self.audioURLs!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isNote {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteTableViewCell
            let note = self.notes![indexPath.row]
            cell.update(with: note)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as! AudioTableViewCell
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
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isNote {
            let note = self.notes![indexPath.row]
            self.performSegue(withIdentifier: "toNotePreviewVC", sender: note)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension MediaViewController: PlayableTableViewCellDelegate {
    
    func playButtonTappedFor(_ cell: UITableViewCell) {
        guard
            let indexPath = self.tableView.indexPath(for: cell),
            let audioURL = self.audioURLs?[indexPath.row]
        else { return }
        
        guard self.player != nil else {
            self.prepareToPlay(url: audioURL) {
                self.playButtonTappedFor(cell)
            }
            return
        }
        
        if self.player.isPlaying {
            if indexPath == self.playingIndexPath {
                self.player.pause()
                (cell as? AudioTableViewCell)?.configForPauseState()
            } else {
                self.player.stop()
                self.displayLink?.invalidate()
                self.player = nil
                if let lastPlayingCell = tableView.cellForRow(at: self.playingIndexPath) as? AudioTableViewCell {
                    lastPlayingCell.configForStopState()
                }
                self.playButtonTappedFor(cell)
            }
            
        } else {
            (cell as? AudioTableViewCell)?.configForPlayingState()
            self.player.play()
            self.playingIndexPath = indexPath
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.refreshPlayerTime))
            self.displayLink?.add(to: .main, forMode: .default)
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
        guard let cell = self.tableView.cellForRow(at: self.playingIndexPath) as? AudioTableViewCell else { return }
        
        if self.player.isPlaying && self.player.currentTime < self.player.duration {
            let min = Int(self.player.currentTime) / 60
            let second = Int(self.player.currentTime) % 60
            cell.setTime(min: min, sec: second)
        } else {
            self.displayLink?.invalidate()
            cell.configForStopState()
        }
    }
}

extension MediaViewController: EditableTableViewCellDelegate, DeletableTableViewCellDelegate {
    
    func deleteButtonTappedFor(_ cell: UITableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let title = "حذف فایل"
        let message = "آیا از حذف این فایل مطمئن هستید؟"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: "بله", style: .destructive) { _ in
            do {
                if let audioURL = self.audioURLs?[indexPath.row] {
                    try self.booth.deleteAudio(at: audioURL)
                    try self.audioURLs = self.booth.getAudios()
                } else if let note = self.notes?[indexPath.row] {
                    try self.booth.deleteNote(note)
                    try self.notes = self.booth.getNotes()
                }
                self.tableView.deleteRows(at: [indexPath], with: .left)
            } catch {
                print(error)
            }
        }
        let cancel = UIAlertAction(title: "خیر", style: .cancel) { _ in }
        [yes, cancel].forEach { alert.addAction($0) }
        self.present(alert, animated: true)
    }
    
    func editButtonTappedFor(_ cell: UITableViewCell) {
        guard
            let indexPath = self.tableView.indexPath(for: cell),
            let note = self.notes?[indexPath.row]
        else { return }
        
        self.performSegue(withIdentifier: "toNoteVC", sender: note)
    }
}

extension MediaViewController: NoteViewControllerDelegate {
    
    func noteVC(_ noteVC: NoteViewController, didSubmitTitle title: String, andContent content: String?) {
        return
    }
    
    
    func noteVC(_ noteVC: NoteViewController, didEdit note: Note) {
        do {
            try self.booth.saveNote(note)
            self.dismiss(animated: true)
            self.notes = try self.booth.getNotes()
        } catch {
            print(error)
        }
    }
}
