//
//  VideoManager.swift
//  MemeCollection
//
//  Created by 김상민 on 11/21/24.
//

import Foundation
import UIKit

class VideoManager {
    let database = DataBaseManager.shared
    
    func addVideo(_ video: Video, to id: UUID) {
        guard let category = database.read(of: RealmCategory.self, with: id) else { return }
        database.update {
            category.videos.append(video.managedObject())
        }
    }
    
    func deleteVideo(_ video: Video) -> Bool {
        if !ImageManager.shared.removeImage(of: video.getThumbnailIdentifier()) {
            return false
        }
        if let deleteItem = database.read(of: RealmVideo.self, with: video.getId()) {
            database.delete(deleteItem)
            return true
        } else {
            return false
        }
    }
    
    func editVideo(_ video: Video, in categoryId: UUID) {
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
    
    
    func changeFavorite(of video: Video, to changedState: Bool) {
        guard let editVideo = database.read(of: RealmVideo.self, with: video.getId()) else { return }
        guard let favoriteCategory = database.read(RealmCategory.self).first(where: { $0.isForFavorites }) else { return }
        
        database.update {
            editVideo.isFavorite = !video.getIsFavorite()
        }
        
        if changedState {
            database.update {
                editVideo.favoritesIndex = favoriteCategory.videos.count
                favoriteCategory.videos.append(editVideo)
            }
        } else {
            database.update {
                if let removeRealmIndex = favoriteCategory.videos.firstIndex(where: { $0.id == video.getId() }) {
                    editVideo.favoritesIndex = -1
                    favoriteCategory.videos.remove(at: removeRealmIndex)
                }
            }
        }
    }
    
    
    func updateVideoOrder(using orderedVideos: [Video], isFavoriteCategory: Bool) {
        for (index, video) in orderedVideos.enumerated() {
            if let willBeEditedVideo = database.read(of: RealmVideo.self, with: video.getId()) {
                database.update {
                    if isFavoriteCategory {
                        willBeEditedVideo.favoritesIndex = index
                    } else {
                        willBeEditedVideo.index = index
                    }
                }
            }
        }
    }
    
    
    /// Update indices of video's favoriteIndex property in Favorties category.
    ///  - Note: Only use this function in case of removing favorite video from other category.
    func updateVideosOrderInFavorites() {
        guard let videosInFavorites = database.read(RealmCategory.self).first(where: { $0.isForFavorites })?.videos else { return }
        database.update {
            for (index, video) in videosInFavorites.sorted(byKeyPath: "favoritesIndex", ascending: true).enumerated() {
                print("current video's favorite index: \(index)")
                print("set to \(index)\n")
                video.favoritesIndex = index
            }
        }
    }
}
