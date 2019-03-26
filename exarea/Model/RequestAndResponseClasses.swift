//
//  RequestAndResponseClasses.swift
//  exarea
//
//  Created by Soroush on 11/9/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Foundation

struct AuthLoginForm: JSONSerializable {
    let userToken, sessionID: String
}

struct LoginForm: JSONSerializable {
    let userName, password: String
    let platform = "mobile app"
    let oS = "iOS"
    let model = UIDevice.modelName
    let version = "9.0"
    let iP = "????"
}

struct ActivateForm: JSONSerializable {
    let userID, accountActivationCode: String
    let platform = "mobile app"
    let oS = "iOS"
    let model = UIDevice.modelName
    let version = "9.0"
    let iP = "????"
}

struct RegisterForm: JSONSerializable {
    
    
    
    let userName, password: String
    let roleID: String
    
    init(userName: String, password: String, roleID: Account.Role) {
        self.userName = userName
        self.password = password
        self.roleID = roleID.id
    }
}
