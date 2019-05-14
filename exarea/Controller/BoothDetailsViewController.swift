//
//  BoothDetailsViewController.swift
//  exarea
//
//  Created by Soroush on 11/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Alamofire
import ImageSlideshow
import Kingfisher
import MapKit
import Cosmos
import Floaty
import SwiftyJSON

class BoothDetailsViewController: UIViewController {
    
    @IBOutlet private var slideShow: ImageSlideshow!
    @IBOutlet private var imageViewLogo: UIImageView!
    
    @IBOutlet private var buttonFiles: UIButton!
    @IBOutlet private var buttonTicket: UIButton!
    @IBOutlet private var buttonProducts: UIButton!
    @IBOutlet private var buttonFavorite: UIButton!
    
    @IBOutlet private var labelBoothName: UILabel!
    @IBOutlet private var floaty: Floaty!
    @IBOutlet private var labelAbout: UILabel!
    
    @IBOutlet private var cosmosViewScore: CosmosView!
    
    var fair: Fair!
    var booth: Booth!
    private var pendingScoreRequest: DataRequest?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.floaty.setNeedsUpdateConstraints()
    }
    
    private func configUI() {
        self.buttonFiles.rounded()
        self.buttonProducts.rounded()
        self.buttonFiles.bordered()
        self.buttonProducts.bordered()
        self.buttonTicket.rounded()
        self.imageViewLogo.bordered()
        self.imageViewLogo.layer.cornerRadius = self.imageViewLogo.bounds.height / 2
        
        self.configFloaty()
        self.configFavButton()
        
        self.booth.getPhotos { error in
            guard let error = error else {
                var urls = [URL]()
                for photo in self.booth.photos {
                    guard let url = photo.address else { continue }
                    urls.append(url)
                }
                self.configSlideShow(urls: urls)
                return
            }
            print(error)
        }
        
        self.booth.getScore { error in
            self.cosmosViewScore.rating = Double(self.booth.score)
        }
        
        DispatchQueue.main.async {
            self.labelBoothName.text = self.booth.title
            self.labelAbout.text = self.booth.about
            
            self.cosmosViewScore.didFinishTouchingCosmos = self.score
            if let url = self.booth.imageURL {
                let resource = ImageResource(downloadURL: url)
                self.imageViewLogo.kf.setImage(with: resource)
            }
        }
    }
    
    
    private func configFavButton() {
        self.booth.favorite(action: .is) { error in
            guard let error = error else {
                self.buttonFavorite.tintColor = self.booth.isFavorite ? .mainYellowColor : .mainBlueColor
                return
            }
            print(error)
        }
    }
    
    private func configFloaty() {
        
        self.floaty.buttonColor = .mainBlueColor
        self.floaty.plusColor = .white
        self.floaty.openAnimationType = .slideLeft
        self.floaty.animationSpeed = 0.05
        
        let camera = FloatyItem()
        camera.icon = UIImage(named: "icon-camera-yellow-90")
        camera.buttonColor = .mainBlueColor
        camera.imageSize.height *= 0.8
        camera.imageSize.width *= 0.8
        camera.handler = { _ in self.openCamera() }
        
        let note = FloatyItem()
        note.buttonColor = .mainBlueColor
        note.iconImageView.center.x += 1
        note.iconImageView.center.y += 1
        note.icon = UIImage(named: "icon-note-yellow-90")
        note.handler = { _ in self.openNote() }
        
        let record = FloatyItem()
        record.buttonColor = .mainBlueColor
        record.icon = UIImage(named: "icon-record-audio-yellow-90")
        record.handler = { _ in self.openRecorder() }
        
        [camera, note, record].forEach { self.floaty.addItem(item: $0) }
    }
    
    private func configSlideShow(urls: [URL]) {
        self.slideShow.setImageInputs(urls.map { KingfisherSource(url: $0) })
        self.slideShow.slideshowInterval = 4
        self.slideShow.circular = true
        self.slideShow.contentScaleMode = .scaleToFill
    }
    
    private func fave(_ action: Booth.FavoriteAction) {
        self.booth.favorite(action: action) { error in
            if error == nil {
                self.buttonFavorite.tintColor = self.booth.isFavorite ? .mainYellowColor : .mainBlueColor
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProductsViewController, let booth = sender as? Booth {
            vc.booth = booth
        } else if let vc = segue.destination as? AudioRecorderViewController {
            vc.dirToRecord = FileType.audio.folderURL(forBooth: self.booth) 
        } else if let vc = segue.destination as? NoteViewController {
            if let customSegue = segue as? MessagesCenteredSegue {
                customSegue.dimMode = .blur(style: .dark, alpha: 0.5, interactive: false)
                customSegue.messageView.tapHandler = { _ in
                    customSegue.destination.view.endEditing(true)
                }
            }
            vc.delegate = self
        } else if let vc = segue.destination as? FileFoldersTableViewController {
            vc.booth = self.booth
        }
    }
    
    //MARK: - actions
    
    @IBAction private func productsButtonClicked() {
        self.performSegue(withIdentifier: "toProductsVC", sender: self.booth)
    }
    
    @IBAction private func filesButtonClicked() {
        self.performSegue(withIdentifier: "toFilesVC", sender: self.booth)
    }
    
    @IBAction private func shareButtonClicked() {
        
        self.booth.getQRImage { result in
            if let qrcodeImg = result.value, let ciImage = CIImage(data: qrcodeImg), let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) {
                
                let features = detector.features(in: ciImage)
                guard let feature = (features as! [CIQRCodeFeature]).first, let url = feature.messageString else { return }
                
                let title = "EXAREA"
                let textToShow = [title, url].joined(separator: "\n")
                let activity = UIActivityViewController(activityItems: [textToShow], applicationActivities: nil)
                self.present(activity, animated: true)
                
            }
        }
    }
    
    @IBAction private func checkFave() {
        let wasLocalyFaved = self.booth.isFavorite
        
        self.booth.favorite(action: .is) { error in
            guard let error = error else {
                let isFaved = self.booth.isFavorite
                if wasLocalyFaved && isFaved {
                    self.fave(.delete)
                } else if wasLocalyFaved && !isFaved {
                    self.buttonFavorite.tintColor = .mainBlueColor
                } else if !wasLocalyFaved && isFaved {
                    self.buttonFavorite.tintColor = .mainYellowColor
                } else {
                    self.fave(.make)
                }
                return
            }
            print(error)
        }
    }
    
    @IBAction private func showInMap() {
        
        guard let latString = self.booth.latitude, let longString = self.booth.longitude else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: Double(latString)!, longitude: Double(longString)!)
        let placeMark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapitem = MKMapItem(placemark: placeMark)
        mapitem.name = self.booth.title
        
        let controller = UIActivityViewController(activityItems: [mapitem], applicationActivities: [MapActivity.google, MapActivity.waze, MapActivity.maps])
        self.present(controller, animated: true, completion: nil)
    }
    
    private func score(score: Double) {
        if let req = self.pendingScoreRequest {
            req.cancel()
        }
        
        let score = Int(self.cosmosViewScore.rating)
        self.pendingScoreRequest = self.booth.doScore(score) { error in }
    }
}

