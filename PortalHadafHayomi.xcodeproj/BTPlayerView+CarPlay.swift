//
//  BTPlayerView+CarPlay.swift
//  PortalHadafHayomi
//
//  Created by System on 03/03/2026.
//  Copyright © 2026 Binyamin Trachtman. All rights reserved.
//

import Foundation
import CarPlay
import MediaPlayer

extension BTPlayerView {
    
    /// Sets up CarPlay integration for the player
    func setupCarPlayIntegration() {
        // This method can be called to ensure CarPlay is ready
        CarPlayAudioManager.shared.setupAudioSession()
    }
    
    /// Updates CarPlay now playing info when lesson changes
    func updateCarPlayNowPlayingInfo(for lesson: Lesson?) {
        guard let lesson = lesson else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        
        var nowPlayingInfo: [String: Any] = [:]
        
        // Basic metadata
        let title = "\(lesson.masechet?.name ?? "") - \(lesson.page?.symbol ?? "")"
        let artist = lesson.maggidShiur?.name ?? ""
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "דף היומי"
        
        // Duration info
        if let durationDisplay = lesson.durationDisplay {
            // Try to parse duration from display string
            if let duration = parseDurationFromDisplay(durationDisplay) {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            }
        }
        
        // Current playback position
        if let currentTime = getCurrentPlaybackTime() {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        }
        
        // Playback rate
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying() ? 1.0 : 0.0
        
        // Artwork
        if let artwork = createCarPlayArtwork(for: lesson) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    /// Creates artwork for CarPlay display
    private func createCarPlayArtwork(for lesson: Lesson) -> MPMediaItemArtwork? {
        // Create a simple artwork with lesson info
        let size = CGSize(width: 300, height: 300)
        let image = createLessonArtworkImage(for: lesson, size: size)
        
        return MPMediaItemArtwork(boundsSize: size) { _ in image }
    }
    
    /// Creates an image for lesson artwork
    private func createLessonArtworkImage(for lesson: Lesson, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // Background
        UIColor(red: 0.47, green: 0.12, blue: 0.14, alpha: 1.0).setFill() // Your app's color theme
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // Text setup
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.white,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
        
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.lightGray,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
        
        // Draw text
        let masechetName = lesson.masechet?.name ?? ""
        let pageSymbol = lesson.page?.symbol ?? ""
        let title = "\(masechetName)\n\(pageSymbol)"
        let subtitle = lesson.maggidShiur?.name ?? ""
        
        let titleRect = CGRect(x: 20, y: size.height * 0.3, width: size.width - 40, height: 80)
        let subtitleRect = CGRect(x: 20, y: size.height * 0.6, width: size.width - 40, height: 40)
        
        title.draw(in: titleRect, withAttributes: titleAttributes)
        subtitle.draw(in: subtitleRect, withAttributes: subtitleAttributes)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    /// Parses duration from display string
    private func parseDurationFromDisplay(_ durationDisplay: String) -> TimeInterval? {
        // Expected format: "MM:SS" or "HH:MM:SS"
        let components = durationDisplay.components(separatedBy: ":")
        
        if components.count == 2 {
            // MM:SS format
            guard let minutes = Double(components[0]),
                  let seconds = Double(components[1]) else {
                return nil
            }
            return minutes * 60 + seconds
        } else if components.count == 3 {
            // HH:MM:SS format
            guard let hours = Double(components[0]),
                  let minutes = Double(components[1]),
                  let seconds = Double(components[2]) else {
                return nil
            }
            return hours * 3600 + minutes * 60 + seconds
        }
        
        return nil
    }
    
    /// Gets current playback time - implement based on your player implementation
    private func getCurrentPlaybackTime() -> TimeInterval? {
        // This should return the current playback position
        // You'll need to implement this based on your existing audio player
        // For now, return nil as placeholder
        return nil
    }
    
    /// Checks if currently playing - implement based on your player implementation
    private func isPlaying() -> Bool {
        // This should return whether the player is currently playing
        // You'll need to implement this based on your existing audio player
        return LessonsManager.sharedManager.isPlaying
    }
}

// MARK: - CarPlay Remote Commands Integration

extension BTPlayerView {
    
    /// Sets up remote command handling for CarPlay
    func setupCarPlayRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        // Pause command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        // Stop command
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget { [weak self] _ in
            self?.stop()
            return .success
        }
        
        // Next/Previous track commands
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.onNextButtonClicked?()
            return .success
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.onPreButtonClicked?()
            return .success
        }
        
        // Skip commands
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: 15)]
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            if let skipEvent = event as? MPSkipIntervalCommandEvent {
                self?.skipForward(seconds: skipEvent.interval)
            }
            return .success
        }
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: 15)]
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            if let skipEvent = event as? MPSkipIntervalCommandEvent {
                self?.skipBackward(seconds: skipEvent.interval)
            }
            return .success
        }
    }
    
    private func skipForward(seconds: TimeInterval) {
        // Implement skip forward functionality
        // You'll need to adapt this to your existing player implementation
        if let onSkipForward = self.onSkipForward {
            onSkipForward(seconds)
        }
    }
    
    private func skipBackward(seconds: TimeInterval) {
        // Implement skip backward functionality
        // You'll need to adapt this to your existing player implementation
        if let onSkipBackward = self.onSkipBackward {
            onSkipBackward(seconds)
        }
    }
}

// MARK: - Additional Properties for Skip Functionality

extension BTPlayerView {
    
    private static var onSkipForwardKey: UInt8 = 0
    private static var onSkipBackwardKey: UInt8 = 0
    
    var onSkipForward: ((TimeInterval) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &BTPlayerView.onSkipForwardKey) as? (TimeInterval) -> Void
        }
        set {
            objc_setAssociatedObject(self, &BTPlayerView.onSkipForwardKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var onSkipBackward: ((TimeInterval) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &BTPlayerView.onSkipBackwardKey) as? (TimeInterval) -> Void
        }
        set {
            objc_setAssociatedObject(self, &BTPlayerView.onSkipBackwardKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}