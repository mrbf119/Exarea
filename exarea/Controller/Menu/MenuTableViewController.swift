//
//  MenuTableViewController.swift
//  exarea
//
//  Created by Soroush on 11/2/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    private let segues = ["toContactUsVC", "toAboutUsVC", "toRulesVC", "toExhibitionsVC"]
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: self.segues[indexPath.row], sender: nil)
    }
}
