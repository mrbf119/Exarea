//
//  MenuTableViewController.swift
//  exarea
//
//  Created by Soroush on 11/2/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Kingfisher

protocol MenuTableViewDelegate: class {
    func menuTableVC(_ menuTableVC: MenuTableViewController, selectedVCWithID id: String)
}

class MenuTableViewController: UITableViewController {
    
    @IBOutlet private var imageViewProfile: UIImageView!
    @IBOutlet private var labelAccountInfo: UILabel!
    @IBOutlet private var labelAccountType: UILabel!
    
    
    private let vcIDs = ["ContactUsVC", "AboutUsVC", "RulesVC"]
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    weak var delegate: MenuTableViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        self.labelAccountInfo.text = Account.current?.fullName
        self.labelAccountType.text = Account.current?.userRole.title
        self.imageViewProfile.rounded()
        self.imageViewProfile.bordered()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.delegate?.menuTableVC(self, selectedVCWithID: self.vcIDs[indexPath.row])
        }
        
    }
}
