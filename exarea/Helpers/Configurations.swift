//
//  Configurations.swift
//  exarea
//
//  Created by Soroush on 10/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Foundation


struct Configurations {
    static var `protocol`: String { return "https://" }
    static var baseURL: String { return Configurations.protocol + "www.exarea.ir" }
    static var apiURL: String { return Configurations.baseURL + "/api"}
}
