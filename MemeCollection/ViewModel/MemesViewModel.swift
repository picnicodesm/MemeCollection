//
//  MemeViewModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/22/24.
//

import Foundation
import Combine

/*
 MemesViewModel이 초기화 되는 시점: 카테고리 안으로 들어왔을 때
 초기화될 때 해야하는 것: 데이터에서 해당 카테고리의 영상들을 가지고 와야함. <- 지금 할 수 없음. 그러면...
 전체 데이터에서 해당 카테고리인 것만 가져옴.
 */

class MemesViewModel {
    @Published var memes: [Video] = []
    var category: Category
    private var subscriptions = Set<AnyCancellable>()
    private let database = DataBaseManager.shared
    
    init(with category: Category) {
        self.category = category
        self.memes = category.getVideos()
    }
    
    private func bind(with category: Category) {
        
    }
    
    func updateData() {
        self.memes = TempStorage.shared.getDatas(of: category)
    }
    
    private func setData(with category: Category) {
        memes = Video.mock.filter { $0.getCategoryId() == category.getId() }
    }
    
    func addVideo(_ video: Video) {
        // datasource에는 memes에만 추가해주면 되고 + 원래 Category에 추가해줘야 함.
        memes.append(video)
        // realm에는 category를 찾아서 해당 list에 추가해야 한다.
        let realmVideo = video.managedObject()
        let categoryId = category.getId()
        if let realmCategory = database.read(of: RealmCategory.self, with: categoryId) {
            database.update(realmVideo) { realmVideo in
                realmCategory.videos.append(realmVideo)
            }
        }
        
    }
}
