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
            let favorites = Category(name: "Favorites")
            self.categories = [favorites]
            database.write(favorites.managedObject())
            return
            
        } else {
            self.categories = categories.map { $0.toStruct() }
        }
    }
    
    func addCategory(_ newCategory: Category) {
        categories.append(newCategory)
        database.write(newCategory.managedObject())
    }
        
    func deleteCategory(_ deleteItem: Category) {
        if let deleteIndex = categories.firstIndex(of: deleteItem) {
            print("deleteItem: \(deleteItem.getName()) having \(deleteItem.getId())")
            let deleteItemId = categories[deleteIndex].getId()
            categories.remove(at: deleteIndex)
            database.deleteCategory(id: deleteItemId)
        }
    }
    
    func editCategoryName(of id: UUID, to name: String) {
        print("id: \(id) to \(name)")
    }
    
    func updateCategoryOrder(to orderedCategories: [Category]) {
        categories = orderedCategories
        database.reorderCategories(orderedCategories)
    }

    func getVideoNums(of category: Category) -> Int {
        return TempStorage.shared.getNumberOfVideos(in: category)
    }
}
