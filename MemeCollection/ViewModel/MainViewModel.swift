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
    @Published var categories: [Category] = []
    let database = DataBaseManager.shared
    
    init() {
        let categories = database.read(RealmCategory.self)
        if categories.first(where: { $0.isForFavorites == true }) != nil {
            self.categories = categories.sorted(byKeyPath: "index", ascending: true).map { $0.toStruct() }
        } else {
            let favorites = Category(name: "Favorites", index: 0, isForFavorites: true)
            self.categories.append(favorites)
            database.write(favorites.managedObject())
        }
    }
    
    func refreshCategory() {
        let categories = database.read(RealmCategory.self)
        self.categories = categories.sorted(byKeyPath: "index", ascending: true).map { $0.toStruct() }
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
            guard let deleteRealmItem = database.read(of: RealmCategory.self, with: deleteItemId) else { return }
            database.delete(deleteRealmItem)
        }
    }
    
    func editCategoryName(of id: UUID, to name: String) {
        categories = categories.map { editItem in
            var editItem = editItem
            if editItem.getId() == id {
                editItem.setName(to: name)
            }
            return editItem
        }
        
        guard let editableCategory = database.read(of: RealmCategory.self, with: id) else { return }
        database.update(editableCategory) { editObject in
            editObject.setName(to: name)
        }
    }
    
    func updateCategoryOrder(to orderedCategories: [Category]) {
        categories = orderedCategories
        
        for (index, category) in orderedCategories.enumerated() {
            if let willBeEditedCategory = database.read(of: RealmCategory.self, with: category.getId()) {
                database.update {
                    willBeEditedCategory.index = index
                }
            }
        }
    }

    func getVideoNums(of category: Category) -> Int {
        return category.getVideoNums()
    }
}