extension BoothDetailsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private func openNote() {
        self.performSegue(withIdentifier: "toNoteVC", sender: nil)
    }
    
    private func openRecorder() {
        self.performSegue(withIdentifier: "toAudioRecorderVC", sender: nil)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.cameraFlashMode = .auto
        imagePicker.showsCameraControls = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func openGallery() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true) {
            let image: UIImage
            if let img = info[.editedImage] as? UIImage {
                image = img
            } else if let img = info[.originalImage] as? UIImage {
                image = img
            } else {
                return
            }
            
            do {
                try self.booth.addImageFile(image)
                Toaster.default.toast(title: "عملیات انجام شد", content: "تصویر با موفقیت افزوده شد.")
            } catch {
                Toaster.default.toast(title: "خطا", content: NetworkError.general.failureReason!, theme: .error)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}

extension BoothDetailsViewController: NoteViewControllerDelegate {
    func noteVC(_ noteVC: NoteViewController, didSubmitTitle title: String, andContent content: String?) {
        do {
            try self.booth.addNoteFile(title: title, content: content)
            Toaster.default.toast(title: "عملیات انجام شد", content: "یادداشت با موفقیت افزوده شد.")
            self.dismiss(animated: true)
            self.floaty.setNeedsUpdateConstraints()
        } catch {
            Toaster.default.toast(title: "خطا", content: NetworkError.general.failureReason!, theme: .error)
            print(error)
        }
    }
    
    func noteVC(_ noteVC: NoteViewController, didEdit note: NoteFile) {
        return
    }
}
