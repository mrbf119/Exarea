//
//  Product.swift
//  exarea
//
//  Created by Soroush on 11/21/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Alamofire

struct Product: JSONSerializable, ImageTitled {
    
    var imageURL: URL? { return URL(string: self.productPhoto) }
    var textToShow: String { return self.name ?? "" }
    
    let productID: Int
    let boothID: Int
    let name: String?
    let description: String?
    let productPhoto: String
}

extension Product {
    static func search(query: String, page: Int = 0, pageSize: Int = 20, completion: @escaping DataResult<[Product]>) {
        let params: Parameters = ["FetchRow": page + pageSize, "SkipRow": page, "TargetWord": query]
        let req = CustomRequest(path: "/Search/SearchProduct", method: .post, parameters: params).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: [Product].responseDataSerializer) { response in
            completion(response.result)
        }
    }
}
