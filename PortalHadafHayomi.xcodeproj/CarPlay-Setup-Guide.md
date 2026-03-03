# CarPlay Integration Setup Guide

## 1. Info.plist Configuration

Add the following entries to your app's Info.plist file:

```xml
<!-- CarPlay Support -->
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>UIWindowSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                <key>UISceneStoryboardFile</key>
                <string>Main</string>
            </dict>
        </array>
        <!-- CarPlay Scene Configuration -->
        <key>CPTemplateApplicationSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>CarPlay Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).CarPlaySceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>

<!-- Required Device Capabilities -->
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arm64</string>
</array>

<!-- Background Modes -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>

<!-- Audio Session Category -->
<key>AVAudioSessionCategory</key>
<string>AVAudioSessionCategoryPlayback</string>
```

## 2. Entitlements

Add the following to your app's entitlements file:

```xml
<!-- CarPlay Audio App Entitlement -->
<key>com.apple.developer.carplay-audio</key>
<true/>
```

## 3. CarPlay Framework

Make sure to import the CarPlay framework in your project:

1. Select your project target
2. Go to "Build Phases" → "Link Binary With Libraries"
3. Add "CarPlay.framework"

## 4. Usage Notes

- CarPlay is only supported on iOS 13.0 and later
- Testing requires a physical CarPlay-enabled vehicle or CarPlay Simulator in Xcode
- Audio must be configured properly for background playback
- The app must be approved by Apple for CarPlay integration in the App Store

## 5. Testing

1. Use the CarPlay Simulator in Xcode (I/O → External Displays → CarPlay)
2. Test with a physical CarPlay-enabled vehicle
3. Verify all audio controls work properly
4. Test navigation between masecht, daf, and magid shiur selections
5. Ensure Now Playing information displays correctly

## 6. App Store Requirements

Before submitting to the App Store:
- Request CarPlay entitlement from Apple
- Ensure your app follows CarPlay Human Interface Guidelines
- Test thoroughly with CarPlay Simulator and real devices
- Document CarPlay functionality in your app description