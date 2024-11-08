//
//  MemeViewModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/22/24.
//

import Foundation
import Combine

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
            ImageManager.shared.removeImage(of: video.getThumbnailIdentifier())
        }
    }
    
    func editVideo(_ video: Video) {
        guard let editIndex = memes.firstIndex(where: { $0.getId() == video.getId() }) else { return }
        memes[editIndex] = video
        
        let categoryId = category.getId()
        if let realmCategory = database.read(of: RealmCategory.self, with: categoryId) {
            if let editVideo = realmCategory.videos.first(where: { $0.id == video.getId() }) {
                database.update {
                    editVideo.name = video.getName()
                    editVideo.urlString = video.getUrlString()
                    editVideo.type = video.getVideoType().rawValue
                    editVideo.isFavorite = video.getIsFavorite()
                    editVideo.thumbnailIdentifier = video.getThumbnailIdentifier()
                    editVideo.categoryId = video.getCategoryId()
                    editVideo.startTime = Int(video.getStartTime())!
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
