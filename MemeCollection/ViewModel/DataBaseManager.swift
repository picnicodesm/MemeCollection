//
//  RealmManager.swift
//  MemeCollection
//
//  Created by 김상민 on 10/29/24.
//

import Foundation
import RealmSwift

protocol DataBase {
    func read<T: Object>(_ object: T.Type) -> Results<T>
    func write<T: Object>(_ object: T)
    func delete<T: Object>(_ object: T)
    func delete<T: Object>(_ object: List<T>)
    func delete<T: Object>(_ object: Results<T>)
}

final class DataBaseManager: DataBase {

    static let shared = DataBaseManager()

    private let database: Realm

    private init() {
        self.database = try! Realm()
    }

    func getLocationOfDefaultRealm() {
        print("Realm is located at:", database.configuration.fileURL!)
    }

    func read<T: Object>(_ object: T.Type) -> Results<T> {
        return database.objects(object)
    }
    
    func read<T: Object>(of type: T.Type, with objectId: UUID) -> T? {
        return database.object(ofType: type, forPrimaryKey: objectId)
    }
    
    func write<T: Object>(_ object: T) {
        do {
            try database.write {
                database.add(object, update: .modified)
                print("New object id added")
            }

        } catch let error {
            print(error)
        }
    }

    func update<T: Object>(_ object: T, completion: @escaping ((T) -> ())) {
        do {
            try database.write {
                completion(object)
            }

        } catch let error {
            print(error)
        }
    }
    
    func update<T: Object>(_ object: [T], completion: @escaping (([T]) -> ())) {
        do {
            try database.write {
                completion(object)
            }

        } catch let error {
            print(error)
        }
    }
        
    func delete<T: Object>(_ object: T) {
        do {
            try database.write {
                database.delete(object)
            }

        } catch let error {
            print(error)
        }
    }
    
    func delete<T: Object>(_ objects: Results<T>) {
           do {
               try database.write {
                   database.delete(objects)
               }
           } catch let error {
               print(error)
           }
    }
    
    func delete<T: Object>(_ objects: List<T>) {
        do {
            try database.write {
                database.delete(objects)
            }
        } catch let error {
            print(error)
        }
    }
}
