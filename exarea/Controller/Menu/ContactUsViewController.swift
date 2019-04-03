//
//  ContactUsViewController.swift
//  exarea
//
//  Created by Soroush on 11/2/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController {
    
    @IBOutlet private var contactButtons: [UIButton]!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private let urls: [URL] = [URL(string: "https://www.instagram.com/exarea_official")!,
                               URL(string: "https://twitter.com/ExArea_official")!,
                               URL(string: "https://t.me/Exarea")!,
                               URL(string: "https://www.facebook.com/ExArea_official-717955628571560")!,
                               URL(string: "https://plus.google.com/112278273047213925492")!]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "تماس با ما"
    }
    
    @IBAction private func tapped(_ contactButton: UIButton) {
        guard let index = self.contactButtons.firstIndex( where: { $0 === contactButton }) else { return }
        let url = self.urls[index]
        UIApplication.shared.openURL(url)
    }
}
