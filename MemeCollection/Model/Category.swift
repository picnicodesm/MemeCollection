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
    private var index: Int
    private var isForFavorites: Bool
    
    init(name: String, index: Int, isForFavorites: Bool = false, videos: [Video] = []) {
        self.name = name
        self.videos = videos
        self.index = index
        self.isForFavorites = isForFavorites
    }
    
    func getName() -> String {
        return name
    }
    
    func getId() -> UUID {
        return id
    }
    
    func getVideos(isFavorites: Bool) -> [Video] {
        if isFavorites {
            return videos.sorted {
                $0.getFavoriteIndex() < $1.getFavoriteIndex()
            }
        } else {
            return videos.sorted {
                $0.getIndex() < $1.getIndex()
            }
        }
    }
    
    func getVideoNums() -> Int {
        return videos.count
    }
    
    func getIsForFavortie() -> Bool {
        return isForFavorites
    }
    
    func getIndex() -> Int {
        return index
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
        realmCategory.index = self.index
        realmCategory.videos.append(objectsIn: self.videos.map { $0.managedObject()})
        
        return realmCategory
    }
    
    init(managedObject: RealmCategory) {
        self.id = managedObject.id
        self.name = managedObject.name
        self.isForFavorites = managedObject.isForFavorites
        self.index = managedObject.index
        self.videos = managedObject.videos.map { return $0.toStruct()}
    }
}
