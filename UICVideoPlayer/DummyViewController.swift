//
//  DummyViewController.swift
//  UICVideoPlayer
//
//  Created by Onur Işık on 6.04.2019.
//  Copyright © 2019 Onur Işık. All rights reserved.
//

import UIKit

class DummyViewController: UIViewController, UICVideoPlayerViewDelegate {
    
    func dismiss(_ videoView: UICVideoPlayerView) {
        handleTap()
    }
    
    
    private var uICVideoPlayer: UICVideoPlayerView!
    var statusBarStyle: UIStatusBarStyle = .default
    lazy var startFrame = CGRect(x: view.frame.width - 5, y: view.frame.height, width: 5, height: 5)
    
    let sampleVideoLink = "http://file-examples.com/wp-content/uploads/2017/04/file_example_MP4_480_1_5MG.mp4"
    let youtubeVideoLink = "http://www.html5videoplayer.net/videos/toystory.mp4"
    
    lazy var animationView: UIView = {
        
        statusBarStyle = .lightContent
        self.setNeedsStatusBarAppearanceUpdate()
        
        let view = UIView(frame: startFrame)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        view.backgroundColor = .purple
        
        let videoViewContainer = UIView(frame: .zero)
        videoViewContainer.backgroundColor = .black
        videoViewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoViewContainer)
        
        let calculatedHeight = self.view.frame.width * 9 / 16
        let videoLayerFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: calculatedHeight)
        uICVideoPlayer = UICVideoPlayerView(frame: videoLayerFrame)
        uICVideoPlayer.videoLink = youtubeVideoLink
        uICVideoPlayer.ownerViewController = self
        uICVideoPlayer.delegate = self
        uICVideoPlayer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uICVideoPlayer)
        
        NSLayoutConstraint.activate([
            
            videoViewContainer.heightAnchor.constraint(equalToConstant: calculatedHeight),
            videoViewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: self.topLayoutGuide.length),
            videoViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            uICVideoPlayer.heightAnchor.constraint(equalToConstant: calculatedHeight),
            uICVideoPlayer.topAnchor.constraint(equalTo: videoViewContainer.topAnchor),
            uICVideoPlayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uICVideoPlayer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        self.view.layoutSubviews()
        
        return view
    }()
    
    lazy var animateButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Start animation", for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.backgroundColor = .purple
        btn.layer.cornerRadius = 7
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handlePress), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(animateButton)
        NSLayoutConstraint.activate([
            animateButton.widthAnchor.constraint(equalToConstant: 200),
            animateButton.heightAnchor.constraint(equalToConstant: 50),
            animateButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            animateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    @objc fileprivate func handlePress(_ sender: UIButton) {
        
        view.addSubview(animationView)
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.animationView.frame = self.view.frame
        }, completion: nil)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    @objc fileprivate func handleTap() {
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.animationView.frame = self.startFrame
        }) { (animationCompleted) in
            
            self.statusBarStyle = .default
            self.setNeedsStatusBarAppearanceUpdate()
            self.animationView.frame = self.startFrame
            self.animationView.removeFromSuperview()
        }
        
    }
    
}





