//
//  RealmCategories.swift
//  MemeCollection
//
//  Created by 김상민 on 10/29/24.
//

import Foundation
import RealmSwift

class RealmCategories: Object {
    @Persisted(primaryKey: true) var id = UUID()
    @Persisted var categories: List<RealmCategory>
    
    func toStruct() -> [RealmCategory] {
        return Array(categories)
    }
}
