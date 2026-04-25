//
//  CarPlayPlayerView.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 04/03/2026.
//

import Foundation
import AVFoundation
import MediaPlayer
import CarPlay

protocol CarPlayPlayerViewDelegate: AnyObject {
    func carPlayPlayerDidPlay()
    func carPlayPlayerDidPause()
    func carPlayPlayerDidChangeDuration(_ duration: Int)
    func carPlayPlayerDidFinishPlaying()
    func carPlayPlayerDidCancelWithError(_ error: Error?)
}

class CarPlayPlayerView: NSObject, IPlayerProtocolDelegate {
    
    weak var delegate: CarPlayPlayerViewDelegate?
    
    // Player properties
    private var isPaused = false
    var startAutomatically = false
    private var desiredStartDuration: Float = 0.0
    private var timeObserver: Any?
    private var playingItem: AVPlayerItem?
    private var playerUrl: URL?
    
    // Media info
    private var currentTitle: String = ""
    private var currentSubTitle: String = ""
    
    // Notification observers
    private var observers: [NSObjectProtocol] = []
    
    // Player reference
    private var player: IPlayerProtocol! {
        get {
            var playerInstance = BTPlayerManager.sharedManager.player!
            playerInstance.delegate = self
            return playerInstance
        }
    }
    
    var isPlaying: Bool {
        return player.isPlaying()
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupNotifications()
        setupPlayerStateSync()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Setup
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(itemDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        // Listen for phone app player updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(phonePlayerDidUpdate(_:)),
            name: NSNotification.Name("BTPlayerViewDidUpdateState"),
            object: nil
        )
    }
    
