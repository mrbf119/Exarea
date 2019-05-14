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
    
    struct Banner: JSONSerializable, ImageTitled {
        let bannerID: Int
        let position: Int
        let imageAddress: String
        let link: String
        let rank: Int
        
        var imageURL: URL? { return URL(string: self.imageAddress) }
        var textToShow: String { return "" }
    }
    
    
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
    var textToShow: String { return self.name }
    
}

extension Fair {
    
    static func getAll(page: Int = 0, pageSize: Int = 20, completion: @escaping DataResult<[Fair]>) {
        let pageParams = ["FetchRow": pageSize, "SkipRow": page]
        let req = CustomRequest(path: "/Fair/ActiveFairs", method: .post, parameters: pageParams).api().authorize()
        NetworkManager.session
            .requestWithValidation(req)
            .response(responseSerializer: [Fair].responseDataSerializer) { response in
            completion(response.result)
        }
    }
    
    static func getBanners(page: Int = 0, completion: @escaping DataResult<[Fair.Banner]>) {
        let pageParams = ["Position": 2, "FetchRow": 1, "SkipRow": page]
        let req = CustomRequest(path: "/Fair/GetBanner", method: .post, parameters: pageParams).api().authorize()
        NetworkManager.session
            .requestWithValidation(req)
            .response(responseSerializer: [Fair.Banner].responseDataSerializer) { response in
                completion(response.result)
        }
    }
    
    static func mainSlider(completion: @escaping DataResult<[MainSliderItem]>) {
        let req = CustomRequest(path: "/Fair/MainSlider", method: .post).api()
        NetworkManager.session
            .requestWithValidation(req)
            .response(responseSerializer: [MainSliderItem].responseDataSerializer) { response in
                completion(response.result)
        }
    }
}
