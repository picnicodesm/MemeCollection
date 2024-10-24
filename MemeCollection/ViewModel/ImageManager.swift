//
//  ImageManager.swift
//  MemeCollection
//
//  Created by 김상민 on 10/24/24.
//

import Foundation
import UIKit

class ImageManager {
    static let shared = ImageManager()

    func saveImage(image: UIImage, name imageName: String) -> Bool {
        var imageExtension = ""
        var compressedImage: Data = Data()
//        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
//            return false
//        }
        if let data = image.jpegData(compressionQuality: 1) {
            imageExtension = "jpeg"
            compressedImage = data
        } else if let data = image.pngData() {
            imageExtension = "png"
            compressedImage = data
        } else {
            return false
        }
            
        guard let directoryPath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            print(directoryPath)
            try compressedImage.write(to: directoryPath.appendingPathComponent("\(imageName).\(imageExtension)")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
}
