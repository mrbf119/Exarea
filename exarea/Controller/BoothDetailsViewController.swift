//
//  BoothDetailsViewController.swift
//  exarea
//
//  Created by Soroush on 11/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import ImageSlideshow
import Kingfisher
import MapKit

class BoothDetailsViewController: UIViewController {
    
    @IBOutlet private var slideShow: ImageSlideshow!
    @IBOutlet private var imageViewLogo: UIImageView!
    @IBOutlet private var buttonFiles: UIButton!
    @IBOutlet private var buttonTicket: UIButton!
    @IBOutlet private var buttonProducts: UIButton!
    @IBOutlet private var labelBoothName: UILabel!
    
    
    var booth: Booth!

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
        self.slideShow.setImageInputs([
            KingfisherSource(url: Bundle.main.url(forResource: "image1", withExtension: ".jpg")!),
            KingfisherSource(url: Bundle.main.url(forResource: "image2", withExtension: ".jpg")!),
            KingfisherSource(url: Bundle.main.url(forResource: "image3", withExtension: ".jpeg")!),
            KingfisherSource(url: Bundle.main.url(forResource: "image4", withExtension: ".jpeg")!)
            ])
        self.slideShow.slideshowInterval = 4
        self.slideShow.circular = true
        self.slideShow.contentScaleMode = .scaleToFill
        
        self.imageViewLogo.layer.cornerRadius = self.imageViewLogo.bounds.height / 2
        
        DispatchQueue.main.async {
            self.labelBoothName.text = self.booth.title
            if let url = self.booth.imageURL {
                let resource = ImageResource(downloadURL: url)
                self.imageViewLogo.kf.setImage(with: resource)
            }
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
}
