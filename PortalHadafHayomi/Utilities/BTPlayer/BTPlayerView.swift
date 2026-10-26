//
//  BTPlayerView.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 01/08/2016.
//
//

import UIKit
import AVFoundation
import MediaPlayer

protocol BTPlayerViewDelegate: class {
    
    func didPlay(player:BTPlayerView)
    func didPause(player:BTPlayerView)
    func playerView(_ player:BTPlayerView, didChangeDuration duration:Int)
    func didFinishPlaying(_ player:BTPlayerView)
    func didCancelWithError(_ error:Error?)
}

class BTPlayerView: UIView,IPlayerProtocolDelegate, BTPlayerRateSpeedViewDelegate {
    
    weak var delegate: BTPlayerViewDelegate?
    
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var pauseButton:UIButton!
    @IBOutlet weak var loadingActivityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var subTitleLabel:UILabel?
    @IBOutlet weak var progressSlider:UISlider!
    @IBOutlet weak var timePassedLabel:UILabel!
    @IBOutlet weak var timeLeftLabel:UILabel!
    @IBOutlet weak var errorLabel:UILabel!
    
    @IBOutlet weak var rateSpeedButton:UIButton?
    
    @IBOutlet weak var lockButton:UIButton!
    
    @IBOutlet weak var jumpForwardButton:UIButton?
    @IBOutlet weak var jumpBackButton:UIButton?
    
    var lockView:UIView?
    
    var onReadyToPlay:(() -> Void)?
    var onLessonNotFound:(() -> Void)?
    var onPlayerDidStop:(() -> Void)?
    var onPreButtonClicked:(() -> Void)?
    var onNextButtonClicked:(() -> Void)?
    
    var isPaused = false
    var startAutomatically = false
    
    var isPlaying:Bool{
        get{
            return self.player.isPlaying()
        }
    }
    
    var desiredStartDuration:Float = 0.0
    
    var player:IPlayerProtocol!
    {
        get{
            var player = BTPlayerManager.sharedManager.player!
            player.delegate = self
            
            
            return player
        }
    }
    
    var title:String = "" {
        didSet{
            self.player.setTitle(self.title)
            
            self.titleLabel?.text = self.title
            
            // Notify CarPlay of title change
            self.notifyCarPlayOfTitleChange(title: self.title)
        }
    }
    
    var subTitle:String = "" {
        didSet{
            self.player.setSubTitle(self.subTitle)
            
            self.subTitleLabel?.text = self.subTitle
            
            // Notify CarPlay of subtitle change
            self.notifyCarPlayOfSubTitleChange(subTitle: self.subTitle)
        }
    }
    
    
    var getAudioDurationOperation = OperationQueue()
    
    var timeObserver:Any!
    
    var playingItem:AVPlayerItem!
    var playerUrl:URL?
    
