//
//  ServerFilesViewController.swift
//  exarea
//
//  Created by Soroush on 1/12/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import UIKit
import Alamofire

class ServerFilesViewController: UIViewController {
    
    private static var pendingDownloadRequests = [URL]()
    
    @IBOutlet private var tableView: UITableView!
    
    var booth: Booth!
    private var files = [BoothFileWrapper]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.getData()
    }
    
    private func getData() {
        self.booth.getServerFiles { result in
            switch result {
            case .success(let files):
                self.files = files.map { BoothFileWrapper(id: URL(string: $0.fileAddress)!, file: $0) }
                
                for file in self.files {
                    if ServerFilesViewController.pendingDownloadRequests.contains(file.id) {
                        file.state = .downloading
                    } else {
                        file.state = self.booth.hasDownloaded(file: file.file) ? .downloaded : .notDownloaded
                    }
                }
                
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func openPDF(url: URL) {
        DispatchQueue.main.async {
            let vc = UIDocumentInteractionController(url: url)
            vc.delegate = self
            vc.presentPreview(animated: true)
        }
    }
}

extension ServerFilesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! ServerFileTableViewCell
        let item = self.files[indexPath.row]
        cell.delegate = self
        cell.config(state: item.state)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.files[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        guard self.booth.hasDownloaded(file: item.file), let selectedCell = cell else { return }
        self.downloadButtonTappedFor(selectedCell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension ServerFilesViewController: DownloadableTableViewCellDelegate {
    
    func downloadButtonTappedFor(_ cell: UITableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let item = self.files[indexPath.row]
        ServerFilesViewController.pendingDownloadRequests.append(item.id)
        let request = self.booth.open(file: item.file) { result in
            ServerFilesViewController.pendingDownloadRequests.removeAll { $0 == item.id }
            switch result {
            case .success(let url):
                (cell as? ServerFileTableViewCell)?.config(state: .downloaded)
                self.openPDF(url: url)
            case .failure(let error):
                (cell as? ServerFileTableViewCell)?.config(state: .notDownloaded)
                print(error)
            }
        }
        
        guard let req = request else { return }
        
        req.downloadProgress { progress in
            print(progress)
        }
    }
}

extension ServerFilesViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
