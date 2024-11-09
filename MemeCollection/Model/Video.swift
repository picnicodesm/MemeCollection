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

enum VideoType: String {
    case shorts
    case video
}

struct Video: Hashable {
    private var id = UUID()
    private var name: String
    private var urlString: String
    private var type: String
    private var isFavorite: Bool
    private var thumbnailIdentifier: String
    private var categoryId: UUID
    private var startTime: Int = 0
    
    init(name: String, urlString: String, type: String, isFavorite: Bool, thumbnailIdentifier: String, categoryId: UUID, startTime: Int = 0) {
        self.name = name
        self.urlString = urlString
        self.type = type
        self.isFavorite = isFavorite
        self.thumbnailIdentifier = thumbnailIdentifier
        self.categoryId = categoryId
        self.startTime = startTime
    }
    
    /// Use this initializer when you edit Video object.
    init(id: UUID, name: String, urlString: String, type: String, isFavorite: Bool, thumbnailIdentifier: String, categoryId: UUID, startTime: Int) {
        self.id = id
        self.name = name
        self.urlString = urlString
        self.type = type
        self.isFavorite = isFavorite
        self.thumbnailIdentifier = thumbnailIdentifier
        self.categoryId = categoryId
        self.startTime = startTime
    }
    
    func getId() -> UUID {
        return id
    }
    
    func getCategoryId() -> UUID {
        return categoryId
    }
    
    func getName() -> String {
        return name
    }
    
    func getThumbnailIdentifier() -> String {
        return thumbnailIdentifier
    }
    
    func getUrlString() -> String {
        return urlString
    }
    
    func getStartTime() -> String {
        return String(startTime)
    }
    
    func getIsFavorite() -> Bool {
        return isFavorite
    }
    
    func getVideoType() -> VideoType {
        if type == "shorts" {
            return .shorts
        } else {
            return .video
        }
    }
    
    mutating func toggleIsFavorite() {
        isFavorite.toggle()
    }
}

extension Video: Persistable {
    init(managedObject: RealmVideo) {
        self.id = managedObject.id
        self.name = managedObject.name
        self.urlString = managedObject.urlString
        self.type = managedObject.type
        self.isFavorite = managedObject.isFavorite
        self.thumbnailIdentifier = managedObject.thumbnailIdentifier
        self.categoryId = managedObject.categoryId

        self.startTime = managedObject.startTime
    }
    
    func managedObject() -> RealmVideo {
        let realmVideo = RealmVideo()
        realmVideo.id = self.id
        realmVideo.name = self.name
        realmVideo.urlString = self.urlString
        realmVideo.type = self.type
        realmVideo.isFavorite = self.isFavorite
        realmVideo.thumbnailIdentifier = self.thumbnailIdentifier
        realmVideo.categoryId = self.categoryId
        realmVideo.startTime = self.startTime
        return realmVideo
    }
}

extension Video {
    static var mock: [Video] = []
    /*
     https://youtu.be/-J8AG88-2os?si=9FOsj5Z_7UNVec3X
     https://www.youtube.com/shorts/G25eg25el8s
     */
}
