//
//  AudioRecorderViewController.swift
//  exarea
//
//  Created by SoRush on 10/21/1396 AP.
//  Copyright © 1396 tamtom. All rights reserved.
//

import AVFoundation
import SwiftMessages

class AudioRecorderViewController: UIViewController {
    
    @IBOutlet fileprivate weak var btnRecord: UIButton!
    @IBOutlet fileprivate weak var btnPlay: UIButton!
    @IBOutlet fileprivate weak var btnClose: UIButton!
    @IBOutlet fileprivate weak var lblTime: UILabel!
    
    @IBOutlet var playingModeButtons: [UIButton]!
    
    private var recordSession: AVAudioSession!
    private var recorder: AVAudioRecorder!
    private var player: AVAudioPlayer!
    private var timeObserverToken: Any!
    
    var dirToRecord: URL!
    var canBeDismissed = true
    var recordURL: URL? { return self.recorder.url }
   
    
    private var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playingModeButtons.forEach { $0.isHidden = true }
        self.audioRecordingPermission()
    }
    
    
    func audioRecordingPermission() {
        
        self.recordSession = AVAudioSession.sharedInstance()
        
        do {
            self.recordSession.perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playAndRecord, with: nil)
            try self.recordSession.setActive(true)
            self.recordSession.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        self?.dismiss(animated: true)
                    }
                }
            }
        } catch {
            print("\n\n\(error)\n\n")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setRecordSettings(success: ()->()) {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderBitRateKey: 128000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try FileManager.default.createDirectory(at: self.dirToRecord, withIntermediateDirectories: true, attributes: nil)
            let url = self.dirToRecord.appendingPathComponent("audio-\(Date.timeIntervalSinceReferenceDate).m4a")
            self.recorder = try AVAudioRecorder(url: url , settings: settings)
            self.recorder.delegate = self
            success()
        } catch {
            print(error)
        }
    }
    
    func prepareToPlay(success: ()->()) {
        do {
            self.player = try AVAudioPlayer(contentsOf: self.recorder.url)
            success()
        } catch {
            print(error)
        }
    }
    
    
    @objc func refreshPlayerTime() {
        
        if self.player.isPlaying && self.player.currentTime < self.player.duration {
            let min = Int(self.player.currentTime) / 60
            let second = Int(self.player.currentTime) % 60
            self.lblTime.text = "0\(min):" +  (second < 10 ? "0\(second)" : "\(second)")
            self.lblTime.sizeToFit()
        } else {
            self.displayLink?.invalidate()
            self.btnPlay.setImage(#imageLiteral(resourceName: "icon-play-filled-white-100"), for: .normal)
            self.lblTime.text = "00:00"
        }
        
    }
    
    @objc func refreshRecorderTime() {
        let min = Int(self.recorder.currentTime) / 60
        let second = Int(self.recorder.currentTime) % 60
        self.lblTime.text = "0\(min):" +  (second < 10 ? "0\(second)" : "\(second)")
        self.lblTime.sizeToFit()
    }
    
    @IBAction func confirmTapped(_ button: UIButton) {
        
        if self.player != nil {
            self.player.stop()
        }
        
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteTapped() {
        
        guard !self.canBeDismissed else {
            return self.dismiss(animated: true)
        }
        
        self.recorder.deleteRecording()
        self.displayLink?.invalidate()
        self.lblTime.text = "00:00"
        if self.player != nil {
            self.player.stop()
            self.player = nil
        }
        
        self.playingModeButtons.forEach { $0.isHidden = true }
        self.btnRecord.setImage(#imageLiteral(resourceName: "icon-record-filled-white-100"), for: .normal)
        self.canBeDismissed = true
    }
    
    @IBAction func recordTapped() {
        
        self.canBeDismissed = false
        
        guard self.recorder != nil else {
            self.setRecordSettings(success: self.recordTapped)
            return
        }
        
        if self.recorder.isRecording {
            self.recorder.stop()
            self.displayLink?.invalidate()
            self.lblTime.text = "00:00"
            self.playingModeButtons.forEach { $0.isHidden = false }
            self.btnRecord.setImage(#imageLiteral(resourceName: "icon-record-filled-white-100"), for: .normal)
            self.btnPlay.setImage(#imageLiteral(resourceName: "icon-play-filled-white-100"), for: .normal)
            self.btnClose.isHidden = false
        } else {
            self.displayLink?.invalidate()
            self.player = nil
            self.playingModeButtons.forEach { $0.isHidden = true }
            self.btnClose.isHidden = true
            self.btnRecord.setImage(#imageLiteral(resourceName: "icon-stop-filled-white-100"), for: .normal)
            self.recorder.record()
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.refreshRecorderTime))
            self.displayLink?.add(to: .main, forMode: .default)
        }
    }
    
    @IBAction func playTapped() {
        
        guard self.player != nil else {
            self.prepareToPlay(success: self.playTapped)
            return
        }
        
        if self.player.isPlaying {
            self.player.pause()
            self.btnPlay.setImage(#imageLiteral(resourceName: "icon-play-filled-white-100"), for: .normal)
            self.displayLink?.invalidate()
        } else {
            self.btnPlay.setImage(#imageLiteral(resourceName: "icon-pause-white-100"), for: .normal)
            self.player.play()
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.refreshPlayerTime))
            self.displayLink?.add(to: .main, forMode: .default)
        }
    }
}


extension AudioRecorderViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        
    }
    
    func audioRecorderEndInterruption(_ recorder: AVAudioRecorder, withOptions flags: Int) {
        
    }
}
