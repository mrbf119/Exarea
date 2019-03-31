//
//  Note.swift
//  exarea
//
//  Created by Soroush on 1/10/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import Foundation

struct Note: JSONSerializable {
    var title: String
    var content: String?
    
    init(title: String, content: String? = nil) {
        self.title = title
        self.content = content
    }
}
