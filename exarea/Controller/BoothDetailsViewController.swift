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

class BoothDetailsViewController: UIViewController {
    
    @IBOutlet private var slideShow: ImageSlideshow!
    @IBOutlet private var imageViewLogo: UIImageView!
    
    @IBOutlet private var buttonFiles: UIButton!
    @IBOutlet private var buttonTicket: UIButton!
    @IBOutlet private var buttonProducts: UIButton!
    @IBOutlet private var buttonFavorite: UIButton!
    
    @IBOutlet private var labelBoothName: UILabel!
    @IBOutlet private var floaty: Floaty!
    @IBOutlet private var textViewAbout: UITextView!
    
    @IBOutlet private var cosmosViewScore: CosmosView!
    
    var booth: Booth!
    private var pendingScoreRequest: DataRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
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
        
        DispatchQueue.main.async {
            self.labelBoothName.text = self.booth.title
            self.textViewAbout.text = self.booth.about
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
        camera.handler = { _ in print("open camera") }
        
        let note = FloatyItem()
        note.buttonColor = .mainBlueColor
        note.iconImageView.center.x += 1
        note.iconImageView.center.y += 1
        note.icon = UIImage(named: "icon-note-yellow-90")
        note.handler = { _ in print("open note") }
        
        let record = FloatyItem()
        record.buttonColor = .mainBlueColor
        record.icon = UIImage(named: "icon-record-audio-yellow-90")
        record.handler = { _ in print("open record") }
        
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
    
    @IBAction private func score() {
        if let req = self.pendingScoreRequest {
            req.cancel()
        }
        
        let score = Int(self.cosmosViewScore.rating)
        self.pendingScoreRequest = self.booth.doScore(score) { error in
            if let error = error {
                print(error)
            } else {
                self.cosmosViewScore.rating = Double(self.booth.score)
            }
        }
    }
}
