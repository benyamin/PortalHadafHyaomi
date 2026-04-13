//
//  CarPlayImplementationGuide.md
//  PortalHdafHyomi
//
//  CarPlay Implementation Guide
//

# CarPlay Player Implementation Guide

This guide explains how to integrate the CarPlay player functionality with your existing BTPlayerView.

## Overview

The implementation provides a complete CarPlay audio player that synchronizes bidirectionally with your phone app's BTPlayerView. Changes made on either the phone or CarPlay interface are reflected on both platforms.

## Files Added

### 1. `CarPlaySceneDelegate.swift`
- Manages the CarPlay scene lifecycle
- Sets up the CarPlay interface and templates
- Handles CarPlay connection and disconnection

### 2. `CarPlayPlayerView.swift`
- Main CarPlay player implementation
- Mirrors BTPlayerView functionality for CarPlay
- Handles audio playback, seeking, and controls
- Manages bidirectional synchronization with phone app

### 3. `CarPlayManager.swift`
- Singleton manager for CarPlay coordination
- Handles communication between phone app and CarPlay
- Manages CarPlay connection state

### 4. `CarPlayInfoPlistConfiguration.txt`
- Required Info.plist configurations for CarPlay support

## Key Features

### Functionality Mirrored from BTPlayerView:
- ✅ Play/Pause controls
- ✅ Jump forward/backward (30 seconds by default)
- ✅ Playback rate adjustment (0.5x to 2.0x)
- ✅ Progress seeking
- ✅ Title and subtitle display
- ✅ Loading states
- ✅ Error handling
- ✅ Now Playing info center integration
- ✅ Remote control command support

### Bidirectional Synchronization:
- ✅ Play/pause state sync
- ✅ Playback position sync
- ✅ Title/subtitle sync
- ✅ URL changes sync
- ✅ Playback rate sync

## Setup Instructions

### 1. Info.plist Configuration
Add the CarPlay scene configuration to your Info.plist (see `CarPlayInfoPlistConfiguration.txt`):

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>CPTemplateApplicationSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>CarPlay</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).CarPlaySceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>
```

### 2. Entitlements
Ensure your app has the CarPlay entitlement in your App Store Connect app configuration:
- Log into App Store Connect
- Go to your app → Features → CarPlay
- Enable CarPlay support
- Select "Audio" as the CarPlay app category

### 3. Build Configuration
- Add the CarPlay framework to your target
- Ensure your provisioning profile includes the CarPlay entitlement
- Set minimum iOS deployment target to iOS 12.0 or later

### 4. Integration Points

The implementation automatically integrates with your existing BTPlayerView through:

#### BTPlayerView Modifications:
- Added CarPlay synchronization methods
- Notification system for state changes
- Direct CarPlayManager integration

#### Usage in Your App:
No additional code needed - the synchronization happens automatically when:
- User connects to CarPlay
- BTPlayerView state changes (play, pause, seek, etc.)
- CarPlay controls are used

## How It Works

### 1. CarPlay Connection
When a user connects to CarPlay:
```
1. CarPlaySceneDelegate.templateApplicationScene(_:didConnect:) called
2. CarPlayManager.shared setup is triggered
3. CarPlayPlayerView instance is created
4. CPNowPlayingTemplate is configured with controls
5. Media remote commands are set up
```

### 2. Phone to CarPlay Sync
When BTPlayerView state changes:
```
1. BTPlayerView calls notifyCarPlayOfStateChange()
2. Notification sent to CarPlayPlayerView
3. CarPlayManager.updateCarPlayWithPhonePlayerState() called
4. CarPlay UI updates automatically
5. Now Playing info center updates
```

### 3. CarPlay to Phone Sync
When CarPlay controls are used:
```
1. CarPlayPlayerView performs action
2. Notification sent to BTPlayerView
3. BTPlayerView UI updates accordingly
4. Shared player state maintained
```

## User Interface

### CarPlay Screen
- **Now Playing Template**: Shows current track info, artwork, and playback progress
- **Control Buttons**: Play/pause, jump forward/back, speed adjustment
- **Progress Bar**: Shows current position, supports seeking
- **Metadata Display**: Shows title, subtitle, and album artwork

### Phone Integration
- No visual changes to existing BTPlayerView
- Existing functionality preserved
- Synchronization happens transparently

## Testing

### 1. CarPlay Simulator
- Use iOS Simulator with CarPlay support
- Window → External Display → CarPlay
- Test all playback functions

### 2. Physical CarPlay
- Connect iPhone to CarPlay-enabled vehicle or aftermarket unit
- Test audio playback and controls
- Verify synchronization between phone and CarPlay

### 3. Test Scenarios
- Start playback on phone, control from CarPlay
- Start playback on CarPlay, control from phone
- Seek position on both interfaces
- Change playback speed from CarPlay
- Switch between different audio tracks

## Troubleshooting

### Common Issues:

1. **CarPlay not connecting:**
   - Verify Info.plist configuration
   - Check CarPlay entitlement in provisioning profile
   - Ensure minimum iOS version (12.0+)

2. **Audio not playing in CarPlay:**
   - Check AVAudioSession configuration
   - Verify background audio capability
   - Ensure proper Now Playing info setup

3. **Synchronization not working:**
   - Check NotificationCenter observers
   - Verify CarPlayManager initialization
   - Test notification posting and receiving

4. **Controls not responding:**
   - Verify MPRemoteCommandCenter setup
   - Check CarPlay button configuration
   - Ensure proper target-action connections

## Advanced Customization

### Custom Control Buttons
You can customize CarPlay buttons by modifying `setupNowPlayingButtons()` in `CarPlaySceneDelegate.swift`:

```swift
let customButton = CPNowPlayingImageButton(image: UIImage(systemName: "heart")!) { button in
    // Custom action
}
```

### Custom Metadata
Modify the Now Playing info by updating `updateNowPlayingInfo()` in `CarPlayPlayerView.swift`:

```swift
var playingInfo: [String: Any] = [
    MPMediaItemPropertyArtist: currentTitle,
    MPMediaItemPropertyTitle: currentSubTitle,
    // Add custom metadata fields
    "customField": customValue
]
```

### Jump Intervals
Jump intervals automatically use the user preference stored in `selectedLessonSkipInterval` UserDefaults key, maintaining consistency with BTPlayerView.

## Security Considerations

- All communication between phone and CarPlay happens locally
- No external network requests for sync functionality  
- User privacy maintained through Apple's CarPlay framework
- Audio session management follows Apple's guidelines

## Performance Notes

- Minimal impact on existing BTPlayerView performance
- CarPlay UI updates are throttled to prevent excessive refreshing
- Memory management handled through weak references
- Automatic cleanup when CarPlay disconnects

## Future Enhancements

Potential improvements that could be added:

1. **Playlist Support**: Show list of available lessons/tracks
2. **Voice Control**: Siri integration for hands-free control
3. **Custom UI**: More detailed CarPlay-specific interface
4. **Offline Sync**: Better handling of network connectivity changes
5. **Analytics**: Track CarPlay usage patterns

---

This implementation provides a complete CarPlay integration that maintains full compatibility with your existing BTPlayerView while adding comprehensive vehicle integration capabilities.