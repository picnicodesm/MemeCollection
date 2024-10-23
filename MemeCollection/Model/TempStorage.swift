//
//  TempStorage.swift
//  MemeCollection
//
//  Created by 김상민 on 10/23/24.
//

import Foundation

class TempStorage {
    static let shared = TempStorage()
    
    private var datas: [Video] = []
    
    func addData(_ data: Video) {
        datas.append(data)
    }
    
    func removeData(_ data: Video) {
        datas.removeAll { deleteItem in
            data.uuid == deleteItem.uuid
        }
    }
    
    
}
