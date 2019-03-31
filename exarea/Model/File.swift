//
//  File.swift
//  exarea
//
//  Created by Soroush on 1/11/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import Foundation

enum FileSavingError: Error {
    case canNotCreateFile(dir: String)
}

enum FileType: String {
    case audio = "Audios"
    case image = "Images"
    case note = "Notes"
    
    func folderURL(forBooth booth: Booth) -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("BoothFiles", isDirectory: true)
            .appendingPathComponent(booth.fairID.description, isDirectory: true)
            .appendingPathComponent(booth.boothID.description, isDirectory: true)
            .appendingPathComponent(self.rawValue, isDirectory: true)
        return url
    }
}

protocol DataConvertible {
    associatedtype Model
    var converted: Model { get }
}

class File {

    let url: URL
    let name: String
    
    class var type: FileType { return .image }
    
    required init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

class ImageFile: File, DataConvertible {

    typealias Model = UIImage
    override class var type: FileType { return .image }
    
    fileprivate var _converted: UIImage?
    
    var converted: UIImage {
        if let image = self._converted {
            return image
        } else {
            guard
                let data = try? Data(contentsOf: self.url),
                let image = UIImage(data: data)
            else { return UIImage() }
            return image
        }
    }
}

class AudioFile: File, DataConvertible {
    typealias Model = URL
    var converted: URL { return self.url }
    override class var type: FileType { return .audio }
    
}

class NoteFile: File, DataConvertible {
    
    typealias Model = Note
    override class var type: FileType { return .note }
    
    fileprivate var _converted: Note?
    
    var converted: Note {
        if let note = self._converted {
            return note
        } else {
            guard
                let data = try? Data(contentsOf: self.url),
                let note = try? Note.create(from: data)
            else { return Note(title: "") }
            return note
        }
    }
    
    func updateNote(_ note: Note) throws {
        try FileManager.default.createDirectory(at: self.url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        guard FileManager.default.createFile(atPath: self.url.path, contents: note.data, attributes: nil)
        else { throw FileSavingError.canNotCreateFile(dir: self.url.path)}
    }
}
