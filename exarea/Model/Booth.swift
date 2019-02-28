//
//  Booth.swift
//  exarea
//
//  Created by Soroush on 11/13/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Alamofire

struct Photo: JSONSerializable {
    let boothPhotoID: Int
    let boothPhotoTitle: String
    private let boothPhotoAddress: String
    var address: URL? {
        return URL(string: self.boothPhotoAddress)
    }
}

class Booth: JSONSerializable, ImageTitled {
    
    enum FavoriteAction: String {
        case `is` = "Is"
        case make = "Make"
        case delete = "Delete"
        
        var path: String {
            return self.rawValue
        }
    }
    
    private static var boothFilesURL: URL { return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!  }
    private var path: String { return "/BoothFiles/\(self.fairID)-\(self.boothID)" }
    
    let boothID: Int
    let userID: Int
    let fairID: Int
    let hallID: Int?
    let title: String?
    let logo: String?
    let slogan: String?
    let about: String?
    let qRCodePhotoAddress: String?
    let latitude: String?
    let longitude: String?
    let rialCurrency: Bool?
    let view: Int?
    let sEOFriendlyBoothName: String?
    let isActive: Bool
    let modifiedDate: String?
    let boothPhotoAddress: String?
    private var _score: Int?
    private var _photos: [Photo]?
    private var _isFavorite: Bool?
    
    var isFavorite: Bool {
        return self._isFavorite ?? false
    }
    
    var score: Int {
        return self._score ?? 0
    }
    
    var photos: [Photo] {
        return self._photos ?? []
    }
    
    var imageURL: URL? {
        if let string = self.logo {
            return URL(string: string)
        }
        return nil
    }
    
    var textToShow: String { return self.sEOFriendlyBoothName?.replacingOccurrences(of: "-", with: " ") ?? "" }
    
}

//MARK: - file management

struct Note: JSONSerializable {
    let title, description: String
}

extension Booth {
    
    enum FileType: String {
        case audio = "Audios"
        case image = "Images"
        case note = "Notes"
    }
    
    enum FileSavingError: Error {
        case canNotCreateFile(dir: String)
    }
    
    func urlFor(type: FileType) -> URL {
        return Booth.boothFilesURL.appendingPathComponent(self.path).appendingPathComponent(type.rawValue)
    }
    
    private func getPaths(type: FileType) throws -> [String] {
        return try FileManager.default.contentsOfDirectory(atPath: self.urlFor(type: type).path)
    }
    
    private func getData(type: FileType) throws -> [Data] {
        let paths = try self.getPaths(type: type)
        var dataList = [Data]()
        for path in paths {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            dataList.append(data)
        }
        return dataList
    }
    
    func getImage() throws -> [UIImage] {
        let dataList = try self.getData(type: .image)
        return dataList.map { UIImage(data: $0)! }
    }
    
    func getAudios() throws -> [URL] {
        let pathList = try self.getPaths(type: .audio)
        return pathList.map { URL(fileURLWithPath: $0) }
    }
    
    func getNotes() throws -> ([Note]) {
        let dataList = try self.getData(type: .note)
        return try dataList.map { try Note.create(from: $0) }
    }
    
    
    func saveImage(_ image: UIImage) throws{
        let folderPath = self.urlFor(type: .image)
        try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
        guard FileManager.default.createFile(atPath: folderPath.appendingPathComponent(Date().description).path, contents: image.pngData(), attributes: nil)
            else { throw FileSavingError.canNotCreateFile(dir: folderPath.appendingPathComponent(Date().description).path)}
    }
    
//
//    func saveAudio(_ url: URL) throws {
//        let sourcePath = url.path
//        let folderPath = urlFor(folder: "Audios")
//        try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
//        try FileManager.default.moveItem(atPath: sourcePath, toPath: folderPath.appendingPathComponent(Date().description).path)
//    }
    
