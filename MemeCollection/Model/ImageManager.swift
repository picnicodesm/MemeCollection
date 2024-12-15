//
//  ImageManager.swift
//  MemeCollection
//
//  Created by 김상민 on 10/24/24.
//

import Foundation
import UIKit

enum ImageError: String, Error {
    case removeFailed = "이미지 수정 실패"
    case saveFailed = "이미지 저장 실패"
    case compressFailed = "이미지 압축 실패"
    
    var description: String {
        switch self {
        case .removeFailed:
            return "이미지를 수정하는데 문제가 발생했습니다."
        case .saveFailed:
            return "이미지를 저장하는데 문제가 발생했습니다."
        case .compressFailed:
            return "이미지를 압축하는데 문제가 발생했습니다."
        }
    }
}

class ImageManager {
    typealias CompressedImage = (String, Data)
    
    static let shared = ImageManager()
    private let fileManager = FileManager.default
    
    func saveImage(imageData: Data, as identifier: String) -> Bool {
        guard let directoryPath = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.MemeCollection.Share") else {
            return false
        }
        do {
            let encodedIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            try imageData.write(to: directoryPath.appendingPathComponent(encodedIdentifier))
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func removeImage(of identifier: String) -> Bool {
        let encodedIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        guard let fileURL = getFileURL(of: encodedIdentifier) else { return false }
        
        if isImageNameExist(identifier: encodedIdentifier) {
            do {
                try fileManager.removeItem(atPath: fileURL.path())
                return true
                // why wasn't image removed with removeItem(url:)???
            } catch {
                print("Error: \(error.localizedDescription)")
                return false
            }
        } else {
            return false
        }
    }
    
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
    
    func getCompleteIdentifier(of thumbnailData: Data, with title: String) -> CompressedImage? {
        var imageIdentifierNumber = 0
        let thumbnailImage = UIImage(data: thumbnailData)!
        var imageExtension = ""
        var imageIdentifier = ""
        var compressedImageData: Data = Data()
        
        
        if let data = thumbnailImage.pngData() {
            imageExtension = "png"
            compressedImageData = data
        } else if let data = thumbnailImage.jpegData(compressionQuality: 1) {
            imageExtension = "jpeg"
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
    
    func getErrorAlert(error: ImageError, action: UIAlertAction) -> UIAlertController {
        let alert = UIAlertController(
            title: "\(error.rawValue)",
            message: "\(error.description)",
            preferredStyle: .alert
        )
        
        alert.addAction(action)
        return alert
    }
}

extension ImageManager {
    private func isImageNameExist(identifier: String) -> Bool {
        guard let fileURL = getFileURL(of: identifier) else { return false }
        
        if fileManager.fileExists(atPath: fileURL.path()) {
            return true
        } else {
            return false
        }
    }
    
    private func getFileURL(of identifier: String) -> URL? {
        guard let dir = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.MemeCollection.Share") else { return nil }
        if #available(iOS 17, *) {
            return URL(string: "\(dir)/\(identifier)", encodingInvalidCharacters: false)
        }
        else {
            return URL(string: "\(dir)/\(identifier)")
        }
    }
    
}
