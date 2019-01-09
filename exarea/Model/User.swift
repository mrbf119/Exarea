//
//  User.swift
//  exarea
//
//  Created by Soroush on 10/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Alamofire

struct LoginForm: JSONSerializable {
    let phoneNumber, password: String
    let platform = "mobile app"
    let oS = "iOS"
    let model = UIDevice.modelName
    let version = "9.0"
    let iP = "????"
}


class User: JSONSerializable {
    
    static private(set) var shared: User?
    
    let userID: Int
    let firstName: String?
    let lirstName: String?
    let role: String?
    
    let userToken: String
    let sessionID: String
    
    
    class func logout() {
        
    }
}

extension User {
    
    class func login(with form: LoginForm, completion: @escaping ErrorableResult) {
        let req = CustomRequest(path: "/Account/Login", method: .post, parameters: form.parameters!).api()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: User.responseDataSerializer) { response in
            if let user = response.result.value {
                User.shared = user
            }
            completion(response.result.error)
        }
    }
}

