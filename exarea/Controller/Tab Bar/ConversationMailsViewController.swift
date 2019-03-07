//
//  ConversationMailsViewController.swift
//  exarea
//
//  Created by Soroush on 12/16/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ConversationMailsViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!

    var conversation: Conversation!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private var mails = [Mail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.conversation.getMails { result in
            if let mails = result.value {
                self.mails = mails
                self.tableView.reloadData()
            } else {
                print(result.error)
            }
        }
    }
}

extension ConversationMailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let conversation = self.mails[indexPath.row]
        
        if conversation.senderID == Account.current!.userID {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userMailCell", for: indexPath) as! MailTableViewCell
            cell.update(data: conversation)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "adminMailCell", for: indexPath) as! MailTableViewCell
            cell.update(data: conversation)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
