//
//  RealmVideo.swift
//  MemeCollection
//
//  Created by 김상민 on 10/25/24.
//

import Foundation
import RealmSwift


class RealmVideo: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var urlString: String
    @Persisted var type: VideoType.RawValue
    @Persisted var isFavorite: Bool
    @Persisted var thumbnailIdentifier: String
    @Persisted var categoryId: UUID
    @Persisted var startTime: Int = 0
    
    func toStruct() -> Video {
        return Video(managedObject: self)
    }
}
