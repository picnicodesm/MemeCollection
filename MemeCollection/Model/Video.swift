//
//  Video.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import Foundation

enum LinkType {
    case web
    case mobile
    case share
}

enum VideoType {
    case shorts
    case video
}

struct Video: Hashable {
    let uuid = UUID()
    var name: String
    var urlString: String
    var type: VideoType
    var isFavorite: Bool
    var thumbnailIdentifier: String
    var category: Category
    var startTime: Int = 0
    
    init(name: String, urlString: String, type: VideoType, isFavorite: Bool, thumbnailIdentifier: String, category: Category, startTime: Int = 0) {
        self.name = name
        self.urlString = urlString
        self.type = type
        self.isFavorite = isFavorite
        self.thumbnailIdentifier = thumbnailIdentifier
        self.category = category
        self.startTime = startTime
    }
}

extension Video {
    static var mock: [Video] = [
        Video(name: "Fㅏ니", urlString: "https://www.youtube.com/shorts/cxo-IeAG2T4", type: .shorts, isFavorite: false, thumbnailIdentifier: "", category: Category(name: "하니"))
    ]
}
