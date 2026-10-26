//
//  BTAVPlayer.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 08/09/2016.
//
//

import Foundation

import AVFoundation
import AVKit
import MediaPlayer

class BTAVPlayer:NSObject, IPlayerProtocol, AVPlayerViewControllerDelegate
{
    var observerContext = 0
    
    var playerRate = Float(1.0)
    
    var currentPlayerItemPath:String?
    
    var BTTitle:String?
    var BTSubTitle:String?
    
    var playerDelegate:IPlayerProtocolDelegate!
    
    var delegate: IPlayerProtocolDelegate {
        get{
            return self.playerDelegate
        }
        set{
            self.playerDelegate = newValue
        }
    }
    
    private var observedItem:AVPlayerItem?
    private var didSetupCommandCenter = false
    /// time observer token -> the AVPlayer that created it (an observer must be removed from that same player)
    private var timeObserverOwners = [(token:AnyObject, player:AVPlayer)]()
    
    var a_player:AVPlayer!
    var player:AVPlayer!{
        
        get{
            if a_player == nil{
                a_player = AVPlayer()
                
                do {
                    // .allowBluetooth is only for record categories; with .playback it is not valid
                    // (Bluetooth headphones work with .playback anyway)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
              
                    print("Playback OK")
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("Session is Active")
                    
                } catch {
                    print(error)
                }
                
                return a_player
            }
            
            return a_player
        }
        set
        {
            a_player = newValue
        }
    }
    
    
    func setup()
    {
        // FIX: was listening to "keyboard will change frame" by mistake, and added an extra
        // lock-screen "play" handler that did nothing (and returned "failed" while playing).
        if let playerRateSpeed =  UserDefaults.standard.object(forKey: "lessonPlayerRateSpeed") as? Float {
            self.setRate(playerRateSpeed)
        }
    }
    
    func play()
    {
        if self.currentItemType() == "Video"
        {
            self.playVideo()
        }
        else
        {
            // self.player.play()
            self.activatePlaybackAudioSession()
            self.player.playImmediately(atRate: self.playerRate)
            self.player.rate = self.playerRate
            
        }
        
        self.updateNowPlayingInfo()
    }
    
    /// When paused, the voice commands listener may switch the audio session to "playAndRecord".
    /// In that mode iOS uses a different (call) volume and route, so after resuming the lesson
    /// the volume changed. Switch back to normal playback before every play.
    func activatePlaybackAudioSession()
    {
        let session = AVAudioSession.sharedInstance()
        do {
            if session.category != .playback || session.mode != .default {
                try session.setCategory(.playback, mode: .default, options: [])
            }
            try session.setActive(true)
        } catch {
            print("activatePlaybackAudioSession error: \(error)")
        }
    }
    
    func playVideo(){
        
        let moviePlayer = AVPlayerViewController()
        
        moviePlayer.delegate = self
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController
        {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(moviePlayer, animated: true) {
                
                moviePlayer.player = self.player
                
                // Add subtitles
                moviePlayer.addSubtitles()
                
                if let subtitlePath = self.currentPlayerItemPath?.replacingOccurrences(of: "mp4", with: "srt"){
                    let subtitleRemoteUrl = URL(string:subtitlePath)
                    moviePlayer.open(fileFromRemote: subtitleRemoteUrl!)
                    
                }
                moviePlayer.player!.playImmediately(atRate: 1.0)
            }
        }
    }
    
 
    func currentItemType() -> String
    {
        if let playerItemPath = self.currentPlayerItemPath {
            if playerItemPath.hasSuffix("mp4")
            {
                return "Video"
            }
            else if playerItemPath.hasSuffix("wav")
            {
                return "Video"
            }
            else{
                return "Audio"
            }
        }
        else{
            return "Audio"
        }
    }
    
    func stop()
    {
        player.pause()
        
    }
    func pause()
    {
        player.pause()
    }
    
    func removeTimeObserver(observer: Any)
    {
        // FIX: remove from the player that created it (never from another AVPlayer)
        let token = observer as AnyObject
        if let index = self.timeObserverOwners.firstIndex(where: { $0.token === token }) {
            self.timeObserverOwners[index].player.removeTimeObserver(observer)
            self.timeObserverOwners.remove(at: index)
        }
    }
    
    func setPlayerItemPath(itemPathUrl:URL?)
    {
        if let itemPathUrl = itemPathUrl
        {
            self.currentPlayerItemPath = itemPathUrl.absoluteString
            
            let playerItem = AVPlayerItem(url: itemPathUrl)
            
            // FIX: remove the observer only from the item we observed (removing from an item
            // that has no observer crashes)
            if let observedItem = self.observedItem {
                observedItem.removeObserver(self, forKeyPath: "status", context: &observerContext)
                self.observedItem = nil
            }
            playerItem.addObserver(self, forKeyPath: "status", options: .new, context: &observerContext)
            self.observedItem = playerItem
            
            // FIX: keep the same AVPlayer. A new AVPlayer for every lesson broke the time
            // observers (progress stopped updating, and removing an observer of the old
            // player crashes) and lost the playback speed.
            self.player.replaceCurrentItem(with: playerItem)
            
            // FIX: register the lock-screen / CarPlay commands once. They were added again for
            // every lesson, so "skip 30" jumped 60, 90… and play/pause ran several times.
            if !self.didSetupCommandCenter {
                self.didSetupCommandCenter = true
                self.setupCommandCenter()
            }
        }
    }
    