    private func setupPlayerStateSync() {
        // Setup timer to sync with phone player state
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.syncWithPhonePlayer()
        }
    }
    
    // MARK: - Public Interface
    
    func setTitle(_ title: String) {
        currentTitle = title
        player.setTitle(title)
        updateNowPlayingInfo()
    }
    
    func setSubTitle(_ subTitle: String) {
        currentSubTitle = subTitle
        player.setSubTitle(subTitle)
        updateNowPlayingInfo()
    }
    
    func setPlayerUrl(_ url: URL?, duration: Int = 0) {
        if duration > 0 {
            desiredStartDuration = Float(duration)
        }
        
        playerUrl = url
        loadSelectedURL()
    }
    
    // Pending lesson (displayed but not yet loaded into player)
    private var pendingLessonUrl: URL?
    private var pendingLessonDuration: Int = 0
    
    func setPendingLesson(title: String, subTitle: String, url: URL, duration: Int) {
        currentTitle = title
        currentSubTitle = subTitle
        pendingLessonUrl = url
        pendingLessonDuration = duration
        
        var playingInfo: [String: Any] = [
            MPMediaItemPropertyArtist: title,
            MPMediaItemPropertyTitle: subTitle,
            MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 0.0),
            MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: duration)
        ]
        if let image = UIImage(named: "Icon-App-60x60@3x.png") {
            let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300)) { _ in image }
            playingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
    }
    
    func play() {
        // If there's a pending lesson (displayed but not loaded), load it now
        if let pendingUrl = pendingLessonUrl {
            pendingLessonUrl = nil
            startAutomatically = true
            setPlayerUrl(pendingUrl, duration: pendingLessonDuration)
            pendingLessonDuration = 0
            return
        }
        
        guard playerUrl != nil else { return }
        
        if playingItem == nil && playerUrl != nil {
            playingItem = AVPlayerItem(url: playerUrl!)
        }
        
        guard playingItem != nil else { return }
        
        player.play()
        updateNowPlayingInfo()
        notifyPhonePlayerOfStateChange(isPlaying: true)
        delegate?.carPlayPlayerDidPlay()
    }
    
    func pause() {
        player.pause()
        isPaused = true
        updateNowPlayingInfo()
        notifyPhonePlayerOfStateChange(isPlaying: false)
        delegate?.carPlayPlayerDidPause()
    }
    
    func jumpForward() {
        let jumpDuration = Float(UserDefaults.standard.object(forKey: "selectedLessonSkipInterval") as? String ?? "30") ?? 30
        let currentTime = getCurrentTime()
        let newDuration = min(currentTime + jumpDuration, getMaxDuration())
        setDuration(Int(newDuration))
    }
    
    func jumpBackward() {
        let jumpDuration = Float(UserDefaults.standard.object(forKey: "selectedLessonSkipInterval") as? String ?? "30") ?? 30
        let currentTime = getCurrentTime()
        let newDuration = max(currentTime - jumpDuration, 0)
        setDuration(Int(newDuration))
    }
    
    func changePlaybackRate() {
        let currentRate = player.rate()
        let rates: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
        
        if let currentIndex = rates.firstIndex(of: currentRate) {
            let nextIndex = (currentIndex + 1) % rates.count
            let newRate = rates[nextIndex]
            player.setRate(newRate)
            
            // Save the new rate
            UserDefaults.standard.set(newRate, forKey: "lessonPlayerRateSpeed")
            UserDefaults.standard.synchronize()
            
            // Update CarPlay UI
            updatePlaybackRateDisplay(rate: newRate)
        }
    }
    
    func setDuration(_ duration: Int) {
        guard player != nil else {
            desiredStartDuration = Float(duration)
            return
        }
        
        if player.isActive() {
            moveToDesiredStartDuration(Float(duration))
            return
        }
        
        if let playerDuration = player.duration() {
            let timeScale = playerDuration.timescale
            let time = CMTimeMakeWithSeconds(Double(duration), preferredTimescale: timeScale)
            
            if isPaused {
                player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in }
            } else {
                player.pause()
                player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in }
            }
        }
        
        updateNowPlayingProgress(currentTime: TimeInterval(duration))
        notifyPhonePlayerOfDurationChange(duration: duration)
        delegate?.carPlayPlayerDidChangeDuration(duration)
    }
    
    // MARK: - Private Methods
    
    private func loadSelectedURL() {
        // Notify BTPlayerView to remove its time observer before we touch the shared player
        NotificationCenter.default.post(
            name: NSNotification.Name("CarPlayWillLoadNewURL"),
            object: nil
        )
        
        if player != nil {
            if let timeObserver = timeObserver {
                player.removeTimeObserver(observer: timeObserver)
                self.timeObserver = nil
            }
            player.pause()
            isPaused = false
        }
        
        guard playerUrl != nil else {
            setLessonNotFoundLayout()
            return
        }
        
        updatePlayer()
        setupPlayerNotifications()
    }
    
    private func updatePlayer() {
        guard let playerUrl = playerUrl else { return }
        
        playingItem = AVPlayerItem(url: playerUrl)
        player.setPlayerItemPath(itemPathUrl: playerUrl)
    }
    
    private func setupPlayerNotifications() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(itemDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    private func getCurrentTime() -> Float {
        guard player != nil && player.isActive() else { return 0 }
        return Float(Double(player.currentTime().value) / Double(player.currentTime().timescale))
    }
    
    private func getMaxDuration() -> Float {
        guard let duration = player.duration() else { return 0 }
        return Float(CMTimeGetSeconds(duration))
    }
    
    private func moveToDesiredStartDuration(_ duration: Float) {
        desiredStartDuration = duration
        
        guard player.status() == "ReadyToPlay" && desiredStartDuration > 0.0 else { return }
        guard let playerDuration = player.duration() else { return }
        
        let timeScale = playerDuration.timescale
        let time = CMTimeMakeWithSeconds(Double(desiredStartDuration), preferredTimescale: timeScale)
        
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { [weak self] _ in
            self?.updateNowPlayingProgress(currentTime: TimeInterval(duration))
            self?.desiredStartDuration = 0.0
        }
    }
    
    private func setLessonNotFoundLayout() {
        playingItem = nil
        delegate?.carPlayPlayerDidCancelWithError(nil)
    }
    
    private func updateNowPlayingInfo() {
        var playingInfo: [String: Any] = [
            MPMediaItemPropertyArtist: currentTitle,
            MPMediaItemPropertyTitle: currentSubTitle,
            MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: player.rate())
        ]
        
        if let duration = player.duration() {
            playingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: CMTimeGetSeconds(duration))
        }
        
        if let image = UIImage(named: "Icon-App-60x60@3x.png") {
            let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300)) { _ in image }
            playingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        // Add current playback position
        let currentTime = getCurrentTime()
        playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: currentTime)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
    }
    
    private func updateNowPlayingProgress(currentTime: TimeInterval) {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updatePlaybackRateDisplay(rate: Float) {
        // Update the CarPlay UI to show the current playback rate
        // This could be done through a custom button or by updating now playing info
        updateNowPlayingInfo()
    }
    
    // MARK: - Synchronization with Phone Player
    
    private func syncWithPhonePlayer() {
        // This method runs periodically to sync state with the phone player
        // You might want to check for state changes and update accordingly
    }
    
    private func notifyPhonePlayerOfStateChange(isPlaying: Bool) {
        DispatchQueue.main.async {
            let userInfo: [String: Any] = [
                "isPlaying": isPlaying,
                "source": "CarPlay"
            ]
            NotificationCenter.default.post(
                name: NSNotification.Name("CarPlayPlayerDidUpdateState"),
                object: self,
                userInfo: userInfo
            )
        }
    }
    
    private func notifyPhonePlayerOfDurationChange(duration: Int) {
        DispatchQueue.main.async {
            let userInfo: [String: Any] = [
                "duration": duration,
                "source": "CarPlay"
            ]
            NotificationCenter.default.post(
                name: NSNotification.Name("CarPlayPlayerDidChangeDuration"),
                object: self,
                userInfo: userInfo
            )
        }
    }
    
    @objc private func phonePlayerDidUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let source = userInfo["source"] as? String,
              source != "CarPlay" else { return }
        
        // Sync with phone player changes
        if let isPlaying = userInfo["isPlaying"] as? Bool {
            if isPlaying && !self.isPlaying {
                // Phone started playing - update our state without calling play()
                // since the shared player is already playing
                updateNowPlayingInfo()
            } else if !isPlaying && self.isPlaying {
                updateNowPlayingInfo()
            }
        }
        
        if let title = userInfo["title"] as? String {
            currentTitle = title
        }
        
        if let subTitle = userInfo["subTitle"] as? String {
            currentSubTitle = subTitle
        }
        
        if let url = userInfo["url"] as? URL {
            // Don't reload the URL - the phone's BTPlayerView already loaded it
            // into the shared player. Just track the URL and update display.
            playerUrl = url
            pendingLessonUrl = nil
            pendingLessonDuration = 0
            
            // Re-add our time observer since the phone created a new AVPlayer
            self.timeObserver = nil
            addPeriodicTimeObserver()
        }
        
        // Update CarPlay now playing display
        updateNowPlayingInfo()
    }
    
    // MARK: - Notification Handlers
    
    @objc private func itemDidFinishPlaying() {
        guard let duration = player.duration() else { return }
        
        let timeScale = duration.timescale
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: timeScale)
        
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { [weak self] _ in
            self?.desiredStartDuration = 0.0
        }
        
        isPaused = true
        notifyPhonePlayerOfStateChange(isPlaying: false)
        delegate?.carPlayPlayerDidFinishPlaying()
    }
    
    // MARK: - IPlayerProtocolDelegate
    
    func playerIsReadyToPlay(player: IPlayerProtocol) {
        guard let duration = self.player.duration() else {
            setLessonNotFoundLayout()
            return
        }
        
        let seconds = CMTimeGetSeconds(duration)
        if seconds > 0 {
            moveToDesiredStartDuration(desiredStartDuration)
            addPeriodicTimeObserver()
            updateNowPlayingInfo()
            
            if startAutomatically {
                play()
            }
        } else {
            setLessonNotFoundLayout()
        }
    }
    
    func playerDidStop(player: IPlayerProtocol) {
        isPaused = true
        notifyPhonePlayerOfStateChange(isPlaying: false)
        delegate?.carPlayPlayerDidPause()
    }
    
    func playerDidPlay(player: IPlayerProtocol) {
        notifyPhonePlayerOfStateChange(isPlaying: true)
        delegate?.carPlayPlayerDidPlay()
    }
    
    func playerFailed(player: IPlayerProtocol) {
        setLessonNotFoundLayout()
    }
    
    func playerDidUpdateInfo(player: IPlayerProtocol) {
        updateNowPlayingInfo()
    }
    
    // MARK: - Time Observer
    
    private func addPeriodicTimeObserver() {
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] time in
            guard let self = self, self.player.isActive() else { return }
            guard let duration = self.player.duration() else { return }
            
            let seconds = CMTimeGetSeconds(duration)
            let currentTime = self.getCurrentTime()
            
            self.updateNowPlayingProgress(currentTime: TimeInterval(currentTime))
            self.notifyPhonePlayerOfDurationChange(duration: Int(currentTime))
        }
    }
    
    // MARK: - Cleanup
    
    private func cleanup() {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(observer: timeObserver)
            self.timeObserver = nil
        }
        
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - CarPlay Integration Extensions

extension CarPlayPlayerView {
    
    func getCurrentPlaybackPosition() -> TimeInterval {
        return TimeInterval(getCurrentTime())
    }
    
    func getTotalDuration() -> TimeInterval {
        guard let duration = player.duration() else { return 0 }
        return CMTimeGetSeconds(duration)
    }
    
    func getFormattedCurrentTime() -> String {
        let currentTime = Int(getCurrentTime())
        return timeDisplayForSeconds(seconds: currentTime)
    }
    
    func getFormattedTotalDuration() -> String {
        let totalDuration = Int(getTotalDuration())
        return timeDisplayForSeconds(seconds: totalDuration)
    }
    
    private func timeDisplayForSeconds(seconds: Int) -> String {
        let mins = seconds / 60
        let sec = seconds % 60
        
        let minsDisplay = mins > 9 ? "\(mins)" : "0\(mins)"
        let secDisplay = sec > 9 ? "\(sec)" : "0\(sec)"
        
        return "\(minsDisplay):\(secDisplay)"
    }
}