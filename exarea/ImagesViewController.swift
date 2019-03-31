//
//  ImagesViewController.swift
//  exarea
//
//  Created by Soroush on 12/15/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private var cellSize: CGFloat { return 120.0  }
    private var cellMargin: CGFloat { return floor((self.view.bounds.width - (self.cellSize * 2)) / 3 ) }
    
    var booth: Booth!
    var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PreviewPopupViewController, let details = sender as? (UIImage, String) {
            vc.details = details
            (segue as? MessagesCenteredSegue)?.dimMode = .blur(style: .dark, alpha: 0.5, interactive: true)
        }
    }
}

extension ImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        let image = self.images[indexPath.item]
        cell.imageView.image = image
        cell.makeShadowed()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = self.images[indexPath.item]
        let details = (image, "")
        self.performSegue(withIdentifier: "toPeekVC", sender: details)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.cellMargin, left: self.cellMargin, bottom: self.cellMargin, right: self.cellMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellSize, height: self.cellSize)
    }
}

extension ImagesViewController: DeletableCollectionViewCellDelegate {
    
    func deleteButtonTappedFor(_ cell: UICollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
        let title = "حذف فایل"
        let message = "آیا از حذف این فایل مطمئن هستید؟"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: "بله", style: .destructive) { _ in
            
        }
        let cancel = UIAlertAction(title: "خیر", style: .cancel) { _ in }
        [yes, cancel].forEach { alert.addAction($0) }
        self.present(alert, animated: true)
    }
    
}
