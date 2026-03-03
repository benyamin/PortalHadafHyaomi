//
//  CarPlayAudioManager.swift
//  PortalHadafHayomi
//
//  Created by System on 03/03/2026.
//  Copyright © 2026 Binyamin Trachtman. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation
import CarPlay

class CarPlayAudioManager: NSObject {
    
    static let shared = CarPlayAudioManager()
    
    private var currentLesson: Lesson?
    private var audioPlayer: AVPlayer?
    
    override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Remote Command Center Setup
    
    private func setupRemoteCommandCenter() {
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
        
        // Next track command
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNextLesson()
            return .success
        }
        
        // Previous track command
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPreviousLesson()
            return .success
        }
        
        // Skip forward command
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: 15)]
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            if let skipEvent = event as? MPSkipIntervalCommandEvent {
                self?.skipForward(seconds: skipEvent.interval)
            }
            return .success
        }
        
        // Skip backward command
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: 15)]
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            if let skipEvent = event as? MPSkipIntervalCommandEvent {
                self?.skipBackward(seconds: skipEvent.interval)
            }
            return .success
        }
        
        // Seek command
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let seekEvent = event as? MPChangePlaybackPositionCommandEvent {
                self?.seek(to: seekEvent.positionTime)
            }
            return .success
        }
    }
    
    // MARK: - Playback Control
    
    func playLesson(_ lesson: Lesson) {
        self.currentLesson = lesson
        
        guard let url = lesson.getUrl() else {
            print("Could not get URL for lesson")
            return
        }
        
        // Create and configure audio player
        audioPlayer = AVPlayer(url: url)
        
        // Set up playback tracking
        setupPlaybackTracking()
        
        // Update now playing info
        updateNowPlayingInfo()
        
        // Start playback
        audioPlayer?.play()
        
        // Update LessonsManager
        LessonsManager.sharedManager.playingLesson = lesson
        LessonsManager.sharedManager.isPlaying = true
    }
    
    private func play() {
        audioPlayer?.play()
        LessonsManager.sharedManager.isPlaying = true
        updateNowPlayingInfo()
    }
    
    private func pause() {
        audioPlayer?.pause()
        LessonsManager.sharedManager.isPlaying = false
        updateNowPlayingInfo()
    }
    
    private func stop() {
        audioPlayer?.pause()
        audioPlayer = nil
        LessonsManager.sharedManager.isPlaying = false
        LessonsManager.sharedManager.playingLesson = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    // MARK: - Navigation
    
    private func playNextLesson() {
        guard let currentLesson = currentLesson,
              let nextLesson = getNextLesson(from: currentLesson) else {
            return
        }
        
        playLesson(nextLesson)
    }
    
    private func playPreviousLesson() {
        guard let currentLesson = currentLesson,
              let previousLesson = getPreviousLesson(from: currentLesson) else {
            return
        }
        
        playLesson(previousLesson)
    }
    
    private func getNextLesson(from lesson: Lesson) -> Lesson? {
        guard let masechet = lesson.masechet,
              let currentPage = lesson.page,
              let maggidShiur = lesson.maggidShiur else {
            return nil
        }
        
        let currentPageIndex = currentPage.index ?? 0
        
        // Try next page in same masechet
        if currentPageIndex < masechet.pages.count {
            let nextPage = masechet.pages[currentPageIndex] // currentPageIndex is 0-based, pages array is 0-based
            return Lesson(maschet: masechet, page: nextPage, andMaggidShiur: maggidShiur)
        }
        
        // Try first page of next masechet
        if let currentMasechetIndex = HadafHayomiManager.sharedManager.masechtot.firstIndex(where: { $0.id == masechet.id }),
           currentMasechetIndex + 1 < HadafHayomiManager.sharedManager.masechtot.count {
            let nextMasechet = HadafHayomiManager.sharedManager.masechtot[currentMasechetIndex + 1]
            if let firstPage = nextMasechet.pages.first {
                return Lesson(maschet: nextMasechet, page: firstPage, andMaggidShiur: maggidShiur)
            }
        }
        
        return nil
    }
    
    private func getPreviousLesson(from lesson: Lesson) -> Lesson? {
        guard let masechet = lesson.masechet,
              let currentPage = lesson.page,
              let maggidShiur = lesson.maggidShiur else {
            return nil
        }
        
        let currentPageIndex = currentPage.index ?? 0
        
        // Try previous page in same masechet
        if currentPageIndex > 1 {
            let previousPage = masechet.pages[currentPageIndex - 2] // Adjust for 0-based indexing
            return Lesson(maschet: masechet, page: previousPage, andMaggidShiur: maggidShiur)
        }
        
        // Try last page of previous masechet
        if let currentMasechetIndex = HadafHayomiManager.sharedManager.masechtot.firstIndex(where: { $0.id == masechet.id }),
           currentMasechetIndex > 0 {
            let previousMasechet = HadafHayomiManager.sharedManager.masechtot[currentMasechetIndex - 1]
            if let lastPage = previousMasechet.pages.last {
                return Lesson(maschet: previousMasechet, page: lastPage, andMaggidShiur: maggidShiur)
            }
        }
        
        return nil
    }
    
    // MARK: - Seek Operations
    
    private func skipForward(seconds: TimeInterval) {
        guard let player = audioPlayer else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(seconds, preferredTimescale: 1))
        player.seek(to: newTime)
        updateNowPlayingInfo()
    }
    
    private func skipBackward(seconds: TimeInterval) {
        guard let player = audioPlayer else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeSubtract(currentTime, CMTimeMakeWithSeconds(seconds, preferredTimescale: 1))
        let zeroTime = CMTimeMakeWithSeconds(0, preferredTimescale: 1)
        player.seek(to: CMTimeMaximum(newTime, zeroTime))
        updateNowPlayingInfo()
    }
    
    private func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        let seekTime = CMTimeMakeWithSeconds(time, preferredTimescale: 1)
        player.seek(to: seekTime)
        updateNowPlayingInfo()
    }
    
    // MARK: - Now Playing Info
    
    private func updateNowPlayingInfo() {
        guard let lesson = currentLesson,
              let player = audioPlayer else {
            return
        }
        
        var nowPlayingInfo: [String: Any] = [:]
        
        // Basic metadata
        nowPlayingInfo[MPMediaItemPropertyTitle] = "\(lesson.masechet?.name ?? "") - \(lesson.page?.symbol ?? "")"
        nowPlayingInfo[MPMediaItemPropertyArtist] = lesson.maggidShiur?.name ?? ""
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "דף היומי"
        
        // Playback info
        if let duration = player.currentItem?.duration, !duration.isIndefinite {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration)
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        // Artwork
        if let artwork = createLessonArtwork(for: lesson) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func createLessonArtwork(for lesson: Lesson) -> MPMediaItemArtwork? {
        let image = UIImage(systemName: "book.fill") ?? UIImage()
        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }
    
    // MARK: - Playback Tracking
    
    private func setupPlaybackTracking() {
        guard let player = audioPlayer else { return }
        
        // Add periodic time observer
        let interval = CMTimeMakeWithSeconds(1.0, preferredTimescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            self?.updateNowPlayingInfo()
        }
        
        // Add end of playback observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    @objc private func playerDidFinishPlaying() {
        // Auto-play next lesson if available
        if let nextLesson = currentLesson.flatMap(getNextLesson) {
            playLesson(nextLesson)
        } else {
            stop()
        }
    }
    
    // MARK: - Public Interface
    
    var isPlaying: Bool {
        return audioPlayer?.rate != 0
    }
    
    func getCurrentLesson() -> Lesson? {
        return currentLesson
    }
}