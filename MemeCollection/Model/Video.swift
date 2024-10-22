//
//  Video.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import Foundation

enum VideoType {
    case video
    case shorts
}

struct Video: Hashable {
    let uuid = UUID()
    var name: String
    var urlString: String
    var type: VideoType
    var isFavorite: Bool
    var startTime: String?
    var filePath: String
    var category: Category
    
    init(name: String, urlString: String, type: VideoType, isFavorite: Bool, startTime: String? = nil, filePath: String, category: Category) {
        self.name = name
        self.urlString = urlString
        self.type = type
        self.isFavorite = isFavorite
        self.startTime = startTime
        self.filePath = filePath
        self.category = category
    }
}

extension Video {
    static var mock: [Video] = [
        Video(name: "Fㅏ니", urlString: "https://www.youtube.com/shorts/cxo-IeAG2T4", type: .shorts, isFavorite: false, filePath: "", category: Category(name: "하니"))
    ]
}
