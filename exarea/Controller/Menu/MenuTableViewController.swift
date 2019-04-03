//
//  MenuTableViewController.swift
//  exarea
//
//  Created by Soroush on 11/2/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Kingfisher

protocol TransitionDelegate: class {
    func viewController(_ viewController: UIViewController, didSelectVCWithID id: String)
}

class MenuViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var imageViewProfile: UIImageView!
    @IBOutlet private var labelAccountInfo: UILabel!
    @IBOutlet private var labelAccountType: UILabel!
    
    private let vcIDs = ["ContactUsVC", "AboutUsVC", "RulesVC"]
    private let items = [("تماس با ما",UIImage(named: "icon-phone-circle-100")), ("درباره ما", UIImage(named: "icon-info-100")), ("قوانین",UIImage(named: "icon-rule-100")), ("پشتیبانی",UIImage(named: "icon-support-black"))]
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    weak var transitionDelegate: TransitionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelAccountInfo.text = Account.current?.fullName
        self.labelAccountType.text = Account.current?.userRole.title
        self.imageViewProfile.rounded()
        self.imageViewProfile.bordered()
    }
    
    @IBAction private func exit() {
        let title = "خروج از حساب کاربری"
        let message = "آیا می‌خواهید از حساب کاربری خود خارج شوید؟"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: "بله", style: .default) { _ in
            self.dismiss(animated: true) {
                Account.logout()
            }
        }
        let cancel = UIAlertAction(title: "انصراف", style: .cancel) { _ in }
        [yes, cancel].forEach { alert.addAction($0) }
        self.present(alert, animated: true)
    }
}

// MARK: - Table view data source and delegate
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! ImageTitledTableViewCell
        let item = self.items[indexPath.row]
        cell.labelTitle.text = item.0
        cell.imgView.image = item.1
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 3 {
            let title = "تماس با پشتیبانی"
            let message = "آیا با پشتیبانی تماس حاصل شود؟"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let yes = UIAlertAction(title: "بله", style: .default) { _ in
                if let url = URL(string: "tel://+989129302311"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
            let cancel = UIAlertAction(title: "انصراف", style: .cancel) { _ in }
            [yes, cancel].forEach { alert.addAction($0) }
            self.present(alert, animated: true)
        } else {
            self.dismiss(animated: true) {
                self.transitionDelegate?.viewController(self, didSelectVCWithID: self.vcIDs[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
}
