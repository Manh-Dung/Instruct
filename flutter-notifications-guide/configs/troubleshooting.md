# Troubleshooting Flutter Local Notifications

## 🚨 Lỗi thường gặp và cách khắc phục

### 1. **Notification không hiển thị**

#### Nguyên nhân:
- Chưa request permission
- App đang ở foreground (iOS)
- Notification settings bị tắt

#### Cách khắc phục:
```dart
// Kiểm tra permission
Future<bool> checkPermission() async {
  final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  return await androidImpl?.areNotificationsEnabled() ?? false;
}

// Request permission
await _notifications
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
```

### 2. **Timezone Error**

#### Lỗi:
```
RangeError: Invalid argument(s): Invalid timezone
```

#### Cách khắc phục:
```dart
Future<void> _configureTimezone() async {
  tz.initializeTimeZones();
  try {
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    print('Timezone error: $e');
    // Fallback to UTC
    tz.setLocalLocation(tz.getLocation('UTC'));
  }
}
```

### 3. **Android 13+ Permission Issues**

#### Lỗi:
```
Notifications are not allowed for this app
```

#### Cách khắc phục:
1. Thêm vào `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

2. Request runtime permission:
```dart
if (Platform.isAndroid) {
  await _notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}
```

### 4. **Exact Alarm Permission**

#### Lỗi:
```
Cannot schedule exact alarm
```

#### Cách khắc phục:
1. Thêm permission:
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

2. Request permission:
```dart
await _notifications
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestExactAlarmsPermission();
```

### 5. **Notification không hoạt động sau khi app bị kill**

#### Nguyên nhân:
- Chưa setup Boot Receiver
- Sai AndroidScheduleMode

#### Cách khắc phục:
1. Thêm Boot Receiver:
```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    </intent-filter>
</receiver>
```

2. Sử dụng đúng schedule mode:
```dart
await _notifications.zonedSchedule(
  id,
  title,
  body,
  scheduledDate,
  details,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
);
```

### 6. **iOS Notification không hiển thị khi app đang mở**

#### Nguyên nhân:
- Thiếu UNUserNotificationCenterDelegate

#### Cách khắc phục:
Thêm vào `AppDelegate.swift`:
```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
) {
    completionHandler([.alert, .badge, .sound])
}
```

### 7. **Notification ID bị trùng**

#### Vấn đề:
- Notification mới ghi đè notification cũ

#### Cách khắc phục:
```dart
// Sử dụng unique ID
final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

// Hoặc sử dụng counter
static int _notificationIdCounter = 0;
static int get nextNotificationId => ++_notificationIdCounter;
```

### 8. **Không thể cancel notification**

#### Nguyên nhân:
- Sai ID
- Notification đã được trigger

#### Cách khắc phục:
```dart
// Lưu ID khi schedule
final Map<String, int> _notificationIds = {};

// Schedule với ID tracking
_notificationIds['water_reminder'] = id;
await _notifications.zonedSchedule(...);

// Cancel với đúng ID
final id = _notificationIds['water_reminder'];
if (id != null) {
  await _notifications.cancel(id);
}
```

### 9. **Build errors**

#### Lỗi Gradle:
```
Could not resolve all artifacts for configuration ':app:debugRuntimeClasspath'
```

#### Cách khắc phục:
1. Cập nhật `android/app/build.gradle`:
```gradle
dependencies {
    implementation 'androidx.core:core:1.10.1'
    implementation 'androidx.annotation:annotation:1.7.0'
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.3'
}
```

2. Clean và rebuild:
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter build apk
```

### 10. **iOS Build errors**

#### Lỗi CocoaPods:
```
[!] Unable to find a specification for `flutter_local_notifications`
```

#### Cách khắc phục:
```bash
cd ios
pod cache clean --all
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

## 🔧 Debug Tools

### 1. Kiểm tra pending notifications:
```dart
Future<void> debugPendingNotifications() async {
  final pending = await _notifications.pendingNotificationRequests();
  print('=== PENDING NOTIFICATIONS ===');
  print('Total: ${pending.length}');
  
  for (final notification in pending) {
    print('ID: ${notification.id}');
    print('Title: ${notification.title}');
    print('Body: ${notification.body}');
    print('---');
  }
}
```

### 2. Test notification settings:
```dart
Future<void> testNotificationSettings() async {
  // Check if notifications are enabled
  final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  final enabled = await androidImpl?.areNotificationsEnabled() ?? false;
  print('Notifications enabled: $enabled');
  
  // Test immediate notification
  await _notifications.show(
    999,
    'Test Notification',
    'If you see this, notifications are working!',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Channel',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );
}
```

### 3. Validate timezone:
```dart
Future<void> validateTimezone() async {
  try {
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    final location = tz.getLocation(timeZoneName);
    final now = tz.TZDateTime.now(location);
    
    print('Timezone: $timeZoneName');
    print('Current time: $now');
    print('UTC offset: ${now.timeZoneOffset}');
  } catch (e) {
    print('Timezone validation failed: $e');
  }
}
```

## 📱 Platform-specific Issues

### Android
- **Battery optimization**: Một số device có thể kill app, cần whitelist app
- **Doze mode**: Android 6+ có thể delay notifications
- **Notification channels**: Android 8+ yêu cầu notification channels

### iOS
- **Background restrictions**: iOS nghiêm ngặt hơn về background processing
- **Notification delivery**: Có thể bị delay nếu device ở power saving mode
- **Permission prompts**: Chỉ hiển thị 1 lần, sau đó user phải vào Settings

## 🎯 Best Practices

1. **Always test on real devices** - Emulator có thể không hoạt động đúng
2. **Handle permissions gracefully** - Có fallback khi user từ chối permission
3. **Use unique IDs** - Tránh conflict giữa các notifications
4. **Test timezone edge cases** - Đặc biệt khi có daylight saving time
5. **Implement proper error handling** - Catch và log exceptions
6. **Test on different Android versions** - Behavior có thể khác nhau
7. **Consider battery optimization** - Hướng dẫn user whitelist app nếu cần

## 🔗 Useful Resources

- [Flutter Local Notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [Android Notification Documentation](https://developer.android.com/develop/ui/views/notifications)
- [iOS UserNotifications Documentation](https://developer.apple.com/documentation/usernotifications)
- [Flutter Timezone Documentation](https://pub.dev/packages/flutter_timezone)
