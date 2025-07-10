# iOS Info.plist Configuration

File: `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ========== STANDARD PERMISSIONS ========== -->
    
    <!-- Location permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location access to provide location-based features.</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app needs background location access to track your location even when the app is closed.</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>This app needs background location access to track your location even when the app is closed.</string>

    <!-- Camera permission -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to take photos and videos.</string>

    <!-- Photo library permission -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs photo library access to save and select images.</string>
    
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>This app needs permission to save photos to your photo library.</string>

    <!-- Microphone permission -->
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs microphone access to record audio.</string>

    <!-- Contacts permission -->
    <key>NSContactsUsageDescription</key>
    <string>This app needs contacts access to import your contacts.</string>

    <!-- Calendar permission -->
    <key>NSCalendarsUsageDescription</key>
    <string>This app needs calendar access to create and manage events.</string>

    <!-- Reminders permission -->
    <key>NSRemindersUsageDescription</key>
    <string>This app needs reminders access to create and manage reminders.</string>

    <!-- Motion & Fitness permission -->
    <key>NSMotionUsageDescription</key>
    <string>This app needs motion data access to track your activity.</string>

    <!-- Speech recognition permission -->
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>This app needs speech recognition access to convert speech to text.</string>

    <!-- Bluetooth permission -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app needs Bluetooth access to connect to external devices.</string>
    
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>This app needs Bluetooth access to connect to external devices.</string>

    <!-- Face ID / Touch ID permission -->
    <key>NSFaceIDUsageDescription</key>
    <string>This app uses Face ID for secure authentication.</string>

    <!-- Media Library permission -->
    <key>NSAppleMusicUsageDescription</key>
    <string>This app needs media library access to play music.</string>

    <!-- Notification permission (handled in code) -->
    <!-- iOS doesn't require Info.plist entry for notifications -->

    <!-- ========== BACKGROUND MODES ========== -->
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
        <string>background-fetch</string>
        <string>background-processing</string>
    </array>

    <!-- ========== OTHER SETTINGS ========== -->
    
    <!-- App Transport Security -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>

    <!-- Prevent backup to iCloud -->
    <key>NSDocumentsSaveInApplicationSupportToPreventBackup</key>
    <true/>

    <!-- Standard iOS app settings -->
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    
    <key>CFBundleDisplayName</key>
    <string>Your App Name</string>
    
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    
    <key>CFBundleName</key>
    <string>your_app</string>
    
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    
    <key>CFBundleSignature</key>
    <string>????</string>
    
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    
    <key>LSRequiresIPhoneOS</key>
    <true/>
    
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>
    
    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>
    
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
</dict>
</plist>
```

## ⚠️ Lưu ý về iOS Permissions

### Location Permissions
- `NSLocationWhenInUseUsageDescription`: Cần thiết cho location when in use
- `NSLocationAlwaysAndWhenInUseUsageDescription`: Cho iOS 11+ background location
- `NSLocationAlwaysUsageDescription`: Cho iOS 10 và cũ hơn

### Permission Flow
1. iOS luôn hiển thị dialog cho permissions (khác Android)
2. User chỉ được hỏi 1 lần, sau đó phải vào Settings
3. Không có "approximate" location như Android

### Background Modes
- Chỉ thêm background modes khi thật sự cần thiết
- Apple review rất nghiêm ngặt về background usage

## 🔧 Deployment Target

Minimum iOS version để support permissions đầy đủ:

```
iOS 12.0+
```

Set trong `ios/Flutter/AppFrameworkInfo.plist`:
```xml
<key>MinimumOSVersion</key>
<string>12.0</string>
```

## 📱 iOS Version Considerations

| iOS Version | Changes |
|-------------|---------|
| 15.0+ | Enhanced location privacy |
| 14.0+ | App Tracking Transparency required |
| 13.0+ | Background app refresh changes |
| 12.0+ | Screen Time API |
| 11.0+ | New location permission flow |
