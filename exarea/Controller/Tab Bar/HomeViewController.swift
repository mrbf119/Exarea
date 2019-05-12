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
    
    private var hasRequestedFairData = false
    private var endOfList = false
    
    private var hasSelectedFair: Bool { return self.selectedFair != nil }
    private var isExtended = false
    
    
    private var paginatorBooth: Paginator<Booth>?
    private var paginatorFair: Paginator<Fair>!
    private var paginatorBanner = Paginator<Fair.Banner>(pageSize: 1) { page, pageSize, completion in
        Fair.getBanners(page: page, completion: completion)
    }
    
    private var currentList: [ImageTitled] {
        return self.paginatorBooth?.list ?? self.paginatorFair.list
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private var fairPageSize = 12
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
        self.configCollectionView()
        self.configPaginators()
        self.getData()
        self.getSliderItems()
    }
    
    private func configCollectionView() {
        self.collectionView.register(UINib(nibName: "\(SlideShowHeaderView.self)", bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SlideShowHeaderView")
        self.collectionView.register(UINib(nibName: "BannerHeader", bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "BannerHeader")
    }
    
    private func configPaginators() {
        self.paginatorFair = Paginator<Fair>(pageSize: self.fairPageSize) { page, pageSize, completion in
            Fair.getAll(page: page, pageSize: pageSize) { result in
                switch result {
                case .success(let fairs):
                    if fairs.isEmpty {
                        self.endOfList = true
                        completion(result)
                        return
                    }
                    self.paginatorBanner.newData { err in
                        if let error = err {
                            completion(.failure(error))
                        } else {
                            completion(result)
                        }
                    }
                case .failure:
                    completion(result)
                }
            }
        }
    }
    
    private func getData() {
        let currentPagintor: PaginatorProtocol = self.paginatorBooth ?? self.paginatorFair
        currentPagintor.newData { error in
            if error == nil {
                self.hasRequestedFairData = false
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
            self.paginatorBooth = Paginator<Booth> { page, pageSize, completion in
                Booth.getBooths(of: selectedFair, page: page, pageSize: pageSize, completion: completion)
            }
        } else {
            self.paginatorBooth = nil
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
        return self.hasSelectedFair ? 2 : Int(ceil(Double(self.currentList.count) / Double(self.fairPageSize))) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.hasSelectedFair {
            if section == 0 {
                return 1
            } else {
                return self.currentList.count
            }
        } else {
            if section == 0 {
                return 0
            } else {
                let count = self.currentList.count / self.fairPageSize
                return section <= count && count != 0 ? self.fairPageSize : self.currentList.count % self.fairPageSize
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.hasSelectedFair, indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "descriptionCell", for: indexPath) as! ExpandableLabelCollectionViewCell
            cell.label.text = self.selectedFair?.about
            cell.label.numberOfLines = self.isExtended ? 0 : 3
            cell.delegate = self
            cell.makeShadowed()
            return cell
        } else {
            let item = self.currentList[((indexPath.section - 1) * self.fairPageSize) + indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageTitledCell", for: indexPath) as! ImageTitledCollectionCell
            cell.update(with: item)
            cell.makeShadowed()
            return cell
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.hasSelectedFair {
            guard indexPath.section != 0 else { return }
        }
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
        return UIEdgeInsets(top: 0, left: self.cellMargin, bottom: self.cellMargin, right: self.cellMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.hasSelectedFair && indexPath.section == 0 {
            let label = UILabel()
            label.numberOfLines = self.isExtended ? 0 : 3
            label.font = UIFont.iranSansEnglish.withSize(17)
            label.text = self.selectedFair!.about
            let size = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: UIView.layoutFittingCompressedSize.height))
            return CGSize(width: size.width + 20, height: size.height + 60)
        } else {
            return CGSize(width: self.cellSize, height: 220)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize(width: self.view.frame.width, height: 200) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return section == 0 ? .zero : CGSize(width: self.cellSize, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if indexPath.section == 0 {
            
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "\(SlideShowHeaderView.self)",
                for: indexPath) as! SlideShowHeaderView
            
            let items = self.sliderItems.map { KingfisherSource(url: URL(string: $0.imageAddress)!) }
            headerView.slideShow.setImageInputs(items)
            headerView.slideShow.slideshowInterval = 4
            headerView.slideShow.circular = true
            headerView.slideShow.contentScaleMode = .scaleToFill
            headerView.slideShow.setCurrentPage(self.sliderCurrentPage, animated: false)
            return headerView
        } else {
            
            if !self.hasSelectedFair && indexPath.section != 0 {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                                 withReuseIdentifier: "BannerHeader",
                                                                                 for: indexPath) as! ImageReusableView
                
                let item = self.paginatorBanner.list[indexPath.section - 1]
                headerView.update(data: item)
                headerView.makeShadowed()
                return headerView
            } else {
                return UICollectionReusableView(frame: .zero)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
//        if
//            let headerView = collectionView.dequeueReusableSupplementaryView(
//                ofKind: elementKind,
//                withReuseIdentifier: "\(SlideShowHeaderView.self)",
//                for: indexPath) as? SlideShowHeaderView
//        {
//            self.sliderCurrentPage = headerView.slideShow.currentPage
//        }
    }
}

extension HomeViewController: Reloadable {
    func reloadScreen(animated: Bool = false) {
        self.selectedFair = nil
    }
}


extension HomeViewController: ExpandableLabelCollectionViewCellDelegate {
    func expandableCell(_ cell: ExpandableLabelCollectionViewCell, didChangeState isExtened: Bool) {
        self.isExtended = isExtened
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension HomeViewController {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !self.hasSelectedFair && self.currentList.count - 1 == indexPath.row && !self.hasRequestedFairData, !self.endOfList {
            self.hasRequestedFairData = true
            self.getData()
        }
    }
    
}
