//
//  BarcodeScannerViewController.swift
//  khodroyaar
//
//  Created by Alireza on 3/22/1397 AP.
//  Copyright © 1397 gandom. All rights reserved.
//

import UIKit
import AVFoundation

protocol BarcodeScannerDelegate: class {
    func barcodeScanner(_ scanner: BarcodeScannerViewController, didCapture barcode: String)
}

class BarcodeScannerViewController: UIViewController {
    
    // MARK: - properties
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var validBounds: CGRect!
    private var canStartSession: Bool {
        return self.previewLayer != nil && !(self.captureSession?.isRunning)!
    }
    
    weak var delegate: BarcodeScannerDelegate?
    
    // MARK: - view controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.checkPersmission { granted in
            if granted {
                DispatchQueue.main.async { self.configBarcodeScanner() }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.canStartSession {
            self.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.captureSession?.isRunning)! {
            self.captureSession.stopRunning()
        }
    }
    
    // MARK: - methods
    
    func stopSession() {
        self.captureSession?.stopRunning()
    }
    
    func startSession() {
        self.captureSession?.startRunning()
    }
    
    func vibarte() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    private func configBarcodeScanner() {
        self.captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            print("input - not supported this device")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("output - not supported this device")
            return
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.previewLayer)
        self.configBorderView()
        self.captureSession.startRunning()
    }
    
    private func checkPersmission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            self.askForPermissions(completion)
        default:
            completion(false)
        }
    }
    
    private func askForPermissions(_ completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    }
    
    private func configBorderView() {
        
        
        guard let mainView = self.previewLayer else { return }
        let boxHeight: CGFloat = 250
        let boxWidth: CGFloat = 250
        let boxOrigin = CGPoint(x: (mainView.bounds.width - boxWidth)/2, y: (mainView.bounds.height - boxHeight)/2)
        let boxSize = CGSize(width: boxWidth, height: boxHeight)
        self.validBounds = CGRect(origin: boxOrigin, size: boxSize)
        
        UIGraphicsBeginImageContext(mainView.bounds.size)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setFillColor(UIColor.mainBlueColor.cgColor)
        ctx.setAlpha(0.8)
        ctx.fill(mainView.bounds)
        ctx.clear(CGRect(origin: boxOrigin, size: boxSize))
        ctx.setAlpha(1)
        ctx.setLineWidth(2)
        ctx.setStrokeColor(UIColor.mainYellowColor.cgColor)
        ctx.setFillColor(UIColor.mainYellowColor.cgColor)
        ctx.setLineCap(.round)
        
        let offset: CGFloat = 20
        
        ctx.addLines(between: [CGPoint(x: boxOrigin.x, y: boxOrigin.y + offset),
                               boxOrigin,
                               CGPoint(x: boxOrigin.x + offset, y: boxOrigin.y)])
        
        ctx.addLines(between: [CGPoint(x: boxOrigin.x + boxSize.width - offset, y: boxOrigin.y),
                               CGPoint(x: boxOrigin.x + boxSize.width, y: boxOrigin.y),
                               CGPoint(x: boxOrigin.x + boxSize.width, y: boxOrigin.y + offset)])
        
        ctx.addLines(between: [CGPoint(x: boxOrigin.x + boxSize.width, y: boxOrigin.y + boxSize.height - offset),
                               CGPoint(x: boxOrigin.x + boxSize.width, y: boxOrigin.y + boxSize.height),
                               CGPoint(x: boxOrigin.x + boxSize.width - offset, y: boxOrigin.y + boxSize.height)])
        
        ctx.addLines(between: [CGPoint(x: boxOrigin.x + offset, y: boxOrigin.y + boxSize.height),
                               CGPoint(x: boxOrigin.x, y: boxOrigin.y + boxSize.height),
                               CGPoint(x: boxOrigin.x, y: boxOrigin.y + boxSize.height - offset)])
        
        ctx.drawPath(using: .stroke)
        
        guard let image = ctx.makeImage() else { return }
        UIGraphicsEndImageContext()
        let img = UIImage(cgImage: image)
        let imgView = UIImageView(image: img)
        mainView.addSublayer(imgView.layer)
    }
    
    // MARK: - navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard !metadataObjects.isEmpty else { return print("no bar code scanned") }
        
        if let metadataObject = metadataObjects.first {
            guard
                let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue,
                let barcodeObject = self.previewLayer.transformedMetadataObject(for: metadataObject)
            else { return }
            
            guard self.validBounds.contains(barcodeObject.bounds) else { return }
            print("barcode: ", stringValue)
            self.delegate?.barcodeScanner(self, didCapture: stringValue)
        }
    }
}


extension BarcodeScannerViewController: BarcodeScannerDelegate {
    func barcodeScanner(_ scanner: BarcodeScannerViewController, didCapture barcode: String) {
        self.stopSession()
        
    }
}
