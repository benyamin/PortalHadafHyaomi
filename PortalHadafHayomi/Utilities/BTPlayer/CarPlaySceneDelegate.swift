//  CarPlaySceneDelegate.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 04/03/2026.
//

import UIKit
import CarPlay
import MediaPlayer

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    var carPlayPlayerView: CarPlayPlayerView?
    private var updateTimer: Timer?
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        setupCarPlayInterface()
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
        carPlayPlayerView = nil
        
        // Clean up timer
        updateTimer?.invalidate()
        updateTimer = nil
        
        // Disable remote commands
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = false
        commandCenter.pauseCommand.isEnabled = false
        commandCenter.skipForwardCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false
        commandCenter.changePlaybackPositionCommand.isEnabled = false
        commandCenter.changePlaybackRateCommand.isEnabled = false
        commandCenter.seekForwardCommand.isEnabled = false
        commandCenter.seekBackwardCommand.isEnabled = false
    }
    
    private func setupCarPlayInterface() {
        guard let interfaceController = interfaceController else { return }
        
        // Create the CarPlay player view
        carPlayPlayerView = CarPlayPlayerView()
        
        // Create a now playing template
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        
        // Set the now playing template as root
        interfaceController.setRootTemplate(nowPlayingTemplate, animated: false, completion: nil)
        
        // Setup now playing button actions
        setupNowPlayingButtons()
        
        // Setup media remote command center for CarPlay
        setupMediaRemoteCommands()
        
        // Setup periodic updates for better scroll bar responsiveness
        setupPeriodicUpdates()
        
        // Display or auto-play a lesson on connect
        displayLessonOnConnect()
    }
    
    private func setupNowPlayingButtons() {
        guard let carPlayPlayerView = carPlayPlayerView else { return }
        
        // Play/Pause button
        let playPauseButton = CPNowPlayingPlaybackRateButton { [weak self] button in
            if carPlayPlayerView.isPlaying {
                carPlayPlayerView.pause()
            } else {
                carPlayPlayerView.play()
            }
        }
        
        // Jump forward button
        let jumpForwardButton = CPNowPlayingImageButton(image: UIImage(systemName: "goforward.30")!) { [weak self] button in
            carPlayPlayerView.jumpForward()
        }
        
        // Jump backward button
        let jumpBackwardButton = CPNowPlayingImageButton(image: UIImage(systemName: "gobackward.30")!) { [weak self] button in
            carPlayPlayerView.jumpBackward()
        }
        
        // Rate speed button
        let rateSpeedButton = CPNowPlayingImageButton(image: UIImage(systemName: "speedometer")!) { [weak self] button in
            carPlayPlayerView.changePlaybackRate()
        }
        
        // Update the now playing template buttons
        CPNowPlayingTemplate.shared.updateNowPlayingButtons([
            jumpBackwardButton,
            playPauseButton,
            jumpForwardButton,
            rateSpeedButton
        ])
    }
    
    private func setupMediaRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.carPlayPlayerView?.play()
            return .success
        }
        
        // Pause command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.carPlayPlayerView?.pause()
            return .success
        }
        
        // Skip forward command
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: 30)]
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            self?.carPlayPlayerView?.jumpForward()
            return .success
        }
        
        // Skip backward command
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: 30)]
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            self?.carPlayPlayerView?.jumpBackward()
            return .success
        }
        
        // Change playback position command for scroll bar interaction
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let carPlayPlayerView = self.carPlayPlayerView,
                  let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            
            let newPosition = event.positionTime
            let totalDuration = carPlayPlayerView.getTotalDuration()
            
            // Validate that the new position is within bounds
            guard newPosition >= 0 && newPosition <= totalDuration else {
                return .commandFailed
            }
            
            // Set the new playback position
            carPlayPlayerView.setDuration(Int(newPosition))
            
            // Update the now playing info to reflect the change immediately
            self.updateNowPlayingInfoPosition(position: newPosition)
            
            return .success
        }
        
        // Add change playback rate command
        commandCenter.changePlaybackRateCommand.isEnabled = true
        commandCenter.changePlaybackRateCommand.supportedPlaybackRates = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
        commandCenter.changePlaybackRateCommand.addTarget { [weak self] event in
            guard let rateEvent = event as? MPChangePlaybackRateCommandEvent else {
                return .commandFailed
            }
            self?.carPlayPlayerView?.changePlaybackRate()
            return .success
        }
        
        // Add seek commands for fine-grained scrubbing
        commandCenter.seekForwardCommand.isEnabled = true
        commandCenter.seekForwardCommand.addTarget { [weak self] event in
            guard let seekEvent = event as? MPSeekCommandEvent else { return .commandFailed }
            let commandType = seekEvent.type
            
            if commandType == .beginSeeking {
                // Begin seeking - could pause here if needed
                return .success
            } else if commandType == .endSeeking {
                // End seeking - resume playback if it was playing
                return .success
            }
            return .success
        }
        
        commandCenter.seekBackwardCommand.isEnabled = true
        commandCenter.seekBackwardCommand.addTarget { [weak self] event in
            guard let seekEvent = event as? MPSeekCommandEvent else { return .commandFailed }
            let commandType = seekEvent.type
            
            if commandType == .beginSeeking {
                // Begin seeking - could pause here if needed
                return .success
            } else if commandType == .endSeeking {
                // End seeking - resume playback if it was playing
                return .success
            }
            return .success
        }
    }
    
    // MARK: - Auto-Play / Display Lesson on Connect
    
    private func displayLessonOnConnect() {
        // Don't interfere if already playing
        if LessonsManager.sharedManager.isPlaying { return }
        guard let carPlayPlayerView = carPlayPlayerView else { return }
        
        let saveLastLesson = UserDefaults.standard.object(forKey: "setableItem_SaveLastLesson") as? Bool ?? true
        
        // If there's a last played lesson, auto-play it
        if saveLastLesson,
           let lastPlayedLesson = LessonsManager.sharedManager.lastPlayedLasson(),
           let lastPlayedLessonInfo = UserDefaults.standard.object(forKey: "lastPlayedLasson") as? [String: Any],
           let duration = lastPlayedLessonInfo["duration"] as? Int,
           lastPlayedLesson.masechet != nil,
           lastPlayedLesson.maggidShiur != nil,
           lastPlayedLesson.page != nil,
           let lessonUrl = lastPlayedLesson.getUrl() {
            
            let title = "מסכת \(lastPlayedLesson.masechet.name!) דף \(lastPlayedLesson.page!.symbol!)"
            let subTitle = lastPlayedLesson.maggidShiur.name ?? ""
            
            LessonsManager.sharedManager.playingLesson = lastPlayedLesson
            
            // Auto-play the last lesson from saved position
            carPlayPlayerView.setTitle(title)
            carPlayPlayerView.setSubTitle(subTitle)
            carPlayPlayerView.startAutomatically = true
            carPlayPlayerView.setPlayerUrl(lessonUrl, duration: duration)
            return
        }
        
        // Otherwise, display today's daf (without auto-play)
        if LessonsManager.sharedManager.lessons.isEmpty {
            GetLessonsProcess().executeWithObject(nil, onStart: {
            }, onProgress: { [weak self] (object) in
                if let lessons = object as? [Lesson] {
                    LessonsManager.sharedManager.lessons = lessons
                    self?.displayTodaysDaf()
                }
            }, onComplete: { [weak self] (object) in
                if let lessons = object as? [Lesson] {
                    LessonsManager.sharedManager.lessons = lessons
                }
                self?.displayTodaysDaf()
            }, onFaile: { (object, error) in })
        } else {
            displayTodaysDaf()
        }
    }
    
    private func displayTodaysDaf() {
        guard let carPlayPlayerView = carPlayPlayerView else { return }
        guard let todaysMasechet = HadafHayomiManager.sharedManager.todaysMaschet,
              let todaysPage = HadafHayomiManager.sharedManager.todaysPage else { return }
        
        // Find the maggid shiur: default setting -> דוד קלופר -> first available
        var selectedMaggidShiur: MaggidShiur?
        
        if let defaultMaggidShiurName = UserDefaults.standard.object(forKey: "DefaultMagidShiour") as? String {
            selectedMaggidShiur = todaysMasechet.maggidShiurs.first(where: { $0.name == defaultMaggidShiurName })
        }
        
        if selectedMaggidShiur == nil {
            selectedMaggidShiur = todaysMasechet.maggidShiurs.first(where: { $0.name == "דוד קלופר" })
        }
        
        if selectedMaggidShiur == nil {
            selectedMaggidShiur = todaysMasechet.maggidShiurs.first
        }
        
        guard let maggidShiur = selectedMaggidShiur else { return }
        
        // Create a lesson for today's daf
        guard let lesson = LessonsManager.sharedManager.getLessonForMasechet(todaysMasechet, andMaggidShiour: maggidShiur) else { return }
        lesson.page = todaysPage
        
        guard let lessonUrl = lesson.getUrl() else { return }
        
        let title = "מסכת \(todaysMasechet.name!) דף \(todaysPage.symbol!)"
        let subTitle = maggidShiur.name ?? ""
        
        LessonsManager.sharedManager.playingLesson = lesson
        
        // Display only (don't auto-play today's daf)
        carPlayPlayerView.setPendingLesson(title: title, subTitle: subTitle, url: lessonUrl, duration: 0)
    }
    
    // MARK: - Helper Methods
    
    private func updateNowPlayingInfoPosition(position: TimeInterval) {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: position)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: carPlayPlayerView?.isPlaying == true ? 1.0 : 0.0)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupPeriodicUpdates() {
        // Invalidate existing timer if any
        updateTimer?.invalidate()
        
        // Setup timer to regularly update now playing info for responsive scroll bar
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self,
                  let carPlayPlayerView = self.carPlayPlayerView,
                  carPlayPlayerView.isPlaying else { return }
            
            let currentPosition = carPlayPlayerView.getCurrentPlaybackPosition()
            let totalDuration = carPlayPlayerView.getTotalDuration()
            
            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: currentPosition)
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: totalDuration)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: 1.0)
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
}
