//
//  CarPlayIntegrationTests.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 04/03/2026.
//

import Foundation
import AVFoundation
import MediaPlayer

// Simple test runner without external dependencies
class CarPlayIntegrationTests {
    
    static func runAllTests() {
        print("🚗 Running CarPlay Integration Tests...")
        
        testCarPlayManagerSingleton()
        testCarPlayManagerInitialState()
        testCarPlayPlayerViewInitialization()
        testTitleAndSubtitleSetting()
        testPlayerURLSetting()
        testJumpForwardBackward()
        testPlaybackRateChange()
        testDurationSetting()
        testInvalidURLHandling()
        testNegativeDurationHandling()
        testLargeDurationHandling()
        testCarPlayManagerUpdateMethod()
        testNotificationCenterCleanup()
        
        print("✅ All CarPlay Integration Tests Completed!")
    }
    
    // MARK: - Test Helper
    
    private static func assert(_ condition: Bool, _ message: String, file: String = #file, line: Int = #line) {
        if condition {
            print("✅ \(message)")
        } else {
            print("❌ FAILED: \(message) at \(file):\(line)")
        }
    }
    
    // MARK: - CarPlayManager Tests
    
    static func testCarPlayManagerSingleton() {
        let manager1 = CarPlayManager.shared
        let manager2 = CarPlayManager.shared
        
        assert(manager1 === manager2, "CarPlayManager should be a singleton")
    }
    
    static func testCarPlayManagerInitialState() {
        let carPlayManager = CarPlayManager.shared
        
        assert(!carPlayManager.isConnected, "CarPlay should not be connected initially")
        assert(carPlayManager.getCarPlayPlayerView() == nil, "CarPlayPlayerView should be nil initially")
    }
    
    // MARK: - CarPlayPlayerView Tests
    
    static func testCarPlayPlayerViewInitialization() {
        let carPlayPlayerView = CarPlayPlayerView()
        
        assert(carPlayPlayerView.isPlaying == false, "Player should not be playing initially")
    }
    
    static func testTitleAndSubtitleSetting() {
        let carPlayPlayerView = CarPlayPlayerView()
        let testTitle = "Test Lesson Title"
        let testSubTitle = "Test Lesson Subtitle"
        
        // Test that setting title and subtitle doesn't crash
        carPlayPlayerView.setTitle(testTitle)
        carPlayPlayerView.setSubTitle(testSubTitle)
        
        assert(true, "Setting title and subtitle should not crash")
    }
    
    static func testPlayerURLSetting() {
        let carPlayPlayerView = CarPlayPlayerView()
        let testURL = URL(string: "https://example.com/test-audio.mp3")!
        
        carPlayPlayerView.setPlayerUrl(testURL)
        
        // Test that the URL setting doesn't crash and basic state is maintained
        assert(!carPlayPlayerView.isPlaying, "Player should not be playing after URL set")
    }
    
    static func testJumpForwardBackward() {
        let carPlayPlayerView = CarPlayPlayerView()
        
        // These methods should not crash even without a loaded URL
        carPlayPlayerView.jumpForward()
        carPlayPlayerView.jumpBackward()
        
        assert(true, "Jump methods should not crash without loaded URL")
    }
    
    static func testPlaybackRateChange() {
        let carPlayPlayerView = CarPlayPlayerView()
        
        // Test that playback rate changes don't crash
        carPlayPlayerView.changePlaybackRate()
        
        assert(true, "Playback rate changes should not crash")
    }
    
    static func testDurationSetting() {
        let carPlayPlayerView = CarPlayPlayerView()
        let testDuration = 120 // 2 minutes
        
        carPlayPlayerView.setDuration(testDuration)
        
        assert(true, "Setting duration should not crash")
    }
    
    // MARK: - Error Handling Tests
    
    static func testInvalidURLHandling() {
        let carPlayPlayerView = CarPlayPlayerView()
        
        // Test with nil URL
        carPlayPlayerView.setPlayerUrl(nil)
        
        // Test with invalid URL
        let invalidURL = URL(string: "invalid://url")
        carPlayPlayerView.setPlayerUrl(invalidURL)
        
        assert(true, "Invalid URL handling should not crash")
    }
    
    static func testNegativeDurationHandling() {
        let carPlayPlayerView = CarPlayPlayerView()
        
        // Test with negative duration
        carPlayPlayerView.setDuration(-10)
        
        assert(true, "Negative duration should not crash")
    }
    
    static func testLargeDurationHandling() {
        let carPlayPlayerView = CarPlayPlayerView()
        
        // Test with very large duration
        carPlayPlayerView.setDuration(Int.max)
        
        assert(true, "Large duration should not crash")
    }
    
    // MARK: - Integration Tests
    
    static func testCarPlayManagerUpdateMethod() {
        let carPlayManager = CarPlayManager.shared
        let testTitle = "Integration Test Title"
        let testSubTitle = "Integration Test Subtitle"
        let testURL = URL(string: "https://example.com/test.mp3")!
        
        carPlayManager.updateCarPlayWithPhonePlayerState(
            title: testTitle,
            subTitle: testSubTitle,
            url: testURL,
            isPlaying: true,
            duration: 60
        )
        
        assert(true, "CarPlayManager update should not crash")
    }
    
    static func testNotificationCenterCleanup() {
        // Create a player view and then deinitialize it
        var playerView: CarPlayPlayerView? = CarPlayPlayerView()
        
        // Set up some state
        playerView?.setTitle("Test Title")
        
        // Release the player view
        playerView = nil
        
        // Post a notification that the deallocated player would have been listening for
        NotificationCenter.default.post(
            name: NSNotification.Name("BTPlayerViewDidUpdateState"),
            object: nil,
            userInfo: ["test": "value"]
        )
        
        assert(true, "Notification cleanup should not crash")
    }
}

// MARK: - Usage Example
// To run tests, call: CarPlayIntegrationTests.runAllTests()
