//
//  HomeViewController.swift
//  exarea
//
//  Created by Soroush on 10/28/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import ImageSlideshow

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var selectedFair: Fair? {
        didSet { self.setBoothPaginator(); self.getData() }
    }
    
    private var boothPaginator: Paginator<Booth>?
    private let fairPaginator = Paginator<Fair> { page, pageSize, completion in
        Fair.getAll(page: page, pageSize: pageSize, completion: completion)
    }
    
    private var currentList: [ImageTitled] {
        return self.boothPaginator?.list ?? self.fairPaginator.list
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private var cellSize: CGFloat { return 140  }
    private var cellMargin: CGFloat { return ((self.view.bounds.width - (self.cellSize * 2)) / 3 ) }
    private var sliderCurrentPage = 0
    private var sliderItems = [MainSliderItem]() {
        didSet {
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        self.getSliderItems()
    }
    
    private func getData() {
        let currentPagintor: PaginatorProtocol = self.boothPaginator ?? self.fairPaginator
        currentPagintor.newData { error in
            if error == nil {
                self.collectionView.reloadData()
            }
            print(error)
        }
    }
    
    private func getSliderItems() {
        Fair.mainSlider { result in
            switch result {
            case .success(let items):
                self.sliderItems = items
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setBoothPaginator() {
        if let selectedFair = self.selectedFair {
            self.boothPaginator = Paginator<Booth> { page, pageSize, completion in
                Booth.getBooths(of: selectedFair, page: page, pageSize: pageSize, completion: completion)
            }
        } else {
            self.boothPaginator = nil
        }
        self.collectionView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BoothDetailsViewController, let booth = sender as? Booth {
            vc.booth = booth
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.currentList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageTitledCell", for: indexPath) as! ImageTitledCollectionCell
        cell.update(with: item)
        cell.makeShadowed()
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "\(SlideShowHeaderView.self)",
                    for: indexPath) as? SlideShowHeaderView
                else {
                    fatalError("Invalid view type")
            }
            
            let items = self.sliderItems.map { KingfisherSource(url: URL(string: $0.imageAddress)!) }
            headerView.slideShow.setImageInputs(items)
            headerView.slideShow.slideshowInterval = 4
            headerView.slideShow.circular = true
            headerView.slideShow.contentScaleMode = .scaleToFill
            headerView.slideShow.setCurrentPage(self.sliderCurrentPage, animated: false)
            return headerView
        default:
            return UICollectionReusableView(frame: CGRect.zero)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: elementKind,
                withReuseIdentifier: "\(SlideShowHeaderView.self)",
                for: indexPath) as? SlideShowHeaderView
            else {
                fatalError("Invalid view type")
        }
        self.sliderCurrentPage = headerView.slideShow.currentPage
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.currentList[indexPath.row]
        if let fair = item as? Fair {
            self.selectedFair = fair
        } else if let booth = item as? Booth {
            self.performSegue(withIdentifier: "toBoothDetailVC", sender: booth)
        }
    }
}
    
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
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
        return CGSize(width: self.cellSize, height: 220)
    }
}


extension HomeViewController: Reloadable {
    func reloadScreen(animated: Bool = false) {
        self.selectedFair = nil
    }
}
