//
//  HomeViewController.swift
//  exarea
//
//  Created by Soroush on 10/28/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import ImageSlideshow
import Kingfisher

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var slideShow: ImageSlideshow!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.slideShow.setImageInputs([
            KingfisherSource(url: Bundle.main.url(forResource: "image1", withExtension: ".jpg")!),
            KingfisherSource(url: Bundle.main.url(forResource: "image2", withExtension: ".jpg")!),
            KingfisherSource(url: Bundle.main.url(forResource: "image3", withExtension: ".jpeg")!),
            KingfisherSource(url: Bundle.main.url(forResource: "image4", withExtension: ".jpeg")!)
            ])
        self.slideShow.slideshowInterval = 3
        self.slideShow.circular = true
        self.slideShow.contentScaleMode = .scaleToFill
    }
}
