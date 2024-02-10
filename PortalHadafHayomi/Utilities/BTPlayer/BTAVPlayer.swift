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
    
    var a_player:AVPlayer!
    var player:AVPlayer!{
        
        get{
            if a_player == nil{
                a_player = AVPlayer()
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: .duckOthers)
              
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
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
            self.player.playImmediately(atRate: self.playerRate)
            self.player.rate = self.playerRate
            
        }
        
        self.updateNowPlayingInfo()
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
        player.removeTimeObserver(observer)
    }
    
    func setPlayerItemPath(itemPathUrl:URL?)
    {
        if let itemPathUrl = itemPathUrl
        {
            self.currentPlayerItemPath = itemPathUrl.absoluteString
            
            var playerItem:AVPlayerItem!
            
            playerItem = AVPlayerItem(url: itemPathUrl)
            
            playerItem.addObserver(self, forKeyPath: "status", options: .new, context: &observerContext)
            
            self.player.currentItem?.removeObserver(self, forKeyPath:"status")
            
            self.player = nil
            self.player.replaceCurrentItem(with: playerItem)
            
            self.setupCommandCenter()
        }
    }
    
    private func setupCommandCenter() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.seekForwardCommand.isEnabled = true
        commandCenter.seekBackwardCommand.isEnabled = true
        
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.player.play()
            
            self?.player.playImmediately(atRate: 1.0)
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            
            if self != nil {
                
                if let duration  = self?.player.currentItem?.duration {
                    let playerCurrentTime = CMTimeGetSeconds(self!.player.currentTime())
                    let newTime = playerCurrentTime + 30
                    if newTime < CMTimeGetSeconds(duration)
                    {
                        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                        self?.player.seek(to: selectedTime)
                    }
                    self?.player.pause()
                    self?.player.play()
                }
            }
            
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
                 
                 if self != nil {
                     
                     if let duration  = self?.player.currentItem?.duration {
                         let playerCurrentTime = CMTimeGetSeconds(self!.player.currentTime())
                         let newTime = playerCurrentTime - 30
                         if newTime < CMTimeGetSeconds(duration)
                         {
                             let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                             self?.player.seek(to: selectedTime)
                         }
                         self?.player.pause()
                         self?.player.play()
                     }
                 }
                 
                 return .success
             }
        
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
                  self?.player.pause()
                  return .success
              }
        
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
        if let currentItem = self.player.currentItem
        {
            return currentItem.asset.duration
        }
        else{
            return nil
        }
    }
    
    func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Swift.Void)
     {
        self.player.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }
    
    func addPeriodicTimeObserver(forInterval interval: CMTime, queue: DispatchQueue?, using block: @escaping (CMTime) -> Void) -> Any {
        
        return self.player.addPeriodicTimeObserver(forInterval: interval, queue: queue, using:block)
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
                
            case AVPlayer.Status.readyToPlay.rawValue:
                
                print ("PLAYER Status ReadyToPlay")
               
                self.delegate.playerIsReadyToPlay(player: self)
                
                break;
                
            default :
                
                self.delegate.playerFailed(player: self)
                
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
           
           // Set Now Playing Info
           MPNowPlayingInfoCenter.default().nowPlayingInfo = [
               MPMediaItemPropertyTitle: title,
               MPMediaItemPropertyArtist: artist,
               //MPMediaItemPropertyArtwork: artwork,
               // Other metadata properties
           ]
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
        self.player.rate = self.playerRate
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
        
        self.delegate.playerDidStop(player: self)
    }
}
