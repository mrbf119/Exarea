//
//  SearchViewController.swift
//  exarea
//
//  Created by Soroush on 11/21/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit

protocol SearchVCDelegate: class {
    func searchViewController(_ searchVC: SearchViewController, didSelectBooth booth: Booth)
}

class CustomSearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setShowsCancelButton(false, animated: false)
        let searchTextView = self.value(forKey:"searchField") as! UITextField
        searchTextView.font = UIFont.iranSans
        searchTextView.textAlignment = .right
        searchTextView.leftViewMode = .never
        searchTextView.clipsToBounds = true
        searchTextView.clearButtonMode = .never
    }
}

class SearchViewController: UIViewController {
    
    @IBOutlet private var collectionBooths: UICollectionView!
    @IBOutlet private var collectionProducts: UICollectionView!
    @IBOutlet private var searchBar: CustomSearchBar!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }
    private var cellSize: CGFloat { return 140  }
    private var cellMargin: CGFloat { return 10 }
    
    weak var delegate: SearchVCDelegate?
    
    private var query: String? {
        didSet {
            if query == nil {
                self.boothPaginator.reset()
                self.productPaginator.reset()
                self.collectionBooths.reloadData()
                self.collectionProducts.reloadData()
            } else {
                self.boothPaginator.newData { error in
                    self.collectionBooths.reloadSections([0])
                }
                self.productPaginator.newData { error in
                    self.collectionProducts.reloadSections([0])
                }
            }
        }
    }
    
    private var boothPaginator: Paginator<Booth>!
    private var productPaginator: Paginator<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        self.boothPaginator = Paginator<Booth>(paginates: false, pageSize: 20) { page, pageSize, completion in
            Booth.search(query: self.query!, page: page, pageSize: pageSize, completion: completion)
        }
        self.productPaginator = Paginator<Product>(paginates: false, pageSize: 20) { page, pageSize, completion in
            Product.search(query: self.query!, page: page, pageSize: pageSize, completion: completion)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction private func searchButtonClicked() {
        self.searchBarSearchButtonClicked(self.searchBar)
    }
    
    @IBAction private func backButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.query = searchBar.text!
    }
}


extension SearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView === self.collectionBooths ? self.boothPaginator.list.count : self.productPaginator.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageTitledCell", for: indexPath) as! ImageTitledCollectionCell
        let item: ImageTitled = collectionView === self.collectionBooths ? self.boothPaginator.list[indexPath.row] : self.productPaginator.list[indexPath.row]
        cell.update(with: item)
        cell.makeShadowed()
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView === self.collectionBooths else { return }
        let item = self.boothPaginator.list[indexPath.row]
        self.delegate?.searchViewController(self, didSelectBooth: item)
        self.backButtonClicked()
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellSize, height: 190)
    }
}
