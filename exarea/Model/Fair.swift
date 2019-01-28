//
//  Fair.swift
//  exarea
//
//  Created by Soroush on 11/1/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Foundation

struct Fair: JSONSerializable {
    let fairID: Int
    let name: String
    let slogan: String?
    let about: String
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
}

extension Fair {
    
    static func getAll(completion: @escaping DataResult<[Fair]>) {
        let req = CustomRequest(path: "/Fair/ActiveFairs", method: .post, parameters: ["FetchRow": "20", "SkipRow": "0"]).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: [Fair].responseDataSerializer) { response in
            completion(response.result)
        }
    }
}
