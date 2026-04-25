//
//  CarPlayManager.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 04/03/2026.
//

import Foundation
import UIKit
import CarPlay
import MediaPlayer

class CarPlayManager: NSObject {
    
    static let shared = CarPlayManager()
    
    private var carPlayPlayerView: CarPlayPlayerView?
    private var interfaceController: CPInterfaceController?
    private var isCarPlayConnected = false
    
    override init() {
        super.init()
        setupNotifications()
    }
    
    // MARK: - Setup
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(carPlayDidConnect(_:)),
            name: UIScene.didActivateNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(carPlayDidDisconnect(_:)),
            name: UIScene.didDisconnectNotification,
            object: nil
        )
    }
    
    // MARK: - CarPlay Connection Handling
    
    @objc private func carPlayDidConnect(_ notification: Notification) {
        // Check if this is a CarPlay scene
        guard let scene = notification.object as? CPTemplateApplicationScene else { return }
        
        isCarPlayConnected = true
        interfaceController = scene.interfaceController
        setupCarPlayInterface()
    }
    
    @objc private func carPlayDidDisconnect(_ notification: Notification) {
        // Check if this is a CarPlay scene
        guard notification.object is CPTemplateApplicationScene else { return }
        
        isCarPlayConnected = false
        interfaceController = nil
        carPlayPlayerView = nil
    }
    
    private func setupCarPlayInterface() {
        guard let interfaceController = interfaceController else { return }
        
        // Create the CarPlay player view
        carPlayPlayerView = CarPlayPlayerView()
        carPlayPlayerView?.delegate = self
        
        // Create and set up the now playing template
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        interfaceController.setRootTemplate(nowPlayingTemplate, animated: false, completion: nil)
        
        // Set up the now playing buttons
        setupNowPlayingButtons()
        
        // Configure media remote commands
        setupMediaRemoteCommands()
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
        
        // Jump forward button (30 seconds)
        let jumpForwardButton = CPNowPlayingImageButton(image: UIImage(systemName: "goforward.30")!) { [weak self] button in
            carPlayPlayerView.jumpForward()
        }
        
        // Jump backward button (30 seconds)
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
        
        // Clear any existing targets
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.skipForwardCommand.removeTarget(nil)
        commandCenter.skipBackwardCommand.removeTarget(nil)
        commandCenter.changePlaybackPositionCommand.removeTarget(nil)
        
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
        
        // Change playback position command
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self?.carPlayPlayerView?.setDuration(Int(event.positionTime))
            return .success
        }
    }
    
    // MARK: - Public Interface
    
    var isConnected: Bool {
        return isCarPlayConnected
    }
    
    func updateCarPlayWithPhonePlayerState(
        title: String? = nil,
        subTitle: String? = nil,
        url: URL? = nil,
        isPlaying: Bool? = nil,
        duration: Int? = nil
    ) {
        // Phone player state is synced via notifications handled by
        // CarPlaySceneDelegate's CarPlayPlayerView. This method is kept
        // as a no-op to avoid double-loading URLs into the shared player.
    }
    
    func getCarPlayPlayerView() -> CarPlayPlayerView? {
        return carPlayPlayerView
    }
}

// MARK: - CarPlayPlayerViewDelegate

extension CarPlayManager: CarPlayPlayerViewDelegate {
    
    func carPlayPlayerDidPlay() {
        // CarPlay started playing - this will be handled by the notification system
        print("CarPlay player started playing")
    }
    
    func carPlayPlayerDidPause() {
        // CarPlay paused - this will be handled by the notification system
        print("CarPlay player paused")
    }
    
    func carPlayPlayerDidChangeDuration(_ duration: Int) {
        // CarPlay changed duration - this will be handled by the notification system
        print("CarPlay player changed duration to: \(duration)")
    }
    
    func carPlayPlayerDidFinishPlaying() {
        // CarPlay finished playing
        print("CarPlay player finished playing")
    }
    
    func carPlayPlayerDidCancelWithError(_ error: Error?) {
        // CarPlay encountered an error
        if let error = error {
            print("CarPlay player error: \(error.localizedDescription)")
        } else {
            print("CarPlay player cancelled")
        }
    }
}