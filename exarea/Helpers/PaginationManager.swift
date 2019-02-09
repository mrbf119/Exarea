////
////  PaginationManager.swift
////  Helper
////
////  Created by SoRush on 10/15/1396 AP.
////  Copyright © 1397 tamtom. All rights reserved.
////
//

import UIKit

protocol PaginatorProtocol {
    func newData(completion: @escaping ErrorableResult)
}

class Paginator<T>: PaginatorProtocol {
    
    typealias FetchMethod = (Int, Int, @escaping DataResult<[T]>) -> ()
    
    let pageSize: Int
    private(set) var currentPage: Int = 0
    private(set) var list = [T]()
    private let fetchHandler: FetchMethod
    let paginates: Bool
    
    func newData(completion: @escaping ErrorableResult) {
        self.fetchHandler(currentPage * pageSize, pageSize) { result in
            if let list = result.value {
                if self.paginates {
                    self.currentPage += 1
                } else {
                    self.reset()
                }
                self.list.append(contentsOf: list)
            }
            completion(result.error)
        }
    }
    
    func reset() {
        self.currentPage = 0
        self.list.removeAll()
    }
    
    init(paginates: Bool = true, pageSize: Int = 20, fetchHandler: @escaping FetchMethod) {
        self.pageSize = pageSize
        self.fetchHandler = fetchHandler
        self.paginates = paginates
    }
}
