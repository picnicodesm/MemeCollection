//
//  CategoryModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import Foundation

struct Category: Hashable {
    private var name: String
    private var videoNums: Int = 0
    
    init(name: String) {
        self.name = name
    }
    
    func getName() -> String {
        return name
    }
    
    func getVideoNumbers() -> Int {
        return videoNums
    }
}

extension Category {
    static var mock: [Category] = [Category(name: "Favorites"), Category(name: "Category 1"), Category(name: "Category 2"), Category(name: "Category 3")]
}
