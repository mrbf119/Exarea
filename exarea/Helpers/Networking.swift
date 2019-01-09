//
//  NetManager.swift
//  saraf.ios
//
//  Created by SoRush on 10/19/1397 AP.
//  Copyright © 1396 tamtom. All rights reserved.
//

import Alamofire
import SwiftyJSON


typealias ErrorableResult = (Error?) -> Void

struct ResultTypeError: LocalizedError {
    let message: String
    let status: Int
}

enum NetworkError: Error {
    case noInternetAccess
    case resultTypeError(message: String)
    case canceled
    case notAuthorized //401
    case forbidden //403
    case badRequest // 400
}

extension SessionManager {
    
    func requestWithValidation(_ url: URLRequestConvertible) -> DataRequest {
        return self.request(url).validate().validate(CustomRequest.apiValidation)
    }
}

class NetManager: SessionManager, RequestRetrier {
    
    static let shared: NetManager = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 45
        config.timeoutIntervalForResource = 45
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let session = NetManager(configuration: config)
        session.retrier = session
        session.adapter = Adapter()
        return session
    }()
    
    struct Message {
        static var tryAgain: String { return "مشکلی پیش آمده که به زودی برطرف میشود. لطفا کمی بعد دوباره تلاش کنید" }
        static var internetAccess: String { return "ارتباط با سرور برقرار نشد. لطفا ارتباط اینترنت خود را چک کنید" }
        static var getDataFailure: String { return "متاسفانه دریافت اطلاعات به صورت کامل انجام نشد" }
        static var submissionSuccess: String { return "اطلاعات با موفقیت ثبت شد." }
    }
    
    private var maxRefreshCount: Int = 5
    private var refreshCount: Int = 0
    private let lock = NSLock()
    private var isRefreshingTokens = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    private func resetRefreshCount() {
        self.refreshCount = 0
        Account.logout()
    }
    
    override func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        let dataRequest = super.request(urlRequest).validate()
        if let arzbaanReq = urlRequest as? CustomRequest, arzbaanReq.isAPI {
            dataRequest.validate(CustomRequest.apiValidation)
        }
        return dataRequest
    }
    
    var isOnline: Bool {
        let isReachable = NetworkReachabilityManager()!.isReachable
        //if !isReachable { LocalNotification.toast(message: NetManager.Message.internetAccess, type: .error) }
        return isReachable
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
//                User.requestTokens(mode: .refresh) {[weak self] error in
//                    guard let strongSelf = self else { return }
//                    strongSelf.isRefreshingTokens = false
//                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
//                    strongSelf.requestsToRetry.forEach { $0(error == nil, 0.0) }
//                    strongSelf.requestsToRetry.removeAll()
//                }
            case 400:
                completion(false, 0.0)
                DispatchQueue.main.async {
                    self.resetRefreshCount()
                }
            default:
                completion(false, 0.0)
                return
            }
        } else {
            if (error as NSError).code == -1009 {
                DispatchQueue.main.async {
//                    LocalNotification.shared.toast(message: Message.internetAccess, type: .error)
                }
            }
            completion(false, 0.0)
        }
    }
}

class Adapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        if  // checks if request is api and needs auth.
            request.url?.pathComponents.contains("api") ?? false,
            let body = request.httpBody,
            let httpBody = try? JSON(data: body),
            var dict = httpBody.dictionaryObject,
            dict["UserToken"] != nil,
            let token = Account.shared?.userToken,
            let sessionID = Account.shared?.sessionID {
            dict["UserToken"] = token
            dict["SessionID"] = sessionID
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
                guard json["Status", "Code"].intValue == 200 else { return .failure(ResultTypeError(message: json["Status", "Message"].stringValue,
                                                                                                    status: json["Status", "Code"].intValue)) }
            } catch let err {
                return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: err)))
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
    
    func asURLRequest() throws -> URLRequest {
        var url = self.isAPI ? Configurations.apiURL : Configurations.baseURL
        url += self.path
        
        var params = self.parameters
        
        if self.isAuthorized {
            params = params.merging(["UserToken":""], uniquingKeysWith: { old, new in new })
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
}
