//
//  RealmManager.swift
//  MemeCollection
//
//  Created by 김상민 on 10/29/24.
//

import Foundation
import RealmSwift

// TODO: Notification으로 error 알리기

protocol DataBase {
    func read<T: Object>(_ object: T.Type) -> Results<T>
    func write<T: Object>(_ object: T)
    func delete<T: Object>(_ object: T)
    func delete<T: Object>(_ object: List<T>)
    func delete<T: Object>(_ object: Results<T>)
}

final class DataBaseManager: DataBase {

    static let shared = DataBaseManager()

    private var database: Realm!

    private init() {
        shareRealm()
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
            print(error.localizedDescription)
        }
    }
    
    func update<T: Object>(_ object: [T], completion: @escaping (([T]) -> ())) {
        do {
            try database.write {
                completion(object)
            }

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func update(completion: @escaping () -> ()) {
        do {
            try database.write {
                completion()
            }
        } catch let error {
            print(error.localizedDescription)
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
    
    func delete<T: Object>(_ object: T, completion: @escaping () -> ()) {
        do {
            try database.write {
                database.delete(object)
                completion()
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

extension DataBaseManager {
    func shareRealm() {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.MemeCollection.Share")?.appendingPathComponent("shared.realm")
        let sharedConfig = Realm.Configuration(fileURL: directory)
        if let bundleUrl = Bundle.main.url(forResource: "bundle", withExtension: "realm") {
            if !FileManager.default.fileExists(atPath: directory!.path) {
                try! FileManager.default.copyItem(at: bundleUrl, to: sharedConfig.fileURL!)
                print(sharedConfig.fileURL!)
            }
            else{
                print("file exist")
            }
        }
        
        database = try! Realm(configuration: sharedConfig)
    }
}
