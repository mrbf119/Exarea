//
//  MainViewController.swift
//  exarea
//
//  Created by Soroush on 10/27/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setColors(background: .mainBlueColor, text: .mainYellowColor)
    }
    

}
