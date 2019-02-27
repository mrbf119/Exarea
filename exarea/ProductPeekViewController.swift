//
//  ProductPeekViewController.swift
//  exarea
//
//  Created by Soroush on 12/8/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import SwiftMessages

public class MessagesCenteredSegue: SwiftMessagesSegue {
    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        self.interactiveHide = false
        self.dimMode = .blur(style: .dark, alpha: 0.5, interactive: true)
        self.configure(layout: .centered)
        self.messageView.backgroundHeight = 250
        self.containerView.cornerRadius = 7
        
    }
}

class ProductPeekViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var labelTitle: UILabel!
    
    var details: (image: UIImage, title: String)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.details.image
        self.imageView.layer.cornerRadius = 7
        self.imageView.clipsToBounds = true
        self.labelTitle.text = self.details.title
    }
}
