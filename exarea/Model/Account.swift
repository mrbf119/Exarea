//
//  User.swift
//  exarea
//
//  Created by Soroush on 10/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Alamofire




class Account: JSONSerializable {
    
    static private(set) var current: Account?
    
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
                Account.current = user
            }
            completion(response.result.error)
        }
    }
    
    class func register(with form: RegisterForm, completion: @escaping DataResult<String>) {
        let req = CustomRequest(path: "/Account/Register", method: .post, parameters: form.parameters!).api()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: String.responseDataSerializer) { response in
            completion(response.result)
        }
    }
    
    class func activate(with form: ActivateForm, completion: @escaping ErrorableResult) {
        let req = CustomRequest(path: "/Account/AccountActivation", method: .post, parameters: form.parameters!).api()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: Account.responseDataSerializer) { response in
            if let user = response.result.value {
                Account.current = user
            }
            completion(response.result.error)
        }
    }
    
    func loginWithToken(completion: @escaping ErrorableResult) {
        let form = AuthLoginForm(userToken: self.userToken, sessionID: self.sessionID)
        let req = CustomRequest(path: "/Account/AccountActivation", method: .post, parameters: form.parameters!).api()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: Account.responseDataSerializer) { response in
            if let user = response.result.value {
                Account.current = user
            }
            completion(response.result.error)
        }
    }
}

