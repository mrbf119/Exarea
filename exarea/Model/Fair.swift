//
//  Fair.swift
//  exarea
//
//  Created by Soroush on 11/1/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Foundation

struct MainSliderItem: JSONSerializable {
    let sliderID: Int
    let title: String?
    let imageAddress: String
    let link: String?
    let location: String?
}

struct Fair: JSONSerializable, ImageTitled {
    let fairID: Int
    let name: String
    let slogan: String?
    let about: String?
    let view: Int
    let colorHex: String
    let startDateShamsi: String
    let startDateShamsiFull: String
    let endDate: String
    let endDateShamsi: String
    let endDateShamsiFull: String
    let sEOFriendlyFairName: String
    let isActive: Bool
    let fairPhotoAddress: String
    
    var imageURL: URL? { return URL(string: self.fairPhotoAddress) }
    var textToShow: String { return self.sEOFriendlyFairName.replacingOccurrences(of: "-", with: " ") }
    
}

extension Fair {
    
    static func getAll(page: Int = 0, pageSize: Int = 20, completion: @escaping DataResult<[Fair]>) {
        let pageParams = ["FetchRow": page + pageSize, "SkipRow": page]
        let req = CustomRequest(path: "/Fair/ActiveFairs", method: .post, parameters: pageParams).api().authorize()
        NetManager
            .shared
            .requestWithValidation(req)
            .response(responseSerializer: [Fair].responseDataSerializer) { response in
            completion(response.result)
        }
    }
    
    static func mainSlider(completion: @escaping DataResult<[MainSliderItem]>) {
        let req = CustomRequest(path: "/Fair/MainSlider", method: .post).api()
        NetManager
            .shared
            .requestWithValidation(req)
            .response(responseSerializer: [MainSliderItem].responseDataSerializer) { response in
                completion(response.result)
        }
    }
}
