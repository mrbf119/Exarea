//
//  FileFoldersTableViewController.swift
//  exarea
//
//  Created by Soroush on 12/11/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class FileFoldersTableViewController: UITableViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    var booth: Booth!
    private var isInLocalMode = false
    private var localCellsData: [(String, UIImage)] = [("تصاویر", #imageLiteral(resourceName: "icon-image-gallery-mainColor-small")), ("متن", #imageLiteral(resourceName: "icon-file-mainColor-small")), ("صداهای ضبط شده", #imageLiteral(resourceName: "icon-sound-mainColor-small"))]
    private var mainCellsData = ["فایل‌های ذخیره شده","فایل‌های غرفه"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LocalFilesViewController, let files = sender as? [File] {
            vc.files = files
            vc.booth = self.booth
        } else if let vc = segue.destination as? ServerFilesViewController {
            vc.booth = self.booth
        }
    }
    
    func canNavigateBack() -> Bool {
        if self.isInLocalMode {
            self.isInLocalMode = false
            self.tableView.reloadData()
            return false
        }
        return true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isInLocalMode ? 3 : 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isInLocalMode {
            let cell = tableView.dequeueReusableCell(withIdentifier: "localFileCell", for: indexPath)
            let data = self.localCellsData[indexPath.row]
            (cell.viewWithTag(2) as? UILabel)?.text = data.0
            (cell.viewWithTag(1) as? UIImageView)?.image = data.1
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath)
            cell.textLabel?.text = self.mainCellsData[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.isInLocalMode {
            var files = [File]()
            do {
                switch indexPath.row {
                case 0:  files = try self.booth.getLocalFiles(ofType: ImageFile.self)
                case 1:  files = try self.booth.getLocalFiles(ofType: NoteFile.self)
                default: files = try self.booth.getLocalFiles(ofType: AudioFile.self)
                }
            } catch {
                print(error)
            }
            self.performSegue(withIdentifier: "toMediaVC", sender: files)
        } else {
            if indexPath.row == 0 {
                self.isInLocalMode = true
                self.tableView.reloadData()
            } else {
                self.performSegue(withIdentifier: "toServerFilesVC", sender: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
