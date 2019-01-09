////
////  PaginationManager.swift
////  Helper
////
////  Created by SoRush on 10/15/1396 AP.
////  Copyright © 1397 Gandom. All rights reserved.
////
//
//import UIKit
//
//public enum RequestResult<T> {
//    case data(T)
//    case error(Error)
//}
//
//public protocol SelfUpdateView where Self: UIView {
//    associatedtype dataType
//    func update(with data: dataType)
//    static var defaultHeight: CGFloat { get }
//}
//
//public protocol Listable {
//    associatedtype associatedType = Self
//    static func getAll(parameters: [String: Any], completion: @escaping (RequestResult<[associatedType]>) -> ())
//}
//
//public class ListManager<T: Listable> {
//    public var dataCount: Int { return self.dataList.count }
//    public var parameters: [String: Any] { return [:] }
//    public var dataList: [T.associatedType] = []
//    
//    internal func getData(additionalParams: [String: Any] = [:], completion: @escaping (Error?) -> ()) {
//        let params = self.parameters.merging(additionalParams, uniquingKeysWith: { old, new in old })
//        T.getAll(parameters: params) { result in
//            switch result {
//            case .data(let data):
//                self.dataList.append(contentsOf: data)
//                completion(nil)
//            case .error(let error):
//                print(error.localizedDescription)
//                completion(error)
//            }
//        }
//    }
//    
//    func reset() {
//        self.dataList.removeAll()
//    }
//    
//    public func refreshData(completion: @escaping (Error?) -> ()) {
//        self.reset()
//        self.getData(completion: completion)
//    }
//}
//
//public class Paginator<listable: Listable>: ListManager<listable> {
//    
//    var perPage: Int { return 10 }
//
//    private(set) var currentPage: Int = 0
//    
//    func getData(completion: @escaping (Error?) -> ()) {
//        // TODO: check if super class is called or not :)
//        let params = ["per_page": self.perPage, "page": self.currentPage + 1]
//        super.getData(additionalParams: params) { (err) in
//            if err == nil {
//                self.currentPage += 1
//            }
//            completion(err)
//        }
//    }
//    
//    override func reset() {
//        super.reset()
//        self.currentPage = 0
//    }
//}
//
//open class PaginationCollectionViewController<CellContentViewClass: SelfUpdateView, PaginationDataType: Listable>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    public var pullToRefreshDraggingText = ""
//    public var pullToRefreshReleaseText = ""
//    public var pullToRefreshWaitingText = ""
//    
//    private var isInfiniteScolling = false
//    public var collectionView: UICollectionView? { return nil }
//    public var labelDataStatus: UILabel? { return nil }
//    public var acitivityIndicatorLoading: UIActivityIndicatorView? { return nil }
//    
//    let manager = Paginator<PaginationDataType>()
//    
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        self.configPullToRefresh()
//        self.configInfiniteScroll()
//    }
//    
//    private func configPullToRefresh() {
//        self.collectionView.rect
//        self.tableView?.addPullToRefresh {
//            self.tableView?.pullToRefreshView.startAnimating()
//            self.refreshData()
//        }
//        // TODO: what the f is this ? said hamed
//        self.tableView?.pullToRefreshView.setTitle(pullToRefreshDraggingText, forState: 0)
//        self.tableView?.pullToRefreshView.setTitle(pullToRefreshReleaseText, forState: 1)
//        self.tableView?.pullToRefreshView.setTitle(pullToRefreshWaitingText, forState: 2)
//    }
//    
//    private func configInfiniteScroll() {
//        self.tableView?.addInfiniteScrolling {[weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.tableView?.infiniteScrollingView.startAnimating()
//            strongSelf.getData()
//        }
//    }
//    
//    func startLoading() {
//        DispatchQueue.main.async {
//            self.acitivityIndicatorLoading?.startAnimating()
//            
//        }
//    }
//    
//    func stopLoading() {
//        DispatchQueue.main.async {
//            self.acitivityIndicatorLoading?.stopAnimating()
//            self.tableView?.pullToRefreshView.stopAnimating()
//            self.tableView?.infiniteScrollingView.stopAnimating()
//        }
//    }
//    
//    func getData() {
//        if self.manager.dataList.isEmpty {
//            self.startLoading()
//        }
//        self.manager.getData {[weak self] error in
//            guard let strongSelf = self else { return }
//            strongSelf.stopLoading()
//            strongSelf.labelDataStatus?.isHidden = !strongSelf.manager.dataList.isEmpty
//            guard let error = error else {
//                strongSelf.collectionView?.reloadData()
//                return
//            }
//            print(error.localizedDescription)
//        }
//    }
//    
//    func refreshData() {
//        self.labelDataStatus?.isHidden = true
//        self.manager.refreshData {[weak self] error in
//            guard let strongSelf = self else { return }
//            strongSelf.stopLoading()
//            strongSelf.labelDataStatus?.isHidden = !strongSelf.manager.dataList.isEmpty
//            guard let error = error else {
//                strongSelf.collectionView?.reloadData()
//                return
//            }
//            print(error.localizedDescription)
//        }
//        self.collectionView?.reloadData()
//    }
//    
//    func startInfiniteScroll() {
//        guard !self.isInfiniteScolling else { return }
//        self.isInfiniteScolling = true
//        self.collectionView?.reloadData()
//    }
//    
//    //MARK: - CollectionView Delegation
//    
//    public func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.manager.dataList.count + (self.isInfiniteScolling ? 1 : 0)
//    }
//    
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        if self.isInfiniteScolling {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//            guard let customView = cell.contentView.subviews.first as? CellContentViewClass else { return UICollectionViewCell() }
//            guard let data = self.manager.dataList[indexPath.row] as? CellContentViewClass.dataType else { return UICollectionViewCell() }
//            customView.update(with: data)
//            return cell
//        } else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//            guard let customView = cell.contentView.subviews.first as? CellContentViewClass else { return UICollectionViewCell() }
//            guard let data = self.manager.dataList[indexPath.row] as? CellContentViewClass.dataType else { return UICollectionViewCell() }
//            customView.update(with: data)
//            return cell
//        }
//        
//    }
//    
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: CellContentViewClass.defaultHeight,
//                      height: CellContentViewClass.defaultHeight)
//    }
//    
//    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row == self.manager.dataList.count - 1 {
//            self.startInfiniteScroll()
//        }
//    }
//}
