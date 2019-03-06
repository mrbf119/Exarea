//
//  PreviewPopupViewController.swift
//  exarea
//
//  Created by Soroush on 12/8/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class PreviewPopupViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var labelTitle: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    var details: (image: UIImage, title: String)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.details.image
        self.imageView.layer.cornerRadius = 7
        self.imageView.clipsToBounds = true
        self.labelTitle.text = self.details.title
    }
}
