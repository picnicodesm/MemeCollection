//
//  MainViewModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import Foundation
import Combine
import RealmSwift

// TODO: - Favorite을 만들고 unique하게 알 수 있는 방법 생각하기
// TODO: - Favorite button 추가하고 로직 넣기
// TODO: - Cell design
// TODO: - Add video category 선택도 할 수 있게 하기

class MainViewModel: CategoryViewModel {
    @Published var categories: [Category] = []
    let database = DataBaseManager.shared
    
    init() {
        let categories = database.read(RealmCategory.self)
        if categories.first(where: { $0.isForFavorites == true }) != nil {
            self.categories = categories.map { $0.toStruct() }
        } else {
            let favorites = Category(name: "Favorites", isForFavorites: true)
            if categories.isEmpty {
                self.categories.append(favorites)
                database.write(favorites.managedObject())
            } else {
                let temp: [Category] = categories.map { $0.toStruct() }
                self.categories.insert(favorites, at: 0)
                database.delete(categories)
                database.write(favorites.managedObject())
                for category in temp {
                    self.database.write(category.managedObject())
                    self.categories.append(category)
                }
            }

        }
    }
    
    func refreshCategory() {
        let categories = database.read(RealmCategory.self)
        self.categories = categories.map { $0.toStruct() }
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
        let currentCategories = database.read(RealmCategory.self)
        for category in currentCategories {
            database.delete(category.videos)
        }
        database.delete(currentCategories)
        let _ = orderedCategories.map {
            database.write($0.managedObject())
        }
        
    }

    func getVideoNums(of category: Category) -> Int {
        return category.getVideoNums()
    }
}
