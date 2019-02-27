//
//  ProductsViewController.swift
//  exarea
//
//  Created by Soroush on 12/8/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class ProductsViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var booth: Booth!
    private var products = [Product]()

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private var cellSize: CGFloat { return 140  }
    private var cellMargin: CGFloat { return ((self.view.bounds.width - (self.cellSize * 2)) / 3 ) }
    private var sliderCurrentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
    }
    
    private func getData() {
        self.booth.getProducts { result in
            switch result {
            case .success(let products):
                self.products = products
                self.collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProductPeekViewController, let details = sender as? (UIImage, String) {
            vc.details = details
        }
    }
}

extension ProductsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.products[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageTitledCell", for: indexPath) as! ImageTitledCollectionCell
        cell.update(with: item)
        cell.makeShadowed()
        return cell
    }

}

extension ProductsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageTitledCollectionCell, let image = cell.imageView.image else { return }
        let details = (image, cell.titleLabel.text ?? "")
        self.performSegue(withIdentifier: "toPeekVC", sender: details)
    }
}

extension ProductsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.cellMargin, left: self.cellMargin, bottom: self.cellMargin, right: self.cellMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellSize, height: 200)
    }
}
