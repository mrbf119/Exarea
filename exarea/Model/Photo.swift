//
//  Photo.swift
//  exarea
//
//  Created by Soroush on 1/10/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import Foundation

struct Photo: JSONSerializable {
    let boothPhotoID: Int
    let boothPhotoTitle: String
    private let boothPhotoAddress: String
    var address: URL? {
        return URL(string: self.boothPhotoAddress)
    }
}
