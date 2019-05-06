//
//  NetworkManager.swift
//  saraf.ios
//
//  Created by SoRush on 10/19/1397 AP.
//  Copyright © 1396 tamtom. All rights reserved.
//

import Alamofire
import SwiftyJSON
import SwiftMessages

typealias DataResult<T> = (Result<T>) -> Void
typealias ErrorableResult = (Error?) -> Void

class RetryNeededError: ToastableError {
    
    var image: UIImage? { return UIImage(named: "icon-noConnection-white") }
    let failureReason: String?
    let recoverySuggestion: String?
    
    static let noInternetAccess = RetryNeededError(reason: "خطا در اتصال به اینترنت", suggestion: "لطفا تنظیمات شبکه را بررسی کنید.")
    
    init(reason: String, suggestion: String? = nil) {
        self.failureReason = reason
        self.recoverySuggestion = suggestion
    }
}

enum NetworkError: LocalizedError {
    case resultTypeError(message: String, status: Int)
    case general
    
    var recoverySuggestion: String? {
        return nil
    }
    
    var failureReason: String? {
        switch self {
        case .general:                                 return "عملیات با خطا مواجه شد."
        case .resultTypeError(let message, status: _): return message
        }
    }
}

class NetworkManager: SessionManager {
    static let session: SessionManager = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let session = SessionManager(configuration: config, delegate: CustomSessionDelegate())
        session.retrier = CustomSessionRetrier()
        session.adapter = CustomSessionAdapter()
        return session
    }()
    
    static var toaster: Toaster?
    static var loadingIndicator: LoadingIndicator?
}

class CustomSessionRetrier: RequestRetrier {
    
    private var maxRefreshCount: Int = 5
    private var refreshCount: Int = 0
    private let lock = NSLock()
    private var isRefreshingTokens = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    private func resetRefreshCount() {
        self.refreshCount = 0
        Account.logout()
    }
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        self.lock.lock() ; defer { self.lock.unlock() }
        
        if case AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: let code)) = error {
            switch code {
            case 403:
                guard !self.isRefreshingTokens else { return }
                guard self.maxRefreshCount > self.refreshCount else { return self.resetRefreshCount() }
                self.requestsToRetry.append(completion)
                self.isRefreshingTokens = true
            case 400:
                completion(false, 0.0)
                self.resetRefreshCount()
            default:
                completion(false, 0.0)
                return
            }
        } else {
            completion(false, 0.0)
        }
    }
}

class LoadingIndicator {
    
    private(set) var hasRequestedShowing = false
    private let id: String
    
    init(id: String = "indicatorView") {
        self.id = id
    }
    
    func startLoading(from: SwiftMessages.PresentationStyle = .top) {
        guard !self.hasRequestedShowing else { return }
        self.hasRequestedShowing = true
        let view = try! SwiftMessages.viewFromNib(named: "IndicatorView") as! MessageView
        view.id = id
        view.configureTheme(.info)
        view.configureDropShadow()
        view.bodyLabel?.text = "درحال دریافت اطلاعات"
        var config = SwiftMessages.Config()
        config.duration = .forever
        config.presentationStyle = from
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
    }
    
    func stopLoading() {
        self.hasRequestedShowing = false
        SwiftMessages.hide(id: "indicatorView")
    }
}

class CustomSessionDelegate: SessionDelegate {
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.startLoading(_:)), name: Notification.Name.Task.DidResume, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopLoading(_:)), name: Notification.Name.Task.DidComplete, object: nil)
    }
    
    @objc private func startLoading(_ notif: Notification) {
        guard let indicator = NetworkManager.loadingIndicator else { return }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            if !indicator.hasRequestedShowing {
                NetworkManager.session.session.getAllTasks { tasks in
                    if tasks.contains(where: { $0.state == .running }) {
                        DispatchQueue.main.async {
                            NetworkManager.loadingIndicator?.startLoading()
                        }
                    }
                }
            }
            
        }
    }
    
    @objc private func stopLoading(_ notif: Notification) {
        NetworkManager.session.session.getAllTasks { tasks in
            if !tasks.contains(where: { $0.state == .running }) {
                DispatchQueue.main.async {
                    NetworkManager.loadingIndicator?.stopLoading()
                }
            }
        }
    }
    
    override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let err: Error? = (error as? URLError)?.code == URLError.notConnectedToInternet ? RetryNeededError.noInternetAccess : error
        super.urlSession(session, task: task, didCompleteWithError: err)
        if let toastable = error as? ToastableError, !(toastable is RetryNeededError) {
            NetworkManager.toaster?.toast(error: toastable)
        }
    }
}

extension SessionManager {
    @discardableResult
    func requestWithValidation(_ url: URLRequestConvertible) -> DataRequest {
        let req = request(url).validate().validate(CustomRequest.apiValidation)
        return req
    }
}

class CustomSessionAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        if
            request.url?.pathComponents.contains("api") ?? false,
            let body = request.httpBody,
            let httpBody = try? JSON(data: body),
            var dict = httpBody.dictionaryObject,
            dict["UserToken"] != nil,
            let data = Account.getTokenAndSession() {
            dict["UserToken"] = data.token
            dict["SessionID"] = data.session
            request.httpBody = try! JSON(dict).rawData()
        }
        return request
    }
}

class CustomRequest: URLRequestConvertible {
    
    static var apiValidation: DataRequest.Validation {
        let pattern: (URLRequest?,HTTPURLResponse, Data?) -> (DataRequest.ValidationResult) = { (req, res, data) -> DataRequest.ValidationResult in
            
            guard let data = data else { return .failure(AFError.responseValidationFailed(reason: .dataFileNil)) }
            do {
                let json = try JSON(data: data)
                guard json["Status", "Code"].intValue == 200 else {
                    let status = json["Status", "Code"].intValue
                    let message = json["Status", "Message"].stringValue
                    let error = NetworkError.resultTypeError(message: message, status: status)
                    return .failure(error)
                }
            } catch let err {
                let error = AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: err))
                return .failure(error)
            }
            return .success
        }
        return pattern
    }
    
    
    let path: String
    let method: HTTPMethod
    let parameters: Parameters
    let encoding: ParameterEncoding
    let additionalHeaders: HTTPHeaders
    
    private(set) var isAuthorized = false
    private(set) var isAPI = false
    
    init(path: String,
         method: HTTPMethod = .get,
         parameters: Parameters = [:],
         encoding: ParameterEncoding = JSONEncoding.default,
         headers: HTTPHeaders = [:]
        ) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.encoding = encoding
        self.additionalHeaders = headers
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = self.isAPI ? Configurations.apiURL : Configurations.baseURL
        url += self.path
        
        var params = self.parameters
        
        if self.isAuthorized {
            params = params.merging(["UserToken": "", "SessionID": ""], uniquingKeysWith: { old, new in new })
        }
        
        let originalRequest = try URLRequest(url: url, method: self.method, headers: self.additionalHeaders)
        let encodedURLRequest = try self.encoding.encode(originalRequest, with: params)
        return encodedURLRequest
    }
    
    func authorize() -> CustomRequest {
        self.isAuthorized = true
        return self
    }
    
    func api() -> CustomRequest {
        self.isAPI = true
        return self
    }
}
