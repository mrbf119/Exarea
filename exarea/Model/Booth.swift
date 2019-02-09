//
//  Booth.swift
//  exarea
//
//  Created by Soroush on 11/13/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import Alamofire

class Booth: JSONSerializable, ImageTitled {
    
    let boothID: Int
    let userID: Int
    let fairID: Int
    let hallID: Int
    let title: String?
    let logo: String?
    let slogan: String?
    let about: String?
    let qRCodePhotoAddress: String?
    let latitude: String?
    let longitude: String?
    let rialCurrency: Bool?
    let view: Int?
    let sEOFriendlyBoothName: String?
    let isActive: Bool
    let modifiedDate: String?
    let boothPhotoAddress: String
    
    var imageURL: URL? { return URL(string: self.boothPhotoAddress) }
    var description: String { return self.sEOFriendlyBoothName?.replacingOccurrences(of: "-", with: " ") ?? "" }
    
}

extension Booth {
    static func getBooths(of fair: Fair, page: Int = 0, pageSize: Int = 20, completion: @escaping DataResult<[Booth]>) {
        let pageParams = ["FetchRow": page + pageSize, "SkipRow": page]
        let params = pageParams.merging(["FairID": fair.fairID]) { old, new in new }
        let req = CustomRequest(path: "/Booth/List", method: .post, parameters: params).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: [Booth].responseDataSerializer) { response in
            completion(response.result)
        }
    }
}
