//
//  UICVideoPlayerView.swift
//  VideoPlayer
//
//  Created by Coder ACJHP on 6.04.2019.
//  Copyright © 2019 Onur Işık. All rights reserved.
//

import UIKit
import AVFoundation

protocol UICVideoPlayerViewDelegate: class {
    func dismiss(_ videoView: UICVideoPlayerView)
}

class UICVideoPlayerView: UIView {
    
    
    enum KeyPath: String {
        case Status = "status"
        case TimeControl = "timeControlStatus"
        case LoadedTimeRange = "currentItem.loadedTimeRanges"
    }
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer?
    private var isMuted: Bool = false
    private var isPlaying: Bool = false
    private var isFirstPlaying: Bool = true
    private var lastVolumeSliderPosition: Float = 0
    private var isControlContainerViewShowing: Bool = false
    
    private var contextMenu: ContextMenu!
    
    private lazy var playPauseButton: UIButton = {
        let btn = UIButton(type: .system)
        let icon = UIImage(named: "pause")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.tag = 0
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handlePress(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var forwardButton: UIButton = {
        let btn = UIButton(type: .system)
        let icon = UIImage(named: "forward")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.tag = 1
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handlePress(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var rewindButton: UIButton = {
        let btn = UIButton(type: .system)
        let icon = UIImage(named: "rewind")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.tag = 2
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handlePress(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var volumeButton: UIButton = {
        let btn = UIButton(type: .system)
        let icon = UIImage(named: "volume")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.tag = 3
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handlePress(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        let icon = UIImage(named: "dismiss")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.tag = 4
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handlePress(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var menuButton: UIButton = {
        let btn = UIButton(type: .system)
        let icon = UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.tag = 6
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handlePress(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var shareButton: UIButton = {
        let btn = UIButton(type: .system)
        let icon = UIImage(named: "share")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.tag = 5
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handlePress(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var videoLenghtLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "00:00"
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var passedTimeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "00:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var errorlabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "Unknown error, please try again later."
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var timeSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .white
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(handleSliding(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var volumeSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x: self.frame.width - 65, y: 0, width: 90, height: 35))
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .lightGray
        let icon = UIImage(named: "sliderThumb")?.withRenderingMode(.alwaysTemplate)
        slider.setThumbImage(icon, for: .normal)
        slider.tintColor = .white
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        slider.setValue(Float(1.0), animated: false)
        lastVolumeSliderPosition = 1.0
        slider.addTarget(self, action: #selector(handleVolume(_:)), for: .valueChanged)
        return slider
    }()
    
    private var loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        return spinner
    }()
    
    private lazy var controlContainerView: UIView = {
        let view = UIView(frame: self.frame)
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public var videoLink: String = "" {
        didSet {
            if isPlaying { pauseVideo() }
            setupPlayer(with: videoLink)
        }
    }
    
    public var ownerViewController: UIViewController?
    public weak var delegate: UICVideoPlayerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        controlContainerView.addSubview(dismissButton)
        controlContainerView.addSubview(menuButton)
        controlContainerView.addSubview(shareButton)
        controlContainerView.addSubview(loadingSpinner)
        controlContainerView.addSubview(rewindButton)
        controlContainerView.addSubview(playPauseButton)
        controlContainerView.addSubview(forwardButton)
        controlContainerView.addSubview(volumeSlider)
        volumeSlider.center.y = self.center.y
        controlContainerView.addSubview(volumeButton)
        controlContainerView.addSubview(passedTimeLabel)
        controlContainerView.addSubview(timeSlider)
        controlContainerView.addSubview(videoLenghtLabel)
        controlContainerView.addSubview(errorlabel)
        
        addSubview(controlContainerView)
        
        
        NSLayoutConstraint.activate([
            
            loadingSpinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Control containrer view constraints
            controlContainerView.topAnchor.constraint(equalTo: topAnchor),
            controlContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            controlContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            controlContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            // Dismiss button constraints
            dismissButton.widthAnchor.constraint(equalToConstant: 20),
            dismissButton.heightAnchor.constraint(equalToConstant: 20),
            dismissButton.leadingAnchor.constraint(equalTo: controlContainerView.leadingAnchor, constant: 12),
            dismissButton.topAnchor.constraint(equalTo: controlContainerView.topAnchor, constant: 12),
            
            // Menu button constraints
            menuButton.widthAnchor.constraint(equalToConstant: 20),
            menuButton.heightAnchor.constraint(equalToConstant: 20),
            menuButton.trailingAnchor.constraint(equalTo: controlContainerView.trailingAnchor, constant: -12),
            menuButton.topAnchor.constraint(equalTo: controlContainerView.topAnchor, constant: 12),
            
            // Share button constraints
            shareButton.widthAnchor.constraint(equalToConstant: 20),
            shareButton.heightAnchor.constraint(equalToConstant: 20),
            shareButton.trailingAnchor.constraint(equalTo: menuButton.trailingAnchor, constant: -24),
            shareButton.topAnchor.constraint(equalTo: controlContainerView.topAnchor, constant: 12),
            
            // Rewind button constraints
            rewindButton.widthAnchor.constraint(equalToConstant: 35),
            rewindButton.heightAnchor.constraint(equalToConstant: 35),
            rewindButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -75),
            rewindButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Play pause button constraints
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40),
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Rewind button constraints
            forwardButton.widthAnchor.constraint(equalToConstant: 35),
            forwardButton.heightAnchor.constraint(equalToConstant: 35),
            forwardButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 75),
            forwardButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            
            // Volume button constraints
            volumeButton.widthAnchor.constraint(equalToConstant: 20),
            volumeButton.heightAnchor.constraint(equalToConstant: 20),
            volumeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            volumeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35),
            
            // Total time label
            passedTimeLabel.widthAnchor.constraint(equalToConstant: 45),
            passedTimeLabel.heightAnchor.constraint(equalToConstant: 25),
            passedTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            passedTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Total time label
            videoLenghtLabel.widthAnchor.constraint(equalToConstant: 45),
            videoLenghtLabel.heightAnchor.constraint(equalToConstant: 25),
            videoLenghtLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            videoLenghtLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Slider constraints
            timeSlider.leadingAnchor.constraint(equalTo: passedTimeLabel.trailingAnchor),
            timeSlider.trailingAnchor.constraint(equalTo: videoLenghtLabel.leadingAnchor),
            timeSlider.bottomAnchor.constraint(equalTo: bottomAnchor),
            timeSlider.heightAnchor.constraint(equalToConstant: 25),
            
            // Play pause button constraints
            errorlabel.widthAnchor.constraint(equalToConstant: 200),
            errorlabel.heightAnchor.constraint(equalToConstant: 70),
            errorlabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorlabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayer(with urlString: String) {

        if let url = URL(string: urlString) {
            // Create AVPlayer object
            let asset = AVAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
            
            // If there is a video layer thats mean user playing next video
            // So hide buttons, show loading spinner and show control view
            // Than remove old layer from view to add new layer.
            if playerLayer != nil {
                self.rewindButton.isHidden = true
                self.playPauseButton.isHidden = true
                self.forwardButton.isHidden = true
                self.loadingSpinner.startAnimating()
                self.handleTap()
                UIView.transition(with: self, duration: 1.0, options: .transitionCrossDissolve, animations: {
                    self.playerLayer?.removeFromSuperlayer()
                }) { (_) in
                    self.playerLayer = nil
                }
            }
            // Create AVPlayerLayer object
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = self.bounds
            playerLayer?.videoGravity = .resizeAspect
            playerLayer?.name = "VideoLayer"
            
            // Add playerLayer to view's layer
            self.layer.insertSublayer(playerLayer!, at: 0)
            
            // Add observer for tracking current time value
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: .main) {[weak self] (progressTime) in
                
                // Get passed time for video (minute & seconds)
                if let duration = self!.player?.currentItem?.duration {
                    let durationSeconds = CMTimeGetSeconds(duration)
                    let seconds = CMTimeGetSeconds(progressTime)
                    let progress = Float(seconds/durationSeconds)
                    
                    DispatchQueue.main.async {[weak self] in
                        self?.timeSlider.value = progress
                        let secondText = String(format: "%02d", Int(seconds) % 60)
                        let minuteText = String(format: "%02d", Int(seconds) / 60)
                        self?.passedTimeLabel.text = "\(minuteText):\(secondText)"
                        if progress >= 1.0 {
                            self?.timeSlider.value = 0.0
                            self?.passedTimeLabel.text = "00:00"
                        }
                    }
                }
            }
            
            // Add observer for tracking player buffering status
            player?.addObserver(self, forKeyPath: KeyPath.TimeControl.rawValue, options: [.old, .new], context: nil)
            
            // Add observer for tracking player time details
            player?.addObserver(self, forKeyPath: KeyPath.LoadedTimeRange.rawValue, options: [.old, .new], context: nil)
            
            // Add observer for tracking player load status
            playerItem?.addObserver(self, forKeyPath: KeyPath.Status.rawValue, options: [.old, .new], context: nil)
            
            // Add observer for tracking player playback ends
            NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            
            // Start playing video
            self.playVideo()
        }
    }
    
    // Mark: - Player & video status
    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        
        // Current video loading details (is started to play or not)
        if keyPath == KeyPath.TimeControl.rawValue, let change = change,
            let newValue = change[NSKeyValueChangeKey.newKey] as? Int,
            let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        
                        if self!.isFirstPlaying {
                            self?.isFirstPlaying = false
                            self?.controlContainerView.isHidden = true
                            self?.isControlContainerViewShowing = true
                        }
                        self?.rewindButton.isHidden = false
                        self?.playPauseButton.isHidden = false
                        self?.forwardButton.isHidden = false
                        self?.loadingSpinner.stopAnimating()
                    } else {
                        self?.rewindButton.isHidden = true
                        self?.playPauseButton.isHidden = true
                        self?.forwardButton.isHidden = true
                        self?.loadingSpinner.startAnimating()
                    }
                }
            }
        }
        
        // Current video time details (video lenght)
        if keyPath == KeyPath.LoadedTimeRange.rawValue {
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondText = String(format: "%02d", Int(seconds) % 60)
                let minuteText = String(format: "%02d", Int(seconds) / 60)
                DispatchQueue.main.async {[weak self] in
                    self?.videoLenghtLabel.text = "\(minuteText):\(secondText)"
                }
            }
        }
        
        // Player loading status (is failed or unknown or ready to play)
        if keyPath == KeyPath.Status.rawValue {
            guard let status = player?.currentItem?.status else { return }
            if status == .failed || status == .unknown {
                DispatchQueue.main.async {[weak self] in
                    self?.loadingSpinner.stopAnimating()
                    self?.controlContainerView.isHidden = false
                    self?.errorlabel.isHidden = false
                    self?.timeSlider.isEnabled = false
                }
            }
        }
    }
    
    // Mark: - Player options, functionalities
    
    private func playVideo() {
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        isPlaying = true
        player?.play()
    }
    
    private func pauseVideo() {
        playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        isPlaying = false
        player?.pause()
    }
    
    private func muteVideo() {
        let icon = isMuted ? UIImage(named: "volume") : UIImage(named: "mute")
        volumeButton.setImage(icon, for: .normal)
        isMuted ? volumeSlider.setValue(lastVolumeSliderPosition, animated: true) : volumeSlider.setValue(0, animated: true)
        isMuted = !isMuted
        player?.isMuted = isMuted
    }
    
    private func rewindVideo(by seconds: Float64) {
        if let currentTime = player?.currentTime() {
            var newTime = CMTimeGetSeconds(currentTime) - seconds
            if newTime <= 0 {
                newTime = 0
            }
            player?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    private func forwardVideo(by seconds: Float64) {
        if let currentTime = player?.currentTime(), let duration = player?.currentItem?.duration {
            var newTime = CMTimeGetSeconds(currentTime) + seconds
            if newTime >= CMTimeGetSeconds(duration) {
                newTime = CMTimeGetSeconds(duration)
            }
            player?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    @objc private func playerEndedPlaying(_ notification: Notification) {
        DispatchQueue.main.async {[weak self] in
            self!.player?.seek(to: CMTime.zero)
            self!.playPauseButton.setImage(UIImage(named: "replay"), for: .normal)
            self!.isPlaying = false
            self!.handleTap()
        }
    }
    
    private func shareVideoLink() {
        let message = "Shared from UICVideoPlayer"
        if let link = URL(string: videoLink) {
            let sharableObjects: [Any] = [message, link]
            let activityCOntroller = UIActivityViewController(activityItems: sharableObjects, applicationActivities: nil)
            ownerViewController?.present(activityCOntroller, animated: true, completion: nil)
        }
    }
    
    // Mark: - Action event handlers
    
    @objc private func handleTap() {
        self.isControlContainerViewShowing = !self.isControlContainerViewShowing
        UIView.transition(with: self.controlContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.controlContainerView.isHidden = self.isControlContainerViewShowing
        })
    }
    
    @objc private func handlePress(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            isPlaying ? pauseVideo() : playVideo(); break;
        case 1:
            forwardVideo(by: 3.0); break;
        case 2:
            rewindVideo(by: 3.0); break;
        case 3:
            muteVideo(); break;
        case 4:
            pauseVideo()
            delegate?.dismiss(self)
        case 5:
            shareVideoLink(); break;
        case 6:
            contextMenu = ContextMenu(frame: .zero)
            contextMenu.showContextMenu(); break;
        default: break;
        }
    }
    
    @objc private func handleSliding(_ slider: UISlider) {
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = totalSeconds * Float64(slider.value)
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime)
        }
    }
    
    @objc private func handleVolume(_ slider: UISlider) {
        player?.volume = slider.value
        lastVolumeSliderPosition = slider.value
    }
    
    // Mark: - Deinitialize dependencies & items
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player?.removeObserver(self, forKeyPath: KeyPath.TimeControl.rawValue)
        player?.removeObserver(self, forKeyPath: KeyPath.LoadedTimeRange.rawValue)
        playerItem?.removeObserver(self, forKeyPath: KeyPath.Status.rawValue)
    }
    
}
