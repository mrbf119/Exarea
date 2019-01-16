//
//  User.swift
//  exarea
//
//  Created by Soroush on 10/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Alamofire

struct LoginForm: JSONSerializable {
    let userName, password: String
    let platform = "mobile app"
    let oS = "iOS"
    let model = UIDevice.modelName
    let version = "9.0"
    let iP = "????"
}

struct RegisterForm: JSONSerializable {
    let userName, password, roleID: String
}

class Account: JSONSerializable {
    
    static private(set) var shared: Account?
    
    let userID: Int
    let firstName: String?
    let lastName: String?
    let role: String?
    
    let userToken: String
    let sessionID: String
    
    
    class func logout() {
        
    }
}

extension Account {
    
    class func login(with form: LoginForm, completion: @escaping ErrorableResult) {
        let req = CustomRequest(path: "/Account/Login", method: .post, parameters: form.parameters!).api()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: Account.responseDataSerializer) { response in
            if let user = response.result.value {
                Account.shared = user
            }
            completion(response.result.error)
        }
    }
    
    class func register(with form: RegisterForm, completion: @escaping ErrorableResult) {
        let req = CustomRequest(path: "/Account/Register", method: .post, parameters: form.parameters!).api()
        NetManager.shared.requestWithValidation(req).responseData { response in
            completion(response.result.error)
        }
    }
}

