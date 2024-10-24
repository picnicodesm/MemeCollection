//
//  TempStorage.swift
//  MemeCollection
//
//  Created by 김상민 on 10/23/24.
//

import Foundation
import Combine

class TempStorage {
    static let shared = TempStorage()
    
    @Published var datas: [Video] = []
    
    func getDatas() -> [Video] {
        return datas
    }
    
    func getDatas(of category: Category) -> [Video] {
        return datas.filter { video in
            video.category.uuid == category.uuid
        }
    }
    
    func addData(_ data: Video) {
        datas.append(data)
    }
    
    func removeData(_ data: Video) {
        datas.removeAll { deleteItem in
            data.uuid == deleteItem.uuid
        }
    }
    
    func getNumberOfVideos(in category: Category) -> Int {
        return getDatas(of: category).count
    }
    
    
}
