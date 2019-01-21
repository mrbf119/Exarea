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
    
    private var data = [Fair]()
    
    private var cellSize: CGFloat { return 140  }
    private var cellMargin: CGFloat { return ((self.view.bounds.width - (self.cellSize * 2)) / 3 ).rounded() }
    private var sliderCurrentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configSlideShow()
        self.getData()
    }
    
    private func configSlideShow() {
        
    }
    
    private func getData() {
        Fair.getAll { result in
            switch result {
            case .success(let fairs):
                self.data = fairs
                self.collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fairCell", for: indexPath) as! FairCollectionCell
        let fair = self.data[indexPath.row]
        cell.update(with: fair)
        cell.makeShadowed()
        return cell
    }
    
    
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
            
            headerView.slideShow.setImageInputs([
                KingfisherSource(url: Bundle.main.url(forResource: "image1", withExtension: ".jpg")!),
                KingfisherSource(url: Bundle.main.url(forResource: "image2", withExtension: ".jpg")!),
                KingfisherSource(url: Bundle.main.url(forResource: "image3", withExtension: ".jpeg")!),
                KingfisherSource(url: Bundle.main.url(forResource: "image4", withExtension: ".jpeg")!)
                ])
            headerView.slideShow.slideshowInterval = 5
            headerView.slideShow.circular = true
            headerView.slideShow.contentScaleMode = .scaleToFill
            headerView.slideShow.setCurrentPage(self.sliderCurrentPage, animated: false)
            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }
    
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
}
