//
//  JSONSerializable.swift
//  Helper
//
//  Created by Soroush on 10/19/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Alamofire
import SwiftyJSON

public typealias CodingStrategies = (decodeStrategy: JSONDecoder.KeyDecodingStrategy, encodeStrategy: JSONEncoder.KeyEncodingStrategy)

public protocol SelfDataSerializable {
    associatedtype ModelObject = Self
    static var responseDataSerializer: DataResponseSerializer<Self.ModelObject> { get }
}

public protocol JSONSerializable: SelfDataSerializable, Codable where ModelObject: JSONSerializable {
    
    associatedtype ModelObject = Self
    
    var data: Data? { get }
    var json: JSON? { get }
    var jsonString: String? { get }
    var parameters: Parameters? { get }
    static var config: CodingStrategies { get }
    static var listKeyConfig: String { get }
    static func create(from data: Data) throws -> ModelObject?
    static func createList(from data: Data) throws -> [ModelObject]?
    
}


extension JSONSerializable {
    
    static var config: CodingStrategies {
        return (.convertFromUpperCamelCase, .convertToUpperCamelCase)
    }
    
    public static var listKeyConfig: String {
        return "Result"
    }
    
    public static func create(from data: Data) throws -> Self.ModelObject? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = self.config.decodeStrategy
        let model = try decoder.decode(ModelObject.self, from: data)
        return model
    }
    
    public static func createList(from data: Data) throws -> [Self.ModelObject]? {
        let json = JSON(data)
        var objectList: [Self.ModelObject] = []
        guard let list = json[Self.listKeyConfig].array else { return nil }
        for objectJson in list {
            let objectData = try objectJson.rawData()
            if let object =  try self.create(from: objectData) {
                objectList.append(object)
            }
        }
        return objectList
    }
    
    public var data: Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = Self.config.encodeStrategy
        return try? encoder.encode(self)
    }
    
    public var json: JSON? {
        guard
            let data = self.data,
            let objJson = try? JSON(data: data)
            else { return nil }
        return objJson
    }
    
    public var jsonString: String? {
        guard let data = self.data else { return nil }
        let jsonString = String(data: data, encoding: .utf8)
        return jsonString
    }
    
    public var parameters: Parameters? {
        return self.json?.dictionaryObject
    }
    
    public static var responseDataSerializer: DataResponseSerializer<Self.ModelObject> {
        let serial = DataResponseSerializer<Self.ModelObject>{ (url, response, data, error) -> Result<Self.ModelObject> in
            guard error == nil else { return .failure(error!) }
            guard let data = data else { return .failure(AFError.responseSerializationFailed(reason: .inputDataNil)) }
            do {
                let selfObject = try self.create(from: JSON(data)["Result"].rawData())!
                return .success(selfObject)
            } catch let err {
                return .failure(err)
            }
        }
        return serial
    }
}

extension Array: SelfDataSerializable where Element: JSONSerializable  {
    public static var responseDataSerializer: DataResponseSerializer<Array<Element>> {
        let x = DataResponseSerializer<Array<Element>> { (_, _, data, error) -> Result<Array<Element>> in
            guard error == nil else { return .failure(error!) }
            guard let data = data else { return .failure(AFError.responseSerializationFailed(reason: .inputDataNil)) }
            do {
                let list = try Element.createList(from: data)
                let d = list as! [Element]
                return .success(d)
            } catch let err {
                return .failure(err)
            }
        }
        return x
    }
    
}

extension JSON: SelfDataSerializable {
    public static var responseDataSerializer: DataResponseSerializer<JSON> {
        let serializer = DataResponseSerializer<JSON>.init { (url, response, data, error) -> Result<JSON> in
            guard error == nil else { return .failure(error!) }
            guard let data = data else { return .failure(AFError.responseSerializationFailed(reason: .inputDataNil)) }
            do {
                let json = try JSON(data: data)
                return .success(json)
            } catch let err {
                return .failure(err)
            }
        }
        return serializer
    }
}

extension String: SelfDataSerializable {
    public static var responseDataSerializer: DataResponseSerializer<String> {
        let serializer = DataResponseSerializer<String>.init { (url, response, data, error) -> Result<String> in
            guard error == nil else { return .failure(error!) }
            guard let data = data else { return .failure(AFError.responseSerializationFailed(reason: .inputDataNil)) }
            do {
                let json = try JSON(data: data)
                guard let string = json["Result"].string else { return .failure(AFError.responseSerializationFailed(reason: .stringSerializationFailed(encoding: .utf8))) }
                return .success(string)
            } catch let err {
                return .failure(err)
            }
        }
        return serializer
    }
}

extension Data: SelfDataSerializable {
    public static var responseDataSerializer: DataResponseSerializer<Data> {
        let serializer = DataResponseSerializer<Data>.init { (url, response, data, error) -> Result<Data> in
            guard error == nil else { return .failure(error!) }
            guard let data = data else { return .failure(AFError.responseSerializationFailed(reason: .inputDataNil)) }
            return .success(data)
        }
        return serializer
    }
}
