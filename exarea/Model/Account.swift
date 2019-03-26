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
    
    enum Role: String {
        case user = "User"
        case boothOwner = "BoothOwner"
        
        init?(_ index: Int) {
            self = index == 0 ? .user : .boothOwner
        }
        
        var id: String { return self == .user ? "3" : "4" }
        var title: String { return self == .user ? "کاربر عادی" : "صاحب غرفه" }
    }
    
    static private(set) var current: Account? = {
        guard let data = Account.getTokenAndSession() else { return nil }
        return Account(token: data.token, sessionID: data.session)
    }() {
        didSet {
            if let acc = current {
                acc.saveTokenAndSession()
            }
        }
    }
    
    let userID: Int
    private let userToken: String
    private var sessionID: String?
    
    let firstName: String?
    let lastName: String?
    
    let nationalID: String?
    let gender: String?
    let birthShamsiDate: String?
    let mobileNumber: String?
    let eMailAddress: String?
    private var role: String?
    
    var fullName: String {
        return (self.firstName ?? "") + " " + (self.lastName ?? "")
    }
    
    var userRole: Role {
        return Role(rawValue: self.role ?? "User")!
    }
    
    private init(token: String, sessionID: String) {
        self.userToken = token
        self.sessionID = sessionID
        self.userID = -1
        self.firstName = nil
        self.lastName = nil
        self.nationalID = nil
        self.gender = nil
        self.birthShamsiDate = nil
        self.mobileNumber = nil
        self.eMailAddress = nil
        self.role = nil
    }
    
    static func getTokenAndSession() -> (token: String, session: String)? {
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        guard
            let token = keychain["userToken"],
            let sessionID = keychain["sessionID"]
            else { return nil }
        return (token, sessionID)
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
        let form = AuthLoginForm(userToken: self.userToken, sessionID: self.sessionID!
        )
        let req = CustomRequest(path: "/Account/LoginUserWithTokenAndSession", method: .post, parameters: form.parameters!).api()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: Account.responseDataSerializer) { response in
            if let user = response.result.value {
                Account.current = user
            }
            completion(response.result.error)
        }
    }
    
    func update(with firsName: String, lastName: String, email: String? = nil, completion: @escaping ErrorableResult) {
        var parameters = ["FirstName": firsName, "LastName": lastName]
        if let email = email, email.checking([.notEmpty]).isSuccess {
            parameters["EMail"] = email
        }
        let req = CustomRequest(path: "/Account/UpdateUserInfo", method: .post, parameters: parameters).api().authorize()
        NetManager.shared.requestWithValidation(req).responseData { response in
            self.getInfo(completion: completion)
        }
    }
    
    func getInfo(completion: @escaping ErrorableResult) {
        let form = AuthLoginForm(userToken: self.userToken, sessionID: self.sessionID!)
        let req = CustomRequest(path: "/Account/UserInfo", method: .post, parameters: form.parameters!).api()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: Account.responseDataSerializer) { response in
            if let user = response.result.value {
                user.role = Account.current!.role
                user.sessionID = Account.current!.sessionID
                Account.current = user
            }
            completion(response.result.error)
        }
    }
}

