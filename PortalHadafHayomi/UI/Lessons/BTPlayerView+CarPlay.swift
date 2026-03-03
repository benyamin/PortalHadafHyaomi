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
import ObjectiveC

extension BTPlayerView {
    
    // MARK: - Associated Object Keys
    private struct AssociatedKeys {
        static var onSkipForward = "onSkipForward"
        static var onSkipBackward = "onSkipBackward"
        static var carPlaySetupDone = "carPlaySetupDone"
    }
    
    // MARK: - Associated Properties
    var onSkipForward: ((TimeInterval) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onSkipForward) as? (TimeInterval) -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onSkipForward, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var onSkipBackward: ((TimeInterval) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onSkipBackward) as? (TimeInterval) -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onSkipBackward, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var carPlaySetupDone: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.carPlaySetupDone) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.carPlaySetupDone, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - CarPlay Integration Methods
    
    /// Sets up CarPlay remote command handling
    func setupCarPlayRemoteCommands() {
        // Prevent multiple setups
        guard !carPlaySetupDone else { return }
        carPlaySetupDone = true
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        // Pause command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        // Stop command
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.removeTarget(nil)
        commandCenter.stopCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        // Next/Previous track commands
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.removeTarget(nil)
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.onNextButtonClicked?()
            return .success
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.removeTarget(nil)
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.onPreButtonClicked?()
            return .success
        }
        
        // Skip commands
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: 15)]
        commandCenter.skipForwardCommand.removeTarget(nil)
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            if let skipEvent = event as? MPSkipIntervalCommandEvent {
                self?.handleSkipForward(seconds: skipEvent.interval)
            }
            return .success
        }
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: 15)]
        commandCenter.skipBackwardCommand.removeTarget(nil)
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            if let skipEvent = event as? MPSkipIntervalCommandEvent {
                self?.handleSkipBackward(seconds: skipEvent.interval)
            }
            return .success
        }
        
        // Seek command
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.removeTarget(nil)
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let seekEvent = event as? MPChangePlaybackPositionCommandEvent {
                self?.seekToTime(seekEvent.positionTime)
            }
            return .success
        }
    }
    
    /// Gets current playback time in seconds
    func getCurrentTime() -> TimeInterval {
        return TimeInterval(self.timeNow())
    }
    
    /// Seeks to specific time
    func seekToTime(_ time: TimeInterval) {
        // Use the existing player's seek functionality with CMTime
        if let player = self.player, player.isActive(), let duration = player.duration() {
            let timeScale = duration.timescale
            let seekTime = CMTimeMakeWithSeconds(time, preferredTimescale: timeScale)
            player.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in
                // Seek completed
            }
        }
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
            if let duration = parseDurationFromDisplay(durationDisplay) {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            }
        }
        
        // Current playback position
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = getCurrentTime()
        
        // Playback rate
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.isPlaying ? 1.0 : 0.0
        
        // Artwork
        if let artwork = createCarPlayArtwork(for: lesson) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Private Helper Methods
    
    private func handleSkipForward(seconds: TimeInterval) {
        if let onSkipForward = self.onSkipForward {
            onSkipForward(seconds)
        } else {
            // Default skip forward implementation
            let currentTime = getCurrentTime()
            let newTime = currentTime + seconds
            seekToTime(newTime)
        }
    }
    
    private func handleSkipBackward(seconds: TimeInterval) {
        if let onSkipBackward = self.onSkipBackward {
            onSkipBackward(seconds)
        } else {
            // Default skip backward implementation
            let currentTime = getCurrentTime()
            let newTime = max(0, currentTime - seconds)
            seekToTime(newTime)
        }
    }
    
    /// Creates artwork for CarPlay display
    private func createCarPlayArtwork(for lesson: Lesson) -> MPMediaItemArtwork? {
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
}