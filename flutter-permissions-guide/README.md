# Flutter Permissions - Tham khảo nhanh

## Dependencies
```yaml
dependencies:
  permission_handler: ^11.3.1
  geolocator: ^10.1.0
  device_info_plus: ^10.1.0
```

## Trường hợp đặc biệt

### Location Approximate (Android 12+)
```dart
// permission_handler trả về .denied nhưng user đã cấp approximate
final position = await Geolocator.getCurrentPosition();
bool isApproximate = position.accuracy > 1000;
```

### Storage (Android 13+)
```dart
// Dùng granular permissions thay vì Permission.storage
if (androidInfo.version.sdkInt >= 33) {
  await [Permission.photos, Permission.videos, Permission.audio].request();
} else {
  await Permission.storage.request();
}
```

**iOS Podfile Configuration:**
```ruby
# Trong ios/Podfile, thêm vào post_install hook
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'PERMISSION_PHOTOS=1'
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'PERMISSION_PHOTOS_ADD_ONLY=1'
    end
  end
end
```

**iOS Info.plist Configuration:**
```xml
<!-- Trong ios/Runner/Info.plist -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Ứng dụng cần quyền truy cập thư viện ảnh để hiển thị và lưu nội dung.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Ứng dụng cần quyền lưu ảnh/video vào thư viện.</string>
```

### Location Always (Android 10+)
```dart
// Phải request theo thứ tự
final whenInUse = await Permission.locationWhenInUse.request();
if (whenInUse.isGranted) {
  final always = await Permission.locationAlways.request();
}
```

### Notification (Android 13+)
```dart
// Chỉ request được trên Android 13+, trả về .denied trên phiên bản cũ
if (androidInfo.version.sdkInt >= 33) {
  await Permission.notification.request();
} else {
  // Luôn trả về .denied, notifications được bật mặc định
}
```

**iOS Podfile Configuration:**
```ruby
# Trong ios/Podfile, thêm vào post_install hook
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1'
      ]
    end
  end
end
```

**iOS Info.plist Configuration:**
```xml
<!-- Trong ios/Runner/Info.plist -->
<key>NSUserNotificationUsageDescription</key>
<string>Ứng dụng cần quyền gửi thông báo để nhắc nhở và cập nhật nội dung.</string>
```

## Permissions không có Dialog
Các quyền này mở Settings trực tiếp:
- `Permission.notification`
- `Permission.bluetooth`
- `Permission.manageExternalStorage`
- `Permission.systemAlertWindow`

## Hành vi Permissions

| Permission | Android 12- | Android 13+ | iOS | Ghi chú |
|------------|-------------|-------------|-----|---------|
| `location` | Dialog | Dialog | Dialog | Approximate = `.denied` |
| `locationAlways` | 2 bước | 2 bước | Dialog | Không thể request trực tiếp |
| `storage` | Dialog | **Deprecated** | N/A | Dùng granular permissions |
| `notification` | **Luôn denied** | Dialog | Dialog | Chỉ request được trên Android 13+ |
| `manageExternalStorage` | Settings | Settings | N/A | Không có popup |

## Kiểm tra nhanh

```dart
// Kiểm tra phiên bản Android
final androidInfo = await DeviceInfoPlugin().androidInfo;
bool isAndroid13Plus = androidInfo.version.sdkInt >= 33;

// Kiểm tra notification
bool canRequestNotification = isAndroid13Plus;
if (!canRequestNotification) {
  // Notifications được bật mặc định trên Android 12-
}

// Kiểm tra permission cần xử lý đặc biệt
bool isSpecialPermission(Permission p) {
  return [
    Permission.notification,
    Permission.bluetooth,
    Permission.manageExternalStorage,
    Permission.systemAlertWindow,
  ].contains(p);
}

// Request nhiều permissions cùng lúc
Map<Permission, PermissionStatus> results = await [
  Permission.camera,
  Permission.microphone,
].request();
```

## Patterns thường dùng

```dart
// Request thông minh
final status = await permission.status;
if (status.isPermanentlyDenied) {
  await openAppSettings();
} else if (status.isDenied) {
  await permission.request();
}

// Location với fallback
try {
  final locationStatus = await Permission.location.request();
  if (locationStatus.isDenied) {
    final position = await Geolocator.getCurrentPosition();
    // Có approximate permission
  }
} catch (e) {
  // Không có quyền truy cập location
}
```