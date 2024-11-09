//
//  RealmCategory.swift
//  MemeCollection
//
//  Created by 김상민 on 10/25/24.
//

import Foundation
import RealmSwift

class RealmCategory: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var isForFavorites: Bool
    @Persisted var videos: List<RealmVideo>
    
    func toStruct() -> Category {
        return Category(managedObject: self)
    }
    
    func getId() -> UUID {
        return id
    }
    
    func setName(to name: String) {
        self.name = name
    }
    
}
