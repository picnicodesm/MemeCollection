//
//  CategoryModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/17/24.
//

import Foundation

struct Category: Hashable {
    let uuid = UUID()
    private var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func getName() -> String {
        return name
    }
}

extension Category {
    static var mock: [Category] = [Category(name: "Favorites"), Category(name: "하니"), Category(name: "Category 2"), Category(name: "Category 3"), Category(name: "Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title Long Title")]
}