    func saveNote(_ note: Note) throws {
        let folderPath = self.urlFor(type: .note)
        try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
        guard FileManager.default.createFile(atPath: folderPath.appendingPathComponent(Date().description).path, contents: note.data, attributes: nil)
        else { throw FileSavingError.canNotCreateFile(dir: folderPath.appendingPathComponent(Date().description).path)}
    }
}

//MARK: - api methods

extension Booth {
    
    static func getBooths(of fair: Fair, page: Int = 0, pageSize: Int = 20, completion: @escaping DataResult<[Booth]>) {
        let pageParams = ["FetchRow": page + pageSize, "SkipRow": page]
        let params = pageParams.merging(["FairID": fair.fairID]) { old, new in new }
        let req = CustomRequest(path: "/Booth/List", method: .post, parameters: params).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: [Booth].responseDataSerializer) { response in
            completion(response.result)
        }
    }
    
    func getScore(completion: @escaping ErrorableResult) {
        let params = ["BoothID": self.boothID]
        let req = CustomRequest(path: "/Booth/BoothScore", method: .post, parameters: params).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: String.responseDataSerializer) { response in
            if let value = response.result.value, let score = Int(value) {
                self._score = score
            }
            completion(response.result.error)
        }
    }
    
    func doScore(_ score: Int, completion: @escaping ErrorableResult) -> DataRequest {
        let params = ["BoothID": self.boothID, "Score": score]
        let req = CustomRequest(path: "/Booth/DoScore", method: .post, parameters: params).api().authorize()
        let dataReq = NetManager.shared.requestWithValidation(req).responseData { response in
            guard let error = response.result.error else {
                self.getScore(completion: completion)
                return
            }
            completion(error)
        }
        
        return dataReq
    }
    
    func getPhotos(completion: @escaping ErrorableResult) {
        let params = ["BoothID": self.boothID]
        let req = CustomRequest(path: "/Booth/Photo", method: .post, parameters: params).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: [Photo].responseDataSerializer) { response in
            self._photos = response.result.value
            completion(response.result.error)
        }
    }
    
    func favorite(action: FavoriteAction, completion: @escaping ErrorableResult) {
        let params = ["BoothID": self.boothID]
        let req = CustomRequest(path: "/Booth/\(action.path)Favorite", method: .post, parameters: params).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: String.responseDataSerializer) { response in
            if let boolString = response.result.value, let isTrue = Bool(exactly: NSNumber(value: Int(boolString)!)) {
                if action == .is {
                    self._isFavorite = isTrue
                } else {
                    self._isFavorite = action == .make ? true : false
                }
            }
            completion(response.result.error)
        }
    }
    
    static func getFavorites(page: Int = 0, pageSize: Int = 20, completion: @escaping DataResult<[Booth]>) {
        let pageParams = ["FetchRow": page + pageSize, "SkipRow": page]
        let req = CustomRequest(path: "/Booth/Favorites", method: .post, parameters: pageParams).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: [Booth].responseDataSerializer) { response in
            completion(response.result)
        }
    }
    
    static func search(query: String, page: Int = 0, pageSize: Int = 20, completion: @escaping DataResult<[Booth]>) {
        let params: Parameters = ["FetchRow": page + pageSize, "SkipRow": page, "TargetWord": query]
        let req = CustomRequest(path: "/Search/SearchBooth", method: .post, parameters: params).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: [Booth].responseDataSerializer) { response in
            completion(response.result)
        }
    }
    
    static func getInfo(id: Int, completion: @escaping DataResult<Booth>) {
        let params = ["BoothID": id]
        let req = CustomRequest(path: "/Booth/Info", method: .post, parameters: params).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: Booth.responseDataSerializer) { response in
            completion(response.result)
        }
    }
    
    func getProducts(completion: @escaping DataResult<[Product]>) {
        let params = ["BoothID": self.boothID]
        let req = CustomRequest(path: "/Booth/ProductList", method: .post, parameters: params).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: [Product].responseDataSerializer) { response in
            completion(response.result)
        }
    }
}
