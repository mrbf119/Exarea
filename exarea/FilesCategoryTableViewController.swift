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
        if let vc = segue.destination as? MediaViewController {
            if let data = sender as? [URL] {
                vc.audioURLs = data
            } else if let data = sender as? [Note] {
                vc.notes = data
            }
        } else if let vc = segue.destination as? ImagesViewController, let images = sender as? [UIImage] {
            vc.images = images
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.showImages()
        case 1:
            self.showData(isNote: true)
        default:
            self.showData(isNote: false)
        }
    }
    
    
    private func showImages() {
        do {
            let images = try self.booth.getImage()
            self.performSegue(withIdentifier: "toImagesVC", sender: images)
        } catch {
            print(error)
        }
    }
    
    private func showData(isNote: Bool) {
        do {
            if isNote {
                let notes = try self.booth.getNotes()
                self.performSegue(withIdentifier: "toMediaVC", sender: notes)
            } else {
                let audios = try self.booth.getAudios()
                self.performSegue(withIdentifier: "toMediaVC", sender: audios)
            }
        } catch {
            print(error)
        }
    }
}
