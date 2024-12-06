//
//  AddVideoViewModel.swift
//  MemeCollection
//
//  Created by 김상민 on 10/22/24.
//

import Foundation

enum LinkError: String {
    case linkTypeError = "올바른 주소 형식이 아닙니다."
    case videoTypeError = "주소가 영상의 주소 형식과 맞지 않습니다."
    case strangeLinkError = "올바른 주소가 아닙니다."
    case keyError = "잘못된 주소입니다."
}

/// Test for given link and have video information and thumbnailData from the link
class TestLinkViewModel {
    typealias LinkTestResult = (Bool, LinkError?, VideoType?, LinkType?, String?)
    typealias VideoInfo = (key: String?, videoType: VideoType?, linkType: LinkType?)
    
    @Published var thumbnailData: Data?
    private var videoInfo: VideoInfo = (nil, nil, nil)
    
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
        
        self.videoInfo = (key, videoType, linkType)
        return (true, nil, videoType, linkType, key)
    }
    
    func setThumbnail(with key: String) async {
        let thumbnailString = "https://img.youtube.com/vi/\(key)/0.jpg"
        guard let url = URL(string: thumbnailString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.thumbnailData = data
        } catch {
            self.thumbnailData = nil
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
            return nil
        }
    }
    
    func makeMobileLink(of link: String, using key: String, at time: String) -> String {
        let videoType = getVideoType(of: link)
        if videoType == .shorts { return "https://m.youtube.com/shorts/\(key)" }
        else {
//            print("gived time: \(time)")
            return "https://m.youtube.com/watch?v=\(key)&t=\(time)s"
        }
    }
    
    func getMobileLink(startFrom time: Int) -> String? {
        guard let videoType = videoInfo.videoType, let key = videoInfo.key else { return nil }
        
        if videoType == .shorts { return "https://m.youtube.com/shorts/\(key)" }
        else {
            return "https://m.youtube.com/watch?v=\(key)&t=\(time)s"
        }
    }
    
    func getVideoInfo() -> VideoInfo {
        return videoInfo
    }
}

extension TestLinkViewModel {
    private func getLinkType(of urlString: String) -> LinkType? {
        if urlString.contains("https://www.youtube.com/") {
            return .web
        } else if urlString.contains("https://m.youtube.com/") {
            return .mobile
        } else if urlString.contains("https://youtube.com/") || urlString.contains("https://youtu.be/") {
            return .share
        } else {
            return nil
        }
    }
    
    /// This function must be used after getLinkType(of:).
    /// Or use this function when you sure the link has no problem.
    private func getVideoType(of urlString: String) -> VideoType? {
        if urlString.contains("shorts/") { return .shorts }
        if urlString.contains("watch?v=") || urlString.contains("youtu.be") { return .video }
        return nil
    }
    
    private func getKey(of urlString: String, firstDivider: String, secondDivider: Character) -> String? {
        print("sent divider: \(firstDivider), and \(secondDivider)")
        if let firstDividerRange = urlString.range(of: "\(firstDivider)") {
            if let secondDividerIndex = urlString.firstIndex(of: secondDivider) {
                let key = urlString[firstDividerRange.upperBound..<secondDividerIndex]
                print("key: \(key) with divider \(firstDivider) and \(secondDivider)")
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
                let key = getKey(of: urlString, firstDivider: ".be/", secondDivider: "?")
                if key != nil {
                    return key
                } else {
                    return getKey(of: urlString, firstDivider: "watch?v=", secondDivider: "&")
                }
            }
        }
    }
}
