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
    func sort<T: Object>(_ object: T.Type, by keyPath: String, ascending: Bool) -> Results<T>
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
    
    func write<T: Object>(_ objects: List<T>) {
        do {
            try database.write {
                database.add(objects, update: .modified)
                print("New list object is added")
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

    func delete<T: Object>(_ object: T) {
        do {
            try database.write {
                database.delete(object)
                print("Delete single object Success")
            }

        } catch let error {
            print(error)
        }
    }
    
    func deleteAll<T: Object>(_ objects: Results<T>) {
           do {
               try database.write {
                   database.delete(objects)
                   print("Delete Results Success")
               }
           } catch let error {
               print(error)
           }
       }
       
    func deleteCategory(id categoryId: UUID) {
        do {
            try database.write {
                guard let realmCategoryToDelete = database.object(ofType: RealmCategory.self, forPrimaryKey: categoryId) else {
                    return
                }
                database.delete(realmCategoryToDelete)
                print("\(realmCategoryToDelete.name) is deleted")
            }
        } catch {
            print(error)
        }
    }
    
    func sort<T: Object>(_ object: T.Type, by keyPath: String, ascending: Bool = true) -> Results<T> {
        return database.objects(object).sorted(byKeyPath: keyPath, ascending: ascending)
    }
    
    func reorderCategories(_ orderedCategories: [Category]) {
        do {
            try database.write{
                let currentCategories = database.objects(RealmCategory.self)
                database.delete(currentCategories)
                let _ = orderedCategories.map {
                    database.add($0.managedObject())
                }
            }
        } catch {
            print("error")
        }
    }
}
