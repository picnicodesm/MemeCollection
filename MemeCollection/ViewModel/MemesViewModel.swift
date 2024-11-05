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
    
    init(category: Category) {
        self.category = category
        self.memes = TempStorage.shared.getDatas(of: category)
//        setData(with: category)
        bind(with: category)
    }
    
    private func bind(with category: Category) {
        TempStorage.shared.$datas.sink { [weak self] video in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // 데이터가 실제로 반영되기 전에 함수가 불리는 것을 방지하기 위함.
                self.memes = TempStorage.shared.getDatas(of: category)
            }
        }.store(in: &subscriptions)
    }
    
    func updateData() {
        self.memes = TempStorage.shared.getDatas(of: category)
    }
    
    private func setData(with category: Category) {
        memes = Video.mock.filter { $0.getCategoryId() == category.getId() }
    }
    
    private func addVideo(_ video: Video) {
        var updateVideo = video
        updateVideo.setIndex(to: memes.count + 1)
        Video.mock.append(updateVideo)
        
    }
}
