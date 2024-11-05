//
//  ModelProtocol.swift
//  MemeCollection
//
//  Created by 김상민 on 10/29/24.
//

import Foundation
import RealmSwift

protocol Persistable {
    
    associatedtype ManagedObject: RealmSwift.Object
    
    // RealmObject -> Struct 변환
    init(managedObject: ManagedObject)
    
    // Struct -> RealmObject
    func managedObject() -> ManagedObject
}
