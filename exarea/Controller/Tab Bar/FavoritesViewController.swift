//
//  FavoritesViewController.swift
//  exarea
//
//  Created by Soroush on 7/4/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    private var cellSize: CGFloat { return 140  }
    private var cellMargin: CGFloat { return ((self.view.bounds.width - (self.cellSize * 2)) / 3 ).rounded() }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private var favoritesPaginator = Paginator<Booth>(paginates: false) { page, pageSize, completion in
        Booth.getFavorites(page: page, pageSize: pageSize, completion: completion)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getData()
    }
    
    private func getData() {
        self.favoritesPaginator.newData { error in
            if error == nil {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BoothDetailsViewController, let booth = sender as? Booth {
            vc.booth = booth
        }
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.favoritesPaginator.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.favoritesPaginator.list[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageTitledCell", for: indexPath) as! ImageTitledCollectionCell
        cell.update(with: item)
        cell.makeShadowed()
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let booth = self.favoritesPaginator.list[indexPath.row]
        self.performSegue(withIdentifier: "toBoothDetailVC", sender: booth)
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.cellMargin, left: self.cellMargin, bottom: self.cellMargin + self.tabBarController!.tabBar.frame.height, right: self.cellMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellSize, height: 220)
    }
}
