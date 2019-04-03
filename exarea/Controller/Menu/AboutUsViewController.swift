//
//  AboutUsViewController.swift
//  exarea
//
//  Created by Soroush on 1/14/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {
    
    @IBOutlet private var labelAbout: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelAbout.attributedText = RTF(resource: "About")?.content
    }
}
