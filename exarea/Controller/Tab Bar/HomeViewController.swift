//
//  HomeViewController.swift
//  exarea
//
//  Created by Soroush on 10/28/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import ImageSlideshow
import AlignedCollectionViewFlowLayout

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var selectedFair: Fair? {
        didSet { self.setBoothPaginator(); self.getData() }
    }
    
    private var hasRequestedFairData = false
    private var endOfList = false
    
    private var isInFairMode: Bool { return self.selectedFair != nil }
    private var isExtended = false
    
    
    var fairBannerArray = [Imaged]()
    
    private var boothPaginator: Paginator<Booth>?
    
    private var fairPaginator: Paginator<Fair>!
    
    private var bannerPaginator = Paginator<Fair.Banner>(pageSize: 1) { page, pageSize, completion in
        Fair.getBanners(page: page, completion: completion)
    }
    
    private var currentList: [Imaged] {
        return self.boothPaginator?.list ?? self.fairBannerArray
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
        let alignedFlowLayout = self.collectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .right
        alignedFlowLayout?.minimumInteritemSpacing = self.cellMargin
        alignedFlowLayout?.minimumLineSpacing = self.cellMargin
        alignedFlowLayout?.sectionInset = UIEdgeInsets(top: self.cellMargin, left: self.cellMargin, bottom: self.cellMargin, right: self.cellMargin)
        
        self.fairPaginator = Paginator<Fair>(pageSize: 12) { page, pageSize, completion in
            Fair.getAll(page: page, pageSize: pageSize) { result in
                switch result {
                case .success(let fairs):
                    if fairs.isEmpty {
                        self.endOfList = true
                        completion(result)
                        return
                    }
                    self.fairBannerArray.append(contentsOf: fairs)
                    self.bannerPaginator.newData { err in
                        if let error = err {
                            completion(.failure(error))
                        } else {
                            if let banner = self.bannerPaginator.list.last {
                                self.fairBannerArray.append(banner)
                            }
                            completion(result)
                        }
                    }
                case .failure:
                    completion(result)
                }
            }
        }
        self.getData()
        self.getSliderItems()
    }
    
    private func getData() {
        let currentPagintor: PaginatorProtocol = self.boothPaginator ?? self.fairPaginator
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
        return self.isInFairMode ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.isInFairMode && section == 0 ? 1 : self.currentList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isInFairMode, indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "descriptionCell", for: indexPath) as! ExpandableLabelCollectionViewCell
            cell.label.text = self.selectedFair?.about
            cell.label.numberOfLines = self.isExtended ? 0 : 3
            cell.delegate = self
            cell.makeShadowed()
            return cell
        } else {
            let item = self.currentList[indexPath.row]
            if let banner = item as? Fair.Banner {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImagedCollectionViewCell
                cell.update(with: banner)
                cell.makeShadowed()
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageTitledCell", for: indexPath) as! ImageTitledCollectionCell
                cell.update(with: item as! ImageTitled)
                cell.makeShadowed()
                
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize(width: self.view.frame.width, height: 200) : CGSize.zero
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
        if self.isInFairMode {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.isInFairMode && indexPath.section == 0 {
            let label = UILabel()
            label.numberOfLines = self.isExtended ? 0 : 3
            label.font = UIFont.iranSansEnglish.withSize(17)
            label.text = self.selectedFair!.about
            let size = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: UIView.layoutFittingCompressedSize.height))
            return CGSize(width: size.width + 20, height: size.height + 60)
        } else {
            if self.currentList[indexPath.row] is Fair.Banner {
                return CGSize(width: UIScreen.main.bounds.width - (self.cellMargin * 2), height: 80)
            } else {
                return CGSize(width: self.cellSize, height: 220)
            }
        }
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
        if !self.isInFairMode && self.currentList.count - 1 == indexPath.row && !self.hasRequestedFairData, !self.endOfList {
            self.hasRequestedFairData = true
            self.getData()
        }
    }
    
}
