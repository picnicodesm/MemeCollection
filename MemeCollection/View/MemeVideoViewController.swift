//
//  MemeVideoViewController.swift
//  MemeCollection
//
//  Created by 김상민 on 11/8/24.
//

import UIKit
import WebKit

class MemeVideoViewController: UIViewController {
    private var isMoved: Bool = false
//    let viewAspectRatio: CGFloat = 16/9
    var webView: WKWebView!
    var memesVM: MemesViewModel!
    var currentIndex: Int! {
        willSet(newValue) {
            isMoved = false
            currentVideoURL = memesVM.memes[newValue].getUrlString()
            videoType = memesVM.memes[newValue].getVideoType()
        }
    }
    lazy var currentVideoURL: String = memesVM.memes[currentIndex].getUrlString()
    lazy var videoType: VideoType = memesVM.memes[currentIndex].getVideoType()
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
}

// MARK: - Configure View
extension MemeVideoViewController {
    private func configureView() {
        view.backgroundColor = .black
        createWebView()
        loadWebView()
        configureToolbar()
    }
    
    private func createWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = .video
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        webView.scrollView.isScrollEnabled = false
        view.addSubview(webView)
        self.webView = webView
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadWebView() {
        guard let url = URL(string: currentVideoURL) else { return }
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
    
    private func loadWebView(to urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func configureToolbar() {
        self.navigationController?.isToolbarHidden = false
        let buttonSize = CGRect(x: 0, y: 0, width: 100, height: 0)
    
        let leftToolbarButtonItem = configureLeftToolbarButton(frame: buttonSize)
        let rightToolbarButtonItem = configureRightToolbarButton(frame: buttonSize)
        let centerToolbarButtonItem = configureCenterTollbarButton(frame: buttonSize)
        let flexibleSpaceBarButtonItem = UIBarButtonItem(systemItem: .flexibleSpace)
    
        self.toolbarItems = [leftToolbarButtonItem, flexibleSpaceBarButtonItem, centerToolbarButtonItem, flexibleSpaceBarButtonItem, rightToolbarButtonItem]
    }
    
    private func configureLeftToolbarButton(frame: CGRect) -> UIBarButtonItem {
        let leftToolbarButton = UIButton(frame: frame)
        var leftToolbarButtonConfig = UIButton.Configuration.plain()
        leftToolbarButtonConfig.title = "Previous"
        leftToolbarButton.configuration = leftToolbarButtonConfig
        
        let leftToolbarButtonHandler = UIAction { [weak self] _ in
            guard let self = self else { return }
            let count = self.memesVM.getVideoNum()
            currentIndex = (currentIndex + count - 1) % count
            loadWebView(to: currentVideoURL)
        }
        leftToolbarButton.addAction(leftToolbarButtonHandler, for: .touchUpInside)
        
        return UIBarButtonItem(customView: leftToolbarButton)
    }
    
    private func configureRightToolbarButton(frame: CGRect) -> UIBarButtonItem {
        let rightToolbarButton = UIButton(frame: frame)
        var rightToolbarButtonConfig = UIButton.Configuration.plain()
        rightToolbarButtonConfig.title = "Next"
        rightToolbarButton.configuration = rightToolbarButtonConfig
        
        let rightToolbarButtonHandler = UIAction { [weak self] _ in
            guard let self = self else { return }
            let count = self.memesVM.getVideoNum()
            currentIndex = (currentIndex + count + 1 ) % count
            loadWebView(to: currentVideoURL)
        }
        rightToolbarButton.addAction(rightToolbarButtonHandler, for: .touchUpInside)
        
        return UIBarButtonItem(customView: rightToolbarButton)
    }
    
    private func configureCenterTollbarButton(frame: CGRect) -> UIBarButtonItem {
        let centerToolbarButton = UIButton(frame: frame)
        var centerToolbarButtonConfig = UIButton.Configuration.plain()
        centerToolbarButtonConfig.title = "Memes"
        centerToolbarButton.configuration = centerToolbarButtonConfig
        
        let backToolbarButtonHandler = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        centerToolbarButton.addAction(backToolbarButtonHandler, for: .touchUpInside)
        
        return UIBarButtonItem(customView: centerToolbarButton)
    }
}

extension MemeVideoViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let url = self.webView.url?.absoluteString else { return }
        
        if url != currentVideoURL {
            if videoType == .video {
                if !isMoved {
                    isMoved.toggle()
                    currentVideoURL =  url
                } else {
                    loadWebView(to: currentVideoURL)
                }
            } else {
                loadWebView(to: currentVideoURL)
            }
        }
    }
}
