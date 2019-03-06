//
//  MenuTableViewController.swift
//  exarea
//
//  Created by Soroush on 11/2/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

protocol MenuTableViewDelegate: class {
    func menuTableVC(_ menuTableVC: MenuTableViewController, selectedVCWithID id: String)
}

class MenuTableViewController: UITableViewController {
    
    private let vcIDs = ["ContactUsVC", "AboutUsVC", "RulesVC"]
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    weak var delegate: MenuTableViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.delegate?.menuTableVC(self, selectedVCWithID: self.vcIDs[indexPath.row])
        }
        
    }
}
