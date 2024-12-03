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
        
    // Video Manager로 바꾸기
    func deleteCategory(_ deleteIndex: IndexPath) {
        let deleteItemId = categories[deleteIndex.item].getId()
        categories.remove(at: deleteIndex.item)
        if let deleteRealmCategory = database.read(of: RealmCategory.self, with: deleteItemId) {
            let deleteRealmVideos = deleteRealmCategory.videos
            for video in deleteRealmVideos {
                let _ = ImageManager.shared.removeImage(of: video.thumbnailIdentifier)
                database.delete(video)
            }
            database.delete(deleteRealmCategory)
            refreshCategory()
        }
    }
    
    func editCategoryName(of id: UUID, to name: String) {
        guard let editIndex = categories.firstIndex(where: { $0.getId() == id }) else { return }
        categories[editIndex].setName(to: name)
        
        guard let editableCategory = database.read(of: RealmCategory.self, with: id) else { return }
        database.update {
            editableCategory.setName(to: name)
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
