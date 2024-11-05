//
//  MainViewModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import Foundation
import Combine
import RealmSwift

class MainViewModel: CategoryViewModel {
    @Published var categories: [Category] = [Category(name: "Favorites"), Category(name: "하니")]
    let database = DataBaseManager.shared
    
    init() {
        let categories = database.read(RealmCategory.self)
        if categories.isEmpty {
            print("찾을 수 없네용")
            print("새로 만들게용")
            let favorites = Category(name: "Favorites")
            self.categories = [favorites]
            database.write(favorites.managedObject())
            return
            
        } else {
            print("이미 있네용")
            self.categories = categories.map { $0.toStruct() }
        }
    }
    
    func addCategory(_ newCategory: Category) {
        categories.append(newCategory)
        database.write(newCategory.managedObject())
//        database.update(newCategory.managedObject()) { newObject in
//            guard let categories = self.database.read(RealmCategories.self).first else { return }
//            categories.categories.append(newCategory.managedObject())
//        }
    }
        
    func deleteCategory(_ deleteItem: Category) {
        if let deleteIndex = categories.firstIndex(of: deleteItem) {
            print("deleteItem: \(deleteItem.getName()) having \(deleteItem.getId())")
            let deleteItemId = categories[deleteIndex].getId()
            categories.remove(at: deleteIndex)
            database.deleteCategory(id: deleteItemId)
            print("delete success?")
        }
    }
    
    func updateCategoryOrder(to orderedCategories: [Category]) {
        categories = orderedCategories
        
//        let categoryOrder = orderedCategories.map { $0.getIndex() }
        database.reorderCategories(orderedCategories)
        
        
    }
    

    func getVideoNums(of category: Category) -> Int {
        return TempStorage.shared.getNumberOfVideos(in: category)
    }
}