    private func setupCommandCenter() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [30]
        commandCenter.skipForwardCommand.addTarget(handler: self.handleSkipForward)
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(handler: self.handleSkipForward)

        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [30]
        commandCenter.skipBackwardCommand.addTarget(handler: self.handleSkipBackward)

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(handler: self.handleSkipBackward)

        
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            self.play()
            self.playerDelegate?.playerDidPlay(player: self)
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            self.pause()
            self.playerDelegate?.playerDidStop(player: self)
            return .success
        }
        
    }
    
    func handleSkipForward(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let duration = player.currentItem?.duration.seconds,
              duration.isFinite else {
            return .commandFailed
        }

        let currentTime = player.currentTime().seconds
        let newTime = min(currentTime + 30, duration)
        let selectedTime = CMTime(seconds: newTime, preferredTimescale: 1000)

        player.seek(to: selectedTime)
        return .success
    }

    func handleSkipBackward(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let duration = player.currentItem?.duration.seconds,
              duration.isFinite else {
            return .commandFailed
        }

        let currentTime = player.currentTime().seconds
        let newTime = max(currentTime - 30, 0)
        let selectedTime = CMTime(seconds: newTime, preferredTimescale: 1000)

        player.seek(to: selectedTime)
        return .success
    }
    
    
    func isActive() -> Bool
    {
        return  self.player.currentItem != nil ? true : false
    }
    
    func isPlaying() -> Bool
    {
         return ((self.player.rate != 0) && (self.player.error == nil))
    }
    
    func duration() -> CMTime?
    {
        guard let currentItem = self.player.currentItem else { return nil }
        // FIX: item.duration is ready once the item is ready to play; asset.duration on a remote
        // file loads it synchronously and froze the screen
        let itemDuration = currentItem.duration
        if itemDuration.isNumeric && itemDuration.seconds.isFinite {
            return itemDuration
        }
        if currentItem.status == .readyToPlay {
            return currentItem.asset.duration
        }
        return nil
    }
    
    func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Swift.Void)
     {
        self.player.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }
    
    func addPeriodicTimeObserver(forInterval interval: CMTime, queue: DispatchQueue?, using block: @escaping (CMTime) -> Void) -> Any {
        
        let owner = self.player!
        let token = owner.addPeriodicTimeObserver(forInterval: interval, queue: queue, using:block)
        self.timeObserverOwners.append((token: token as AnyObject, player: owner))
        return token
    }
    
    func currentTime() -> CMTime
    {
        return self.player.currentTime()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        // look at `change![.newKey]` to see what the status is, e.g.
        
        if keyPath == "status" {
           if let status = change?[.newKey] as? Int
           {
            switch (status)
            {
                
            case AVPlayerItem.Status.readyToPlay.rawValue:
                
                print ("PLAYER Status ReadyToPlay")
               
                self.playerDelegate?.playerIsReadyToPlay(player: self)
                
                break;
                
            case AVPlayerItem.Status.failed.rawValue:
                
                self.playerDelegate?.playerFailed(player: self)
                
                break
                
            default :
                // FIX: "unknown" is not a failure
                break
            }
            }
            
        }
    }
    
    func updateNowPlayingInfo() {
           guard let player = player else { return }
           
           // Retrieve metadata from AVPlayerItem or set your custom metadata
           let title = "Your Title"
           let artist = "Artist Name"
           /*let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300)) { _ in
               //return yourArtworkImage
           }*/
           /*
           // Set Now Playing Info
           MPNowPlayingInfoCenter.default().nowPlayingInfo = [
               MPMediaItemPropertyTitle: title,
               MPMediaItemPropertyArtist: artist,
               //MPMediaItemPropertyArtwork: artwork,
               // Other metadata properties
           ]
            */
       }
    
    func status() -> String
    {
        if self.player.status == .readyToPlay
        {
            self.updateNowPlayingInfo()
            return "ReadyToPlay"
        }
        return ""
    }
    
    func setRate(_ rate:Float)
    {
        self.playerRate = rate
        if #available(iOS 16.0, *) {
            self.player.defaultRate = rate
        }
        // FIX: setting AVPlayer.rate starts playing; only apply it now if already playing
        if self.player.rate != 0 {
            self.player.rate = self.playerRate
        }
    }
    
    func rate() -> Float
    {
        return self.playerRate
    }
    
    func setTitle(_ title:String)
    {
        self.BTTitle = title
    }
    
    func getTitle() -> String
    {
        return self.BTTitle ?? ""
    }
    
    func setSubTitle(_ title:String)
    {
        self.BTSubTitle = title
    }
    
    func getSubTitle() -> String
    {
        return self.BTSubTitle ?? ""
    }
    
    var subTitle : String {
        get{
            return self.BTSubTitle ?? ""
        }
        set (value){
            
            self.BTSubTitle = value
        }
    }
    
    @objc func itemDidFinishPlaying(notification:NSNotification) {
        
        print ("itemDidFinishPlaying")
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        self.playerDelegate?.playerDidStop(player: self)
    }
}
