//
//  MemeViewModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/22/24.
//

import Foundation

/*
 MemesViewModel이 초기화 되는 시점: 카테고리 안으로 들어왔을 때
 초기화될 때 해야하는 것: 데이터에서 해당 카테고리의 영상들을 가지고 와야함. <- 지금 할 수 없음. 그러면...
 전체 데이터에서 해당 카테고리인 것만 가져옴.
 */

class MemesViewModel {
    @Published var memes: [Video] = []
    var category: Category
    
    init(category: Category) {
        self.category = category
        setData(with: category)
    }
    
    private func setData(with category: Category) {
        memes = Video.mock.filter { $0.category.uuid == category.uuid }
    }
    
    private func addVideo(_ video: Video) {
        Video.mock.append(video)
    }
}
