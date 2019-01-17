//
//  EntryViewController.swift
//  exarea
//
//  Created by Soroush on 10/27/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {
    
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var RegisterButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.contents = UIImage(named: "image-background")?.cgImage
        self.loginButton.rounded()
        self.RegisterButton.rounded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction private func didTap(_ button: UIButton) {
        self.performSegue(withIdentifier: "toLoginVC", sender: button)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginViewController, let button = sender as? UIButton {
            vc.isInLoginMode = button === self.loginButton
        }
    }
}
