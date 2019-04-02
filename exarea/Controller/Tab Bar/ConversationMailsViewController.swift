//
//  ConversationMailsViewController.swift
//  exarea
//
//  Created by Soroush on 12/16/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import GrowingTextView
import IQKeyboardManagerSwift

class ConversationMailsViewController: UIViewController {
    
    @IBOutlet private var buttonSend: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private var textView: GrowingTextView!
    
    var conversation: Conversation!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private var mails = [Mail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.refreshData()
    }
    
    private func configUI() {
        self.buttonSend.rounded()
        self.textView.maxHeight = 120
        IQKeyboardManager.shared.enable = false
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notif:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notif:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc private func keyboardWillShow(notif: Notification) {
        guard let x = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        self.bottomConstraint.constant = x.height
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.mails.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    @objc private func keyboardWillHide(notif: Notification) {
        self.bottomConstraint.constant = 5
    }
    
    private func refreshData() {
        self.conversation.getMails { result in
            if let mails = result.value {
                self.mails = mails
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath.init(row: self.mails.count - 1, section: 0), at: .bottom, animated: false)
                }
            } else {
                print(result.error)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        IQKeyboardManager.shared.enable = true
        super.viewWillDisappear(animated)
    }
    
    @IBAction private func didTapSendButton() {
        guard !self.textView.text.isEmpty else { return }
        self.conversation.resume(content: self.textView.text) { error in
            if error == nil {
                self.textView.text = ""
                self.refreshData()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.textView.isFirstResponder {
            self.textView.resignFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension ConversationMailsViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.mails.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
}