    func setPalyerNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.itemDidFinishPlaying(notification:)),name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func setPlayerUrl(_ url:URL?, durration:Int
                      ,onReadyToPlay:@escaping () -> Void
                      ,onLessonNotFound:@escaping () -> Void
                      ,onPlayerDidStop:@escaping () -> Void)
    {
        self.onReadyToPlay = onReadyToPlay
        self.onLessonNotFound = onLessonNotFound
        self.onPlayerDidStop = onPlayerDidStop
        
        self.setPlayerUrl(url, durration: durration)
    }
    
    func setPlayerUrl(_ url:URL?, durration:Int)
    {
        if durration > 0
        {
            self.desiredStartDuration = Float(durration)
        }
        
        self.setPlayerUrl(url)
    }
    
    func setPlayerUrl(_ url:URL?)
    {
        //If the url is the sampe as the current url, do not update player
        if let newUrl = url
            ,let currentPlayerUrl = self.playerUrl
            , currentPlayerUrl.absoluteString == newUrl.absoluteString
        {
            return
        }
        
        let selectedUrl = url
        
        if selectedUrl != nil
        {
            print ("SelectedAudioUrl:\(selectedUrl!.absoluteString)")
        }
        else{
            print ("setAudioUrlForLesson failed")
        }
        
        self.playerUrl = selectedUrl
        
        self.loadSelectedURL()
        
        // Notify CarPlay of URL change
        self.notifyCarPlayOfURLChange(url: url)
    }
    
    func loadSelectedURL() {
        
        if self.player != nil
        {
            //self.desiredStartDuration = 0.0
            
            if timeObserver != nil
            {
                self.player.removeTimeObserver(observer: timeObserver)
                self.timeObserver = nil
            }
            self.player.pause()
            self.isPaused = false
            //self.player.setPlayerItemPath(itemPathUrl: nil)
            
            self.pauseButton.isHidden = true
            self.playButton.isHidden = false
        }
        
        self.getAudioDurationOperation.cancelAllOperations()
        
        self.errorLabel.isHidden = true
        
        
        self.timeLeftLabel.text = self.timeDisplayForSeconds(seconds: 0)
        self.timePassedLabel.text = self.timeDisplayForSeconds(seconds: 0)
        
        if self.playerUrl == nil
        {
            self.setLessonNotFoundLayout()
            
            return
        }
        
        self.updatePlayer()
        
        self.setPalyerNotifications()
    }
    
    func setReadyToPlayLayout()
    {
        if let duration = self.player.duration()
        {
            self.updatePlayerWithDurationSeconds(seconds: CMTimeGetSeconds(duration))
        }
        
        if self.startAutomatically
        {
            self.play()
            /*
             if let enablesAutomaticPlaying = UserDefaults.standard.object(forKey: "setableItem_EnablesAutomaticPlaying") as? Bool
             ,enablesAutomaticPlaying == false
             {
             self.setPrepareToPlayLayout()
             }
             else{
             
             self.play()
             }
             */
        }
        else{
            self.setPrepareToPlayLayout()
        }
    }
    
    func setLessonNotFoundLayout()
    {
        self.loadingActivityIndicator.isHidden = true
        self.loadingActivityIndicator.stopAnimating()
        self.playingItem = nil
        
        self.playButton.isHidden = true
        self.errorLabel.isHidden = false
        self.errorLabel.text = "st_lesson_not_found".localize()
        
        self.jumpForwardButton?.isHidden = true
        self.jumpBackButton?.isHidden = true
        
        self.updatePlayerWithDurationSeconds(seconds: 0)
        
        self.delegate?.didCancelWithError(nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        /*
         self.playButton.accessibilityIdentifier = "Play"
         self.pauseButton.accessibilityIdentifier = "Pause"
         self.jumpForwardButton?.accessibilityIdentifier = "Jump Forward"
         self.jumpBackButton?.accessibilityIdentifier = "Jump Back"
         */
        self.loadingActivityIndicator.isHidden = true
        self.pauseButton.isHidden = true
        self.errorLabel.isHidden = true
        
        self.progressSlider.setThumbImage(UIImage(named:"inner_ipad.png"), for: .normal)
        self.progressSlider.setThumbImage(UIImage(named:"inner_ipad.png"), for: .highlighted)
        
        self.progressSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BTPlayerView.sliderTappedAction(_:))))
        
        self.errorLabel.textColor = UIColor.white
        
        let jumpDuratoin =  UserDefaults.standard.object(forKey: "selectedLessonSkipInterval") as? String ?? "30"
        self.jumpBackButton?.setTitle(jumpDuratoin, for: .normal)
        self.jumpForwardButton?.setTitle(jumpDuratoin, for: .normal)
        
        self.becomeFirstResponder()
        //UIApplication.shared.beginReceivingRemoteControlEvents()
        
       // self.addActionsToControlCenter()
        
        if let playerRateSpeed =  UserDefaults.standard.object(forKey: "lessonPlayerRateSpeed") as? Float {
            self.rateSpeedButton?.setTitle( String(format: "%.1f", playerRateSpeed), for: .normal)
        }
        
        // Setup CarPlay synchronization
        self.setupCarPlaySync()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else {
            return
        }
        switch event.subtype {
        case .remoteControlPlay:
            self.play()
           // self.rateSpeedButton
            break
            
        case .remoteControlPause:
            self.pause()
            
            break
        case .remoteControlStop:
            ///
            break
            
        default:
            print("default action")
        }
    }
    
    func showLessonNotFoundAlert()
    {
        let title = "st_lesson_not_found".localize()
        let msg = "st_lesson_not_found_message".localize()
        let cancelButton = "st_cancel".localize()
        BTAlertView.show(title: title, message: msg, buttonKeys: [cancelButton], onComplete:{ (dismissButtonKey) in
        })
    }
    
    @IBAction func jumpForwardButtonClicked(_ sedner:UIButton)
    {
        if player != nil
        {
            let jumpDuration = Float(sedner.title(for: .normal) ?? "30") ?? 30
            var newDuratoin = self.progressSlider.value + jumpDuration
            
            if newDuratoin > self.progressSlider.maximumValue
            {
                newDuratoin = self.progressSlider.maximumValue
            }
            
            self.setDuration(Int(newDuratoin))
        }
    }
    
    @IBAction func jumpBackButtonClicked(_ sedner:UIButton)
    {
        if player != nil
        {
            let jumpDuration = Float(sedner.title(for: .normal) ?? "30") ?? 30
            var newDuratoin = self.progressSlider.value - jumpDuration
            
            if newDuratoin < self.progressSlider.minimumValue
            {
                newDuratoin = self.progressSlider.minimumValue
            }
            
            self.setDuration(Int(newDuratoin))
        }
    }
    
    
    @IBAction func lockButtonClicked(_ sender:UIButton){
        self.lockButton.isSelected = !self.lockButton.isSelected
        
        if self.lockButton.isSelected {
            self.lockView = UIView(frame: self.bounds)
            self.lockView?.backgroundColor = UIColor.white
            self.lockView?.alpha = 0.2
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.lockViewTap(_:)))
            self.lockView?.addGestureRecognizer(tap)
            
            self.addSubview(lockView!)
        }
        else{
            self.unlock()
        }
    }
    
    func unlock() {
        if let gestureRecognizers = self.lockView?.gestureRecognizers {
            for gestreRecognizer in gestureRecognizers {
                self.lockView?.removeGestureRecognizer(gestreRecognizer)
            }
        }
        self.lockView?.removeFromSuperview()
        self.lockButton.isSelected = false
    }
    
    @objc func lockViewTap(_ sender: UITapGestureRecognizer) {
        self.displayLockAlert()
    }
    
    func displayLockAlert(){
        BTAlertView.show(title: "st_player_locked_alert_title".localize(), message: "st_player_locked_alert_Message".localize(), buttonKeys: ["st_unlock_button".localize(), "st_keppLocked_button".localize()]) { dismissButtonKey in
            if dismissButtonKey == "st_unlock_button".localize() {
                self.unlock()
            }
        }
    }
    
    @IBAction func rateSpeedButtonClicked(_ sender:UIButton)
    {
        if let playerRateSpeedView = UIView.viewWithNib("BTPlayerRateSpeedView") as? BTPlayerRateSpeedView
        {
            playerRateSpeedView.delegate = self
            
            let options = [
                .type(.down)
            ] as [PopoverOption]
            
            let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
            
            var inView:UIView = self
            if let rootNavController = UIApplication.shared.keyWindow?.rootViewController
            {
                inView = rootNavController.view
            }
            popover.show(playerRateSpeedView, fromView: self.rateSpeedButton!, inView: inView)
            
            playerRateSpeedView.setValue(player.rate(), animated: false)
        }
    }
    
    @IBAction func sliderTappedAction(_ sender: UITapGestureRecognizer)
    {
        if let slider = sender.view as? UISlider {
            
            if slider.isHighlighted { return }
            
            let point = sender.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: false)
            
            
            self.sliderChanged(self.progressSlider)
            
            if player != nil && self.player.isActive()
            {
                if self.playButton.isHidden
                {
                    self.player.play()
                    self.delegate?.didPlay(player:self)
                }
            }
        }
    }
    
    @IBAction func sliderChanged(_ slider:UISlider)
    {
        if slider == progressSlider
        {
            self.setDuration(Int(self.progressSlider.value))
        }
    }
    
    @IBAction func preButtonClicked(_ sender:UIButton){
        self.onPreButtonClicked?()
    }
    
    @IBAction func nextButtonClicked(_ sender:UIButton){
        self.onNextButtonClicked?()
    }
    
    func setDuration(_ duration:Int)
    {
        self.updateDurationLayout(duration:duration)
        
        if player == nil || self.player.isActive()
        {
            // FIX: jumping back to 0:00 did nothing (only times > 0 were seeked to),
            // and the duration change was not reported
            if self.player != nil, self.player.status() == "ReadyToPlay", let playerDuration = self.player.duration() {
                let time = CMTimeMakeWithSeconds(Double(max(0, duration)), preferredTimescale: playerDuration.timescale)
                self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in }
                self.desiredStartDuration = 0.0
            } else {
                self.moveToDesiredStartDuration(Float(duration))
            }
            self.delegate?.playerView(self, didChangeDuration: duration)
            self.notifyCarPlayOfDurationChange(duration: duration)
            return
        }
        if let playerDuration = self.player.duration()
        {
            let timeScale = playerDuration.timescale
            let time = CMTimeMakeWithSeconds(Double(duration), preferredTimescale: timeScale);
            
            if self.isPaused
            {
                self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero){ (Bool) in
                }
                
            }
            else
            {
                self.player.pause()
                self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero){ (Bool) in
                }
            }
        }
        
        self.delegate?.playerView(self, didChangeDuration: duration)
        
        // Notify CarPlay of duration change
        self.notifyCarPlayOfDurationChange(duration: duration)
    }
    
    func updateDurationLayout(duration:Int)
    {
        self.updateNowPlayingProgress(currentTime: TimeInterval(duration))
        self.progressSlider.value = Float(duration)
        self.timePassedLabel.text = self.timeDisplayForSeconds(seconds: duration)
        
        let timeLeft = Int( self.progressSlider.maximumValue) - duration
        self.timeLeftLabel.text = self.timeDisplayForSeconds(seconds: timeLeft)
    }
    
    @IBAction func sliderDidFinishSliding(_ sender:AnyObject)
    {
        print ("sliderDidFinishSliding")
        if self.player != nil && self.player.isActive()
        {
            if self.isPaused == false //the slider should playing
            {
                if self.playButton.isHidden
                {
                    self.player.play()
                    self.updateInfoCenter()
                    self.delegate?.didPlay(player:self)
                }
            }
        }
        else{
            
            self.moveToDesiredStartDuration(self.progressSlider.value)
            
        }
        
    }
    
    @IBAction func playButtonClicked(_ sender:AnyObject)
    {
        self.play()
        
        self.setIsPlayingLayout()
    }
    
    func play()
    {
        // FIX: a new AVPlayerItem was created here on every play just to check the url (unused)
        if self.playerUrl == nil
        {
            return
        }
        
        self.player.play()
        self.updateInfoCenter()
        
        self.setIsPlayingLayout()
        
        self.delegate?.didPlay(player:self)
        
        // Notify CarPlay of state change
        self.notifyCarPlayOfStateChange()
    }
    
    func updatePlayer()
    {
        let jumpDuratoin =  UserDefaults.standard.object(forKey: "selectedLessonSkipInterval") as? String ?? "30"
        self.jumpBackButton?.setTitle(jumpDuratoin, for: .normal)
        self.jumpForwardButton?.setTitle(jumpDuratoin, for: .normal)
        
        if self.playerUrl != nil {
            
            self.playButton.isHidden = true
            self.loadingActivityIndicator.isHidden = false
            self.loadingActivityIndicator.startAnimating()
            
            self.player.setPlayerItemPath(itemPathUrl: self.playerUrl)
            
            self.jumpForwardButton?.isHidden = true
            self.jumpBackButton?.isHidden = true
        }
        
    }
    
    func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func updatePlayerWithDurationSeconds(seconds:Float64)
    {
        // FIX: a not-yet-known / live duration is NaN or infinite -> Int(seconds) crashed
        let seconds = (seconds.isFinite && seconds > 0) ? seconds : 0
        let timeNow = self.timeNow()
        
        if timeNow > 0
        {
            if loadingActivityIndicator.isAnimating
            {
                self.setPrepareToPlayLayout()
                self.setIsPlayingLayout()
            }
        }
        
        self.timePassedLabel.text = self.timeDisplayForSeconds(seconds: timeNow)
        
        self.progressSlider.value = Float(timeNow)
        
        let timeLeft = Int(seconds) - Int(timeNow)
        self.timeLeftLabel.text = self.timeDisplayForSeconds(seconds: timeLeft)
        
        self.progressSlider.minimumValue = 0.0
        self.progressSlider.maximumValue = Float(seconds)
        
        self.updateNowPlayingProgress(currentTime: TimeInterval(timeNow))

        self.delegate?.playerView(self, didChangeDuration: Int(timeNow))
    }
    
    func timeNow() -> Int
    {
        var timeNow = Int(0.0)
        
        if self.player != nil && self.player.isActive()
        {
            // FIX: an invalid time has timescale 0 -> division by zero -> crash on Int(inf / NaN)
            let seconds = CMTimeGetSeconds(self.player.currentTime())
            if seconds.isFinite && seconds >= 0 {
                timeNow = Int(seconds)
            }
        }
        
        return timeNow
    }
    
    func timeDisplayForSeconds(seconds:Int) -> String
    {
        let mins = seconds / 60
        let sec = seconds % 60
        
        let minsDisplay = mins > 9 ? "\(mins)" : "0\(mins)"
        let secDisplay = sec > 9 ? "\(sec)" : "0\(sec)"
        
        return "\(minsDisplay):\(secDisplay)"
        
    }
    
    @IBAction func pauseButtonClicked(_ sender:AnyObject)
    {
        self.pause()
        
        self.delegate?.didPause(player: self)
    }
    
    func pause()
    {
        self.player.pause()
        self.playerDidStop()
        
        // Notify CarPlay of state change
        self.notifyCarPlayOfStateChange()
    }
    
    func playerDidStop()
    {
        self.isPaused = true
        self.pauseButton.isHidden = true
        self.playButton.isHidden = false
        
        if SpeechManager.sharedManager.shouldListen
        {
            SpeechManager.sharedManager.listen()
        }
    }
    
    func moveToDesiredStartDuration(_ desiredStartDuration:Float)
    {
        self.desiredStartDuration = desiredStartDuration
        
        if self.player.status() == "ReadyToPlay"
        {
            // FIX: guard the duration (was force-unwrapped)
            if self.desiredStartDuration > 0.0, let playerDuration = self.player.duration()
            {
                
                let timeScale = playerDuration.timescale;
                let time = CMTimeMakeWithSeconds(Double(self.desiredStartDuration), preferredTimescale: timeScale);
                
                self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero){ (Bool) in
                    
                    self.updateDurationLayout(duration:Int(desiredStartDuration))
                    
                    self.desiredStartDuration = 0.0
                }
            }
        }
    }
    
    @objc func itemDidFinishPlaying(notification:NSNotification)  {
        
        // FIX: this notification comes for EVERY AVPlayerItem in the app (video player, other
        // sounds). Only react when our lesson finished.
        if let finishedItem = notification.object as? AVPlayerItem,
           let lessonPlayer = BTPlayerManager.sharedManager.player as? BTAVPlayer,
           finishedItem !== lessonPlayer.player.currentItem {
            return
        }
        
        let timeScale = self.player.duration()?.timescale ?? 600
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: timeScale);
        
        self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero){ (Bool) in
            
            self.desiredStartDuration = 0.0
        }
        
        self.playerDidStop()
        
        self.delegate?.didFinishPlaying(self)
    }
    
    func setPrepareToPlayLayout()
    {
        self.loadingActivityIndicator.isHidden = true
        self.loadingActivityIndicator.stopAnimating()
        
        self.pauseButton.isHidden = true
        self.playButton.isHidden = false
        self.errorLabel.isHidden = true
        
        self.jumpForwardButton?.isHidden = false
        self.jumpBackButton?.isHidden = false
    }
    
    func setIsPlayingLayout()
    {
        self.pauseButton.isHidden = false
        self.playButton.isHidden = true
    }
    
    func setNotPlayingLayout()
    {
        self.playerDidStop()
    }
    
    
    func playerIsReadyToPlay(player:IPlayerProtocol)
    {
        if let duration = self.player.duration()
        {
            self.moveToDesiredStartDuration(self.desiredStartDuration)
            
            let seconds = CMTimeGetSeconds(duration)
            
            if seconds > 0
            {
                self.setReadyToPlayLayout()
                self.addPeriodicTimeObserver()
                self.setBackgourndPlayer()
                
                //This is a callback if some one is listing to this
                self.onReadyToPlay?()
                
                return
            }
        }
        
        self.onLessonNotFound?()
        self.setLessonNotFoundLayout()
    }
    
    func playerDidStop(player:IPlayerProtocol) {
        
        self.onPlayerDidStop?()
        
        self.pause()
        self.delegate?.didPause(player: self)
    }
    
    func playerDidPlay(player:IPlayerProtocol) {
        self.setIsPlayingLayout()
        self.delegate?.didPlay(player:self)
    }
    
    func addPeriodicTimeObserver()
    {
        // FIX: never keep two observers (ready-to-play can come again, CarPlay re-adds) -
        // the extra one was never removed and kept running
        if self.timeObserver != nil {
            self.player.removeTimeObserver(observer: self.timeObserver!)
            self.timeObserver = nil
        }
        self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] time in
            // FIX: was force-unwrapping a weak self
            guard let self = self, self.player.isActive() else { return }
            if let duration = self.player.duration()
            {
                self.updatePlayerWithDurationSeconds(seconds: CMTimeGetSeconds(duration))
            }
        }
    }
    
    func setBackgourndPlayer()
    {
        // FIX: used a second AVPlayerItem (loading its remote file on the main thread, and nil
        // after "lesson not found" -> crash). Use the playing item's duration and the real speed.
        var durationSeconds:Double = 0
        if let duration = self.player.duration() {
            let seconds = CMTimeGetSeconds(duration)
            if seconds.isFinite && seconds > 0 { durationSeconds = seconds }
        }
        var playingInfo = [MPMediaItemPropertyArtist: self.titleLabel?.text ?? "",
            MPMediaItemPropertyTitle: self.subTitleLabel?.text ?? "",
            MPMediaItemPropertyPlaybackDuration: NSNumber(value: durationSeconds),
            MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: self.timeNow()),
                MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: self.isPlaying ? self.player.rate() : 0)] as [String : Any]
        
        if let image = UIImage(named: "Icon-App-60x60@3x.png") {
            let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300)) { _ in
                image
            }
            playingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
    }
    
    func updateNowPlayingProgress(currentTime: TimeInterval) {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func playerFailed(player:IPlayerProtocol)
    {
        self.onLessonNotFound?()
        self.setLessonNotFoundLayout()
    }
    
    func playerDidUpdateInfo(player: IPlayerProtocol) {
        
    }
    
    //Mark BTPlayerRateSpeedView Delegate methods
    
    func rateSpeedView(_ rateSpeedView:BTPlayerRateSpeedView, valueChanged value:Float)
    {
        self.rateSpeedButton?.setTitle( String(format: "%.1f", value), for: .normal)
        
        UserDefaults.standard.set(value, forKey: "lessonPlayerRateSpeed")
        UserDefaults.standard.synchronize()
        
        self.player.setRate(value)
    }
    
    func currentPlayingDuration() -> Double {
        
        return self.player.currentTime().seconds
    }
    
    func addActionsToControlCenter(){
        addActionToPlayCommand()
        addActionToPauseCommnd()
        addActionToPreviousCommand()
        addActionToNextCommand()
        addActionToChangePlayBackPosition()
        addActionToseekForwardCommand()
        addActionToseekBackwordCommand()
        
        MPRemoteCommandCenter.shared().skipForwardCommand.addTarget { [weak self] event in
                  // Handle forward button press event here
                  if let commandEvent = event as? MPSkipIntervalCommandEvent {
                      let skipInterval = commandEvent.interval
                    
                      return .success
                  }
                  return .commandFailed
              }
    }
    
    func addActionToPlayCommand(){
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(playCommand))
    }
    func addActionToPauseCommnd(){
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(pauseCommand))
    }
    func addActionToPreviousCommand(){MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true   
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action: #selector(previousButtonTapped))
    }
    func addActionToNextCommand(){MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action: #selector(nextButtonTapped))
    }
    func addActionToChangePlayBackPosition(){
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(self, action: #selector(changePlaybackPosition))
    }
    func addActionToseekForwardCommand(){
        MPRemoteCommandCenter.shared().seekForwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(seekForward))
    }
    func addActionToseekBackwordCommand(){
        MPRemoteCommandCenter.shared().seekBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(seekBackword))
    }
    
    @objc func playCommand() -> MPRemoteCommandHandlerStatus {
        self.play()
        return .success
    }
    
    @objc func pauseCommand() -> MPRemoteCommandHandlerStatus {
        // Your implementation to handle play command
        self.pause()
        return .success
    }
    
    @objc func previousButtonTapped() -> MPRemoteCommandHandlerStatus {
        // Your implementation to handle play command
        return .success
    }
    
    @objc func nextButtonTapped() -> MPRemoteCommandHandlerStatus {
        // Your implementation to handle play command
        return .success
    }
    
    @objc func changePlaybackPosition() -> MPRemoteCommandHandlerStatus {
        // Your implementation to handle play command
        return .success
    }
    
    @objc func seekForward() -> MPRemoteCommandHandlerStatus {
        // Your implementation to handle play command
        return .success
    }
    
    @objc func seekBackword() -> MPRemoteCommandHandlerStatus {
        // Your implementation to handle play command
        return .success
    }

    func updateInfoCenter() {
        self.setBackgourndPlayer()
    }
    
    // MARK: - CarPlay Synchronization
    
    private func setupCarPlaySync() {
        // Listen for CarPlay player updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(carPlayPlayerDidUpdate(_:)),
            name: NSNotification.Name("CarPlayPlayerDidUpdateState"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(carPlayPlayerDidChangeDuration(_:)),
            name: NSNotification.Name("CarPlayPlayerDidChangeDuration"),
            object: nil
        )
        
        // Listen for CarPlay about to load a new URL so we can remove our time observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(carPlayWillLoadNewURL),
            name: NSNotification.Name("CarPlayWillLoadNewURL"),
            object: nil
        )
    }
    
    @objc private func carPlayWillLoadNewURL() {
        if timeObserver != nil {
            self.player.removeTimeObserver(observer: timeObserver)
            self.timeObserver = nil
        }
    }
    
    @objc private func carPlayPlayerDidUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let source = userInfo["source"] as? String,
              source == "CarPlay" else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let isPlaying = userInfo["isPlaying"] as? Bool {
                if isPlaying {
                    // CarPlay started playing - fully set up phone UI
                    // since CarPlay may have loaded the lesson into the shared player
                    if let duration = self.player.duration() {
                        let seconds = CMTimeGetSeconds(duration)
                        if seconds > 0 {
                            self.loadingActivityIndicator.isHidden = true
                            self.loadingActivityIndicator.stopAnimating()
                            self.errorLabel.isHidden = true
                            self.jumpForwardButton?.isHidden = false
                            self.jumpBackButton?.isHidden = false
                            
                            self.progressSlider.minimumValue = 0.0
                            self.progressSlider.maximumValue = Float(seconds)
                            
                            // Re-add time observer if needed
                            if self.timeObserver == nil {
                                self.addPeriodicTimeObserver()
                            }
                            
                            self.setBackgourndPlayer()
                        }
                    }
                    self.setIsPlayingLayout()
                } else if !isPlaying && self.isPlaying {
                    // CarPlay paused, update phone UI
                    self.setNotPlayingLayout()
                }
            }
        }
    }
    
    @objc private func carPlayPlayerDidChangeDuration(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let source = userInfo["source"] as? String,
              source == "CarPlay",
              let duration = userInfo["duration"] as? Int else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update UI without triggering another CarPlay notification
            self.updateDurationLayout(duration: duration)
        }
    }
    
    private func notifyCarPlayOfStateChange() {
        DispatchQueue.main.async {
            let userInfo: [String: Any] = [
                "isPlaying": self.isPlaying,
                "title": self.title,
                "subTitle": self.subTitle,
                "source": "Phone"
            ]
            
            NotificationCenter.default.post(
                name: NSNotification.Name("BTPlayerViewDidUpdateState"),
                object: self,
                userInfo: userInfo
            )
            
            // Also update CarPlay directly through manager
            CarPlayManager.shared.updateCarPlayWithPhonePlayerState(
                title: self.title,
                subTitle: self.subTitle,
                isPlaying: self.isPlaying
            )
        }
    }
    
    private func notifyCarPlayOfDurationChange(duration: Int) {
        DispatchQueue.main.async {
            let userInfo: [String: Any] = [
                "duration": duration,
                "source": "Phone"
            ]
            
            NotificationCenter.default.post(
                name: NSNotification.Name("BTPlayerViewDidUpdateState"),
                object: self,
                userInfo: userInfo
            )
            
            // Also update CarPlay directly through manager
            CarPlayManager.shared.updateCarPlayWithPhonePlayerState(duration: duration)
        }
    }
    
    private func notifyCarPlayOfURLChange(url: URL?) {
        DispatchQueue.main.async {
            var userInfo: [String: Any] = ["source": "Phone"]
            if let url = url {
                userInfo["url"] = url
            }
            
            NotificationCenter.default.post(
                name: NSNotification.Name("BTPlayerViewDidUpdateState"),
                object: self,
                userInfo: userInfo
            )
            
            // Also update CarPlay directly through manager
            CarPlayManager.shared.updateCarPlayWithPhonePlayerState(url: url)
        }
    }
    
    private func notifyCarPlayOfTitleChange(title: String) {
        DispatchQueue.main.async {
            let userInfo: [String: Any] = [
                "title": title,
                "source": "Phone"
            ]
            
            NotificationCenter.default.post(
                name: NSNotification.Name("BTPlayerViewDidUpdateState"),
                object: self,
                userInfo: userInfo
            )
            
            // Also update CarPlay directly through manager
            CarPlayManager.shared.updateCarPlayWithPhonePlayerState(title: title)
        }
    }
    
    private func notifyCarPlayOfSubTitleChange(subTitle: String) {
        DispatchQueue.main.async {
            let userInfo: [String: Any] = [
                "subTitle": subTitle,
                "source": "Phone"
            ]
            
            NotificationCenter.default.post(
                name: NSNotification.Name("BTPlayerViewDidUpdateState"),
                object: self,
                userInfo: userInfo
            )
            
            // Also update CarPlay directly through manager
            CarPlayManager.shared.updateCarPlayWithPhonePlayerState(subTitle: subTitle)
        }
    }
}

