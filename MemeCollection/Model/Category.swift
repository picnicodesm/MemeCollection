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
    
    init(name: String, videos: [Video] = []) {
        self.name = name
        self.videos = videos
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
    
    mutating func setName(to name: String) {
        self.name = name
    }
    
}

extension Category: Persistable {
    func managedObject() -> RealmCategory {
        let realmCategory = RealmCategory()
        realmCategory.id = self.id
        realmCategory.name = self.name
        realmCategory.videos.append(objectsIn: self.videos.map { $0.managedObject()})
        return realmCategory
    }
    
    init(managedObject: RealmCategory) {
        self.id = managedObject.id
        self.name = managedObject.name
        self.videos = managedObject.videos.map { return $0.toStruct()}
    }
}
