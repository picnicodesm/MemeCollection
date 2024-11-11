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
        self.memes = category.getVideos(isFavorites: category.getIsForFavortie())
    }
    
    func getVideoNum() -> Int {
        return memes.count
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

        if let deleteItem = database.read(of: RealmVideo.self, with: video.getId()) {
            database.delete(deleteItem)
        }
        ImageManager.shared.removeImage(of: video.getThumbnailIdentifier())
        
        updateVideoOrder(to: memes)
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
    
    func toggleFavorite(of video: Video) {
        print("\(video.getName()) toggle!")
        guard let editIndex = memes.firstIndex(where: { $0.getId() == video.getId() }) else { return }
        memes[editIndex].toggleIsFavorite()

        guard let editVideo = database.read(of: RealmVideo.self, with: video.getId()) else { return }
        guard let favoriteCategory = database.read(RealmCategory.self).first(where: { $0.isForFavorites == true }) else { return }
        
        database.update {
            editVideo.isFavorite = !video.getIsFavorite()
        }
        
        if editVideo.isFavorite == true {
            database.update {
                editVideo.favoritesIndex = favoriteCategory.videos.count
                favoriteCategory.videos.append(editVideo)
            }
        } else {
            database.update { [unowned self] in
                if let removeRealmIndex = favoriteCategory.videos.firstIndex(where: { $0.id == video.getId() }),
                    let removeIndex = memes.firstIndex(where: { $0.getId() == video.getId() }) {
                    editVideo.favoritesIndex = -1
                    favoriteCategory.videos.remove(at: removeRealmIndex)
                    if self.category.getIsForFavortie() {
                        memes.remove(at: removeIndex)
                    }
                }
            }
        }
        
        if !editVideo.isFavorite && category.getIsForFavortie() {
            updateVideoOrder(to: memes)
        }
        
    }
    
    func updateVideoOrder(to orderedVideos: [Video]) {
        self.memes = orderedVideos
        
        for (index, video) in orderedVideos.enumerated() {
            if let willBeEditedVideo = database.read(of: RealmVideo.self, with: video.getId()) {
                database.update { [unowned self] in
                    if self.category.getIsForFavortie() {
                        willBeEditedVideo.favoritesIndex = index
                    } else {
                        willBeEditedVideo.index = index
                    }
                }
            }
        }
    }
    
    
}
