//
//  RulesViewController.swift
//  exarea
//
//  Created by Soroush on 11/2/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class RTF {
    
    let content: NSAttributedString
    
    init?(resource: String) {
        var attributes: NSDictionary? = nil
        guard
            let url = Bundle.main.url(forResource: resource, withExtension: "rtf"),
            let attr = try? NSAttributedString(url: url, options: [.documentType : NSAttributedString.DocumentType.rtf], documentAttributes: &attributes)
        else { return nil }
        self.content = attr
    }
}

class RulesViewController: UIViewController {
    
    @IBOutlet private var scrollViewContainer: UIView!
    @IBOutlet private var labelRules: UILabel!
    
    private var gradient: CAGradientLayer!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelRules.attributedText = RTF(resource: "Rules")?.content
        self.gradient = CAGradientLayer()
        self.gradient.frame = self.scrollViewContainer.bounds
        self.gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        self.gradient.locations = [0, 0, 0.6, 1]
        self.scrollViewContainer.layer.mask = self.gradient
        gradient.duration = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradient.frame = self.scrollViewContainer.bounds
    }

}

extension RulesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let ratio = NSNumber(value: Double(scrollView.contentOffset.y / scrollView.contentSize.height))
        let end = 0.6 + Double(scrollView.contentOffset.y / scrollView.contentSize.height)
        let ratioR = NSNumber(value: end > 1 ? 1 : end)
        self.gradient.locations = [0, ratio, ratioR , 1]
        
    }
}
