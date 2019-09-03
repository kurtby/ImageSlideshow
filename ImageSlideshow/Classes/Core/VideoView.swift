//
//  VideoView.swift
//  ImageSlideshow
//
//  Created by Valentine Eyiubolu on 8/30/19.
//

import UIKit
import AVFoundation

extension UIView {
    func pinEdges(to other: UIView) {
        if #available(iOS 9.0, *) {
            leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
            topAnchor.constraint(equalTo: other.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
    }
}

public class VideoView: UIView {
    public let playImageView = UIImageView(image: nil)
    
    internal let playerView = UIView()
    internal let playerLayer = AVPlayerLayer()
    internal var previewImageView = UIImageView()
    
    public var player: AVPlayer {
        guard playerLayer.player != nil else {
            return AVPlayer()
        }
       // playImageView.image = YPConfig.icons.playImage
        return playerLayer.player!
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    internal func setup() {
        let singleTapGR = UITapGestureRecognizer(target: self,
                                                 action: #selector(singleTap))
        singleTapGR.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGR)
        
        // Loop playback
        addReachEndObserver()
        
        playerView.alpha = 0
        playImageView.alpha = 0.8
        playerLayer.videoGravity = .resizeAspect
        previewImageView.contentMode = .scaleAspectFit

        addSubview(previewImageView)
        addSubview(playerView)
        addSubview(playImageView)
        
        previewImageView.pinEdges(to: self)
        playerView.pinEdges(to: self)
        
        if #available(iOS 9.0, *) {
            playImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            playImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
   
        
        playerView.layer.addSublayer(playerLayer)
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = playerView.frame
    }
    
    @objc internal func singleTap() {
        pauseUnpause()
    }
    
    @objc public func playerItemDidReachEnd(_ note: Notification) {
        player.actionAtItemEnd = .none
        player.seek(to: CMTime.zero)
        player.play()
    }
    
}

// MARK: - Video handling
extension VideoView {
    /// The main load video method
    public func loadVideo<T>(_ item: T) {
        var player: AVPlayer
        
        switch item.self {
        case let url as URL:
            player = AVPlayer(url: url)
        case let playerItem as AVPlayerItem:
            player = AVPlayer(playerItem: playerItem)
            
        default:
            return
        }
        playerLayer.player = player
        playerView.alpha = 1
    }
    
    /// Convenience func to pause or unpause video dependely of state
    public func pauseUnpause() {
        (player.rate == 0.0) ? play() : pause()
    }
    
    /// Mute or unmute the video
    public func muteUnmute() {
        player.isMuted = !player.isMuted
    }
    
    public func play() {
        player.play()
        showPlayImage(show: false)
        addReachEndObserver()
    }
    
    public func pause() {
        player.pause()
        showPlayImage(show: true)
    }
    
    public func stop() {
        player.pause()
        player.seek(to: CMTime.zero)
        showPlayImage(show: true)
        removeReachEndObserver()
    }
    
    public func deallocate() {
        playerLayer.player = nil
        playImageView.image = nil
    }
}

// MARK: - Other API
extension VideoView {
    public func setPreviewImage(_ image: UIImage) {
        previewImageView.image = image
    }
    
    /// Shows or hide the play image over the view.
    public func showPlayImage(show: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.playImageView.alpha = show ? 0.8 : 0
        }
    }
    
    public func addReachEndObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(newErrorLogEntry(_:)), name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        center.addObserver(self, selector: #selector(failedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
    }
    
    
    @objc func newErrorLogEntry(_ notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else {
            return
        }
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else {
            return
        }
        print("Error: \(errorLog)")
    }
    
    @objc func failedToPlayToEndTime(_ notification: Notification) {
        let error = notification.userInfo!["AVPlayerItemFailedToPlayToEndTimeErrorKey"]
        print("Error: failedToPlayToEndTime", error)
    }
    
    
    /// Removes the observer for AVPlayerItemDidPlayToEndTime. Could be needed to implement own observer
    public func removeReachEndObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: nil)
    }
    
}
