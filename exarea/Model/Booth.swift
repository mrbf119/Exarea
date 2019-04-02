//
//  Booth.swift
//  exarea
//
//  Created by Soroush on 11/13/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import Alamofire

class Booth: JSONSerializable, ImageTitled {
    
    enum FavoriteAction: String {
        case `is` = "Is"
        case make = "Make"
        case delete = "Delete"
        
        var path: String {
            return self.rawValue
        }
    }
    
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
    
    var textToShow: String { return self.title ?? "" }
    
    var serverFilesFolderURL: URL {
        return
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("BoothFiles", isDirectory: true)
            .appendingPathComponent(self.fairID.description, isDirectory: true)
            .appendingPathComponent(self.boothID.description, isDirectory: true)
    }
}

//MARK: - file management

extension Booth {
   
    func addImageFile(_ image: UIImage) throws {
        let folderPath = FileType.image.folderURL(forBooth: self)
        try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
        let fileURL = folderPath.appendingPathComponent(Date().description)
        guard FileManager.default.createFile(atPath: fileURL.path, contents: image.pngData(), attributes: nil)
            else { throw FileSavingError.canNotCreateFile(dir: folderPath.appendingPathComponent(Date().description).path)}
    }
    
    func addNoteFile(title: String, content: String? = nil) throws {
        let folderPath = FileType.note.folderURL(forBooth: self)
        let url = folderPath.appendingPathComponent(Date.timeIntervalSinceReferenceDate.description)
        let note = Note(title: title, content: content)
        
        try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
        guard FileManager.default.createFile(atPath: url.path, contents: note.data, attributes: nil)
            else { throw FileSavingError.canNotCreateFile(dir: url.path)}
    }
    
    func getLocalFiles<T: File>(ofType: T.Type) throws -> [T] {
        let url = T.type.folderURL(forBooth: self)
        let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
        return urls.map { T.init(name: $0.lastPathComponent, url: $0) }
    }
    
    func delete(file: File) throws {
        try FileManager.default.removeItem(at: file.url)
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
    
    func getServerFiles(completion: @escaping DataResult<[BoothFile]>) {
        let params = ["BoothID": self.boothID]
        let req = CustomRequest(path: "/Booth/File", method: .post, parameters: params).api().authorize()
        NetManager.shared.requestWithValidation(req).response(responseSerializer: [BoothFile].responseDataSerializer) { response in
            completion(response.result)
        }
    }
    
    @discardableResult
    func open(file: BoothFile, completion: @escaping DataResult<URL>) -> DownloadRequest? {
        let serverURL = URL(string: file.fileAddress)!
        let destinationURL = self.serverFilesFolderURL.appendingPathComponent(serverURL.lastPathComponent)
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            completion(.success(destinationURL))
            return nil
        } else {
            
            let req = NetManager.shared.download(serverURL) { (_, _) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                return (destinationURL, .createIntermediateDirectories)
                }.responseData { response in
                    switch response.result {
                    case .success:
                        completion(.success(destinationURL))
                    case .failure(let error):
                        completion(.failure(error))
                    }
            }
            return req
        }
    }
    
    func hasDownloaded(file: BoothFile) -> Bool {
        let serverURL = URL(string: file.fileAddress)!
        let destinationURL = self.serverFilesFolderURL.appendingPathComponent(serverURL.lastPathComponent)
        return FileManager.default.fileExists(atPath: destinationURL.path)
    }
}
