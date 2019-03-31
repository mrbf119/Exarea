//
//  FilesCategoryTableViewController.swift
//  exarea
//
//  Created by Soroush on 12/11/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class FilesCategoryTableViewController: UITableViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    var booth: Booth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MediaViewController, let files = sender as? [File] {
            vc.files = files
            vc.booth = self.booth
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var files = [File]()
        do {
            switch indexPath.row {
            case 0:  files = try self.booth.getFiles(type: ImageFile.self)
            case 1:  files = try self.booth.getFiles(type: NoteFile.self)
            default: files = try self.booth.getFiles(type: AudioFile.self)
            }
        } catch {
            print(error)
        }
        self.performSegue(withIdentifier: "toMediaVC", sender: files)
    }
}
