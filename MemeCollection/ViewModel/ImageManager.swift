//
//  ImageManager.swift
//  MemeCollection
//
//  Created by 김상민 on 10/24/24.
//

import Foundation
import UIKit

class ImageManager {
    typealias CompressedImage = (String, Data)
    
    static let shared = ImageManager()
    private let fileManager = FileManager.default

    func saveImage(imageData: Data, as identifier: String) -> Bool {
        guard let directoryPath = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.MemeCollection.Share") else {
            return false
        }
        do {
//            print("directoryPath: \(directoryPath)")
            let encodedIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
//            print("saving identifier: \(identifier)")
            try imageData.write(to: directoryPath.appendingPathComponent(encodedIdentifier))
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func removeImage(of identifier: String) {
        guard let fileURL = getFileURL(of: identifier) else { return }
        if isImageNameExist(identifier: identifier) {
            do {
                try fileManager.removeItem(atPath: fileURL.path())
                // why wasn't image removed with removeItem(url:)???
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    /// If you encode the identifier, filemanager can't find a file cottectly. DON'T KNOW WHY
    func getSavedImage(of identifier: String) -> UIImage? {
        let encodedIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        guard let fileURL = getFileURL(of: encodedIdentifier) else {
            return nil }
                
        if fileManager.fileExists(atPath: fileURL.path()) {
            return UIImage(contentsOfFile: fileURL.path())
        } else {
            return nil
        }
    }
    
    func isImageNameExist(identifier: String) -> Bool {
        guard let fileURL = getFileURL(of: identifier) else { return false }
                
        if fileManager.fileExists(atPath: fileURL.path()) {
            return true
        } else {
            return false
        }
    }
    
   func getCompleteIdentifier(of thumbnailData: Data, with title: String) -> CompressedImage? {
        var imageIdentifierNumber = 0
        let thumbnailImage = UIImage(data: thumbnailData)!
        var imageExtension = ""
        var imageIdentifier = ""
        var compressedImageData: Data = Data()
        
        if let data = thumbnailImage.jpegData(compressionQuality: 1) {
            imageExtension = "jpeg"
            compressedImageData = data
        } else if let data = thumbnailImage.pngData() {
            imageExtension = "png"
            compressedImageData = data
        } else {
            return nil
        }
        
        imageIdentifier = "\(title) \(imageIdentifierNumber).\(imageExtension)"
        
        while isImageNameExist(identifier: imageIdentifier) {
            imageIdentifierNumber += 1
            imageIdentifier = "\(title) \(imageIdentifierNumber).\(imageExtension)"
        }
    
        return CompressedImage(imageIdentifier, compressedImageData)
    }
    
}

extension ImageManager {
    private func getFileURL(of identifier: String) -> URL? {
        guard let dir = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.MemeCollection.Share") else { return nil }
        if #available(iOS 17, *) {
            return URL(string: "\(dir)/\(identifier)", encodingInvalidCharacters: false)
        }
        else {
            return URL(string: "\(dir)/\(identifier)")
//            return dir.appending(path: identifier) <- 이걸 사용하면 또 자동인코딩됨
        }
    }
}
