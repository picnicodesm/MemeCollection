//
//  AddVideoViewModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/22/24.
//

import Foundation

enum LinkError: String {
    case linkTypeError = "Link isn't matched with correct type."
    case videoTypeError = "Link isn't matched with correct video type."
    case strangeLinkError = "This is incorrect link."
    case keyError = "The key is incorrect."
}

class AddVideoViewModel {
    typealias LinkTestResult = (Bool, LinkError?, VideoType?, LinkType?, String?)

    @Published var thumbnailData: Data?
    
    /// Test the given link whether it is correct youtube link.
    /// - Parameter link: The link for test
    /// - Returns: if test is succeed, return (true, nil, videoType, LinkType, key). if failed, return (false, error, nil, nil, nil)
    func testLink(with link: String) -> LinkTestResult {
        
        guard let linkType = getLinkType(of: link) else {
            return (false, LinkError.linkTypeError , nil, nil, nil)
        }
        guard let videoType = getVideoType(of: link) else {
            return (false, LinkError.videoTypeError, nil, nil, nil)
        }
        guard let key = getKey(of: link, linkType: linkType, videoType: videoType) else {
            return (false, LinkError.strangeLinkError, nil, nil, nil)
        }
        
        return (true, nil, videoType, linkType, key)
    }
    
    func setThumbnail(with key: String) async {
        let thumbnailString = "https://img.youtube.com/vi/\(key)/0.jpg"
        guard let url = URL(string: thumbnailString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.thumbnailData = data
        } catch {
            print("Error fetching thumbnail data: \(error)")
            return
        }
    }
    
    func getErrorData() async -> Data? {
        let errorString = "https://img.youtube.com/vi/errorKey/0.jpg"
        guard let url = URL(string: errorString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print("Error fetching thumbnail data: \(error)")
            return nil
        }
    }

    
    func makeMobileLink(using key: String, type videoType: VideoType, at time: String) -> String {
        if videoType == .shorts { return "https://m.youtube.com/shorts/\(key)" }
        else { return "https://m.youtube.com/watch?v=\(key)&t=\(time)s" }
    }
    
}

extension AddVideoViewModel {
    private func getLinkType(of urlString: String) -> LinkType? {
        if urlString.contains("https://www.youtube.com") {
            return .web
        } else if urlString.contains("https://m.youtube.com") {
            return .mobile
        } else if urlString.contains("https://youtube.com") || urlString.contains("https://youtu.be") {
            return .share
        } else {
            return nil
        }
    }
    
    private func getVideoType(of urlString: String) -> VideoType? {
        // This function must use after getLinkType(of:).
        // Because It doesn't ensure video's type without getLinkType(of:).
        if urlString.contains("shorts/") { return .shorts }
        if urlString.contains("watch?v=") || urlString.contains("youtu.be") { return .video }
        return nil
    }
    
    private func getKey(of urlString: String, firstDivider: String, secondDivider: Character) -> String? {
        if let firstDividerRange = urlString.range(of: "\(firstDivider)") {
            if let secondDividerIndex = urlString.firstIndex(of: secondDivider) {
                let key = urlString[firstDividerRange.upperBound..<secondDividerIndex]
                print("key: \(key) with divider \(secondDivider)")
                return String(key)
            } else {
                let key = urlString[firstDividerRange.upperBound...]
                print("key: \(key) with divider \(firstDivider)")
                return String(key)
            }
        }
        return nil
    }
    
    private func getKey(of urlString: String, linkType: LinkType, videoType: VideoType) -> String? {
        switch linkType {
        case .web: fallthrough
        case .mobile:
            if videoType == .shorts {
                return getKey(of: urlString, firstDivider: "shorts/", secondDivider: "&")
            } else {
                return getKey(of: urlString, firstDivider: "watch?v=", secondDivider: "&")
            }
            
        case .share:
            if videoType == .shorts {
                return getKey(of: urlString, firstDivider: "shorts/", secondDivider: "?")
            } else {
                return getKey(of: urlString, firstDivider: ".be/", secondDivider: "?")
            }
        }
    }
}
