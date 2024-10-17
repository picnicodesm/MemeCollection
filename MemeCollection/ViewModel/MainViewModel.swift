//
//  MainViewModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import Foundation
import Combine

class MainViewModel {
    @Published private var categories: [Category] = []
    
    func addCategory(_ category: Category) {
        categories.append(category)
    }
        
    
}
