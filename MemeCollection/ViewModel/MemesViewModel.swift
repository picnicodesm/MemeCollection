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
        memes.append(video)
        let realmVideo = video.managedObject()
        let categoryId = category.getId()
        if let realmCategory = database.read(of: RealmCategory.self, with: categoryId) {
            database.update(realmVideo) { realmVideo in
                realmCategory.videos.append(realmVideo)
            }
        }
    }
    
    func deleteVideo(_ video: Video) {
        guard let deleteIndex = memes.firstIndex(where: { $0.getId() == video.getId() }) else { return }
        memes.remove(at: deleteIndex)
        let categoryId = category.getId()
        if let realmCategory = database.read(of: RealmCategory.self, with: categoryId) {
            database.update(video.managedObject()) { _ in
                if let deleteIndex = realmCategory.videos.firstIndex(where: { $0.id == video.getId() }) {
                    realmCategory.videos.remove(at: deleteIndex)
                }
            }
        }
    }
    
    func updateVideoOrder(to orderedVideos: [Video]) {
        self.memes = orderedVideos
        let categoryId = category.getId()
        if let realmCategory = database.read(of: RealmCategory.self, with: categoryId) {
            let orderedRealmVideos = orderedVideos.map { $0.managedObject() }
            self.database.delete(realmCategory.videos)
            database.update(orderedRealmVideos) { item in
                let _ = orderedRealmVideos.map { video in
                    realmCategory.videos.append(video)
                }
            }
        }
    }
}
