//
//  ConversationListViewController.swift
//  exarea
//
//  Created by Soroush on 12/16/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ConversationListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private var conversations = [Conversation]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Conversation.sentByUser { result in
            switch result {
            case .success(let conversations):
                self.conversations = conversations
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ConversationMailsViewController, let conversation = sender as? Conversation {
            vc.conversation = conversation
        }
    }
}

extension ConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! ConversationTableViewCell
        let conversation = self.conversations[indexPath.row]
        cell.update(data: conversation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = self.conversations[indexPath.row]
        self.performSegue(withIdentifier: "toMailsVC", sender: conversation)
    }
}
