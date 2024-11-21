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
    private let videoManager = VideoManager()
    
    init(of category: Category) {
        self.category = category
        self.memes = category.getVideos(isFavorites: category.getIsForFavortie())
    }
    
    func getVideoNum() -> Int {
        return memes.count
    }
    
    func addVideo(_ video: Video) {
        memes.append(video)
        videoManager.addVideo(video, to: category.getId())
    }
    
    func deleteVideo(_ video: Video) {
        guard let deleteIndex = memes.firstIndex(where: { $0.getId() == video.getId() }) else { return }
        memes.remove(at: deleteIndex)
        videoManager.deleteVideo(video)
        updateVideoOrder(to: memes)
    }
    
    func editVideo(_ video: Video) {
        guard let editIndex = memes.firstIndex(where: { $0.getId() == video.getId() }) else { return }
        memes[editIndex] = video
      
        videoManager.editVideo(video, in: category.getId())
    }
    
    func toggleFavorite(of video: Video) {
        guard let editIndex = memes.firstIndex(where: { $0.getId() == video.getId() }) else { return }
        memes[editIndex].toggleIsFavorite()
        let changedState = memes[editIndex].getIsFavorite()
        
        videoManager.changeFavorite(of: video, to: changedState)
        
        if !changedState {
            if category.getIsForFavortie() {
                memes.remove(at: editIndex)
                videoManager.updateVideoOrder(using: memes, isFavoriteCategory: category.getIsForFavortie())
            } else {
                videoManager.updateVideosOrderInFavorites()
            }
        }
    }
    
    func updateVideoOrder(to orderedVideos: [Video]) {
        self.memes = orderedVideos
        videoManager.updateVideoOrder(using: orderedVideos, isFavoriteCategory: category.getIsForFavortie())
    }
 
    /// Used when video is added from extension.
    func refreshMemes() {
        guard let realmCategory = database.read(of: RealmCategory.self, with: category.getId()) else { return }
        self.category = realmCategory.toStruct()
        self.memes = self.category.getVideos(isFavorites: self.category.getIsForFavortie())
    }
    
}
