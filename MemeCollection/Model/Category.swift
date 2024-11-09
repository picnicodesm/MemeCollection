//
//  CategoryModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import Foundation

struct Category: Hashable {
    private var id = UUID()
    private var name: String
    private var videos: [Video]
    private var isForFavorites: Bool
    
    init(name: String,  isForFavorites: Bool = false, videos: [Video] = []) {
        self.name = name
        self.videos = videos
        self.isForFavorites = isForFavorites
    }
    
    func getName() -> String {
        return name
    }
    
    func getId() -> UUID {
        return id
    }
    
    func getVideos() -> [Video] {
        return videos
    }
    
    func getVideoNums() -> Int {
        return videos.count
    }
    
    func getIsForFavortie() -> Bool {
        return isForFavorites
    }
    
    mutating func setName(to name: String) {
        self.name = name
    }
    
}

extension Category: Persistable {
    func managedObject() -> RealmCategory {
        let realmCategory = RealmCategory()
        realmCategory.id = self.id
        realmCategory.name = self.name
        realmCategory.isForFavorites = self.isForFavorites
        realmCategory.videos.append(objectsIn: self.videos.map { $0.managedObject()})
        
        return realmCategory
    }
    
    init(managedObject: RealmCategory) {
        self.id = managedObject.id
        self.name = managedObject.name
        self.isForFavorites = managedObject.isForFavorites
        self.videos = managedObject.videos.map { return $0.toStruct()}
    }
}
