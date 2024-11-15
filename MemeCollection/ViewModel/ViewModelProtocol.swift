//
//  ViewModelProtocol.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import Foundation

protocol CategoryViewModel {
    
    func addCategory(_ newCategory: Category)
    
    func deleteCategory(_ deleteItem: Category)
    
    func updateCategoryOrder(to orderedCategory: [Category])
}
