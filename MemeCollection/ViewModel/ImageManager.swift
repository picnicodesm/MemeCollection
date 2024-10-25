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

    func saveImage(imageData: Data, as identifier: String) -> Bool {
        guard let directoryPath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return false
        }
        do {
            print("directoryPath: \(directoryPath)")
            let encodedIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            print("saving identifier: \(identifier)")
            try imageData.write(to: directoryPath.appendingPathComponent(encodedIdentifier))
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    /// If you encode the identifier, filemanager can't find a file cottectly. DON'T KNOW WHY
    func getSavedImage(of identifier: String) -> UIImage? {
        guard let fileURL = getFileURL(of: identifier) else { return nil }
                
        if FileManager.default.fileExists(atPath: fileURL.path()) {
            return UIImage(contentsOfFile: fileURL.path())
        } else {
            return nil
        }
    }
    
    func isImageNameExist(identifier: String) -> Bool {
        guard let fileURL = getFileURL(of: identifier) else { return false }
                
        if FileManager.default.fileExists(atPath: fileURL.path()) {
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
        guard let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }
        return dir.appending(path: identifier)
    }
}
