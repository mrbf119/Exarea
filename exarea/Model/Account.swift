//
//  User.swift
//  exarea
//
//  Created by Soroush on 10/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Alamofire
import KeychainAccess

class Account: JSONSerializable {
    
    static private(set) var current: Account? = {
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        guard
            let token = keychain["userToken"],
            let sessionID = keychain["sessionID"]
            else { return nil }
        return Account(token: token, sessionID: sessionID)
    }() {
        didSet {
            if let acc = current {
                acc.saveTokenAndSession()
            }
        }
    }
    
    let userID: Int
    let firstName: String?
    let lastName: String?
    let role: String?
    
    let userToken: String
    let sessionID: String
    
    private init(token: String, sessionID: String) {
        self.userToken = token
        self.sessionID = sessionID
        self.userID = -1
        self.firstName = nil
        self.lastName = nil
        self.role = nil
    }
    
    private func saveTokenAndSession() {
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        keychain["userToken"] = self.userToken
        keychain["sessionID"] = self.sessionID
    }
    
    class func clearKeychain() {
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        keychain["userToken"] = nil
        keychain["sessionID"] = nil
    }
    
    class func logout() {
        self.clearKeychain()
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
        let req = CustomRequest(path: "/Account/LoginUserWithTokenAndSession", method: .post, parameters: form.parameters!).api()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: Account.responseDataSerializer) { response in
            if let user = response.result.value {
                Account.current = user
            }
            completion(response.result.error)
        }
    }
}

