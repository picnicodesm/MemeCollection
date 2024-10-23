//
//  MainViewModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import Foundation
import Combine

class MainViewModel: CategoryViewModel {
    @Published var categories: [Category] = [Category(name: "Favorites"), Category(name: "하니")]
    
    func addCategory(_ newCategory: Category) {
        categories.append(newCategory)
    }
        
    func deleteCategory(_ deleteItem: Category) {
        if let deleteIndex = categories.firstIndex(of: deleteItem) {
            categories.remove(at: deleteIndex)
        }
    }
    
    func updateCategoryOrder(to orderedCategory: [Category]) {
        categories = orderedCategory
    }
    
    func getVideoNums(of category: Category) -> Int {
        return TempStorage.shared.getNumberOfVideos(in: category)
    }
}
