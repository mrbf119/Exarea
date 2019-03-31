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
    
    var files = [File]()
    
    private var player: AVAudioPlayer!
    private var playingIndexPath: IndexPath!
    private var displayLink: CADisplayLink!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NotePreviewViewController, let note = sender as? NoteFile {
            vc.note = note.converted
        } else if let vc = segue.destination as? NoteViewController, let note = sender as? NoteFile {
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
        return self.files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let notes = self.files as? [NoteFile] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteTableViewCell
            let item = notes[indexPath.row]
            cell.update(with: item.converted)
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
        if let notes = self.files as? [NoteFile] {
            let note = notes[indexPath.row]
            self.performSegue(withIdentifier: "toNotePreviewVC", sender: note)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension MediaViewController: PlayableTableViewCellDelegate {
    
    func playButtonTappedFor(_ cell: UITableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        
        let audio = self.files[indexPath.row]
        
        guard self.player != nil else {
            self.prepareToPlay(url: audio.url) {
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
                let file = self.files[indexPath.row]
                try self.booth.delete(file: file)
                self.files.remove(at: indexPath.row)
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
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let note = self.files[indexPath.row]
        self.performSegue(withIdentifier: "toNoteVC", sender: note)
    }
}

extension MediaViewController: NoteViewControllerDelegate {
    
    func noteVC(_ noteVC: NoteViewController, didSubmitTitle title: String, andContent content: String?) {
        return
    }
    
    func noteVC(_ noteVC: NoteViewController, didEdit note: NoteFile) {
        self.dismiss(animated: true)
    }
}
