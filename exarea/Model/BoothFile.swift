
//
//  BoothFile.swift
//  exarea
//
//  Created by Soroush on 1/11/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import Foundation

class BoothFile: JSONSerializable {
    let boothFileID: Int
    let boothID: Int
    let fileAddress: String
    let fileTitle: String
    let isActive: Bool
}

class BoothFileWrapper {
    
    enum State: Int {
        case notDownloaded = 0
        case downloading
        case downloaded
        
        var title: String {
            return ["دریافت فایل","در حال دریافت","باز کردن"][self.rawValue]
        }
    }
    
    let id: URL
    let file: BoothFile
    
    var state: State = .notDownloaded
    
    init(id: URL, file: BoothFile) {
        self.id = id
        self.file = file
    }
}
