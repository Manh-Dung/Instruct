# Flutter Permissions Quick Reference

## Dependencies
```yaml
dependencies:
  permission_handler: ^11.3.1
  geolocator: ^10.1.0
  device_info_plus: ^10.1.0
```

## Special Cases

### Location Approximate (Android 12+)
```dart
// permission_handler returns .denied but user granted approximate
final position = await Geolocator.getCurrentPosition();
bool isApproximate = position.accuracy > 1000;
```

### Storage (Android 13+)
```dart
// Use granular permissions instead of Permission.storage
if (androidInfo.version.sdkInt >= 33) {
  await [Permission.photos, Permission.videos, Permission.audio].request();
} else {
  await Permission.storage.request();
}
```

### Location Always (Android 10+)
```dart
// Must request in sequence
final whenInUse = await Permission.locationWhenInUse.request();
if (whenInUse.isGranted) {
  final always = await Permission.locationAlways.request();
}
```

### Notification (Android 13+)
```dart
// Only requestable on Android 13+, returns .denied on older versions
if (androidInfo.version.sdkInt >= 33) {
  await Permission.notification.request();
} else {
  // Always returns .denied, notifications enabled by default
}
```

## No Dialog Permissions
These open Settings directly:
- `Permission.notification`
- `Permission.bluetooth`
- `Permission.manageExternalStorage`
- `Permission.systemAlertWindow`

## Permission Behaviors

| Permission | Android 12- | Android 13+ | iOS | Notes |
|------------|-------------|-------------|-----|-------|
| `location` | Dialog | Dialog | Dialog | Approximate = `.denied` |
| `locationAlways` | 2-step | 2-step | Dialog | Cannot request directly |
| `storage` | Dialog | **Deprecated** | N/A | Use granular permissions |
| `notification` | **Always denied** | Dialog | Dialog | Only requestable on Android 13+ |
| `manageExternalStorage` | Settings | Settings | N/A | No popup |

## Quick Checks

```dart
// Check Android version
final androidInfo = await DeviceInfoPlugin().androidInfo;
bool isAndroid13Plus = androidInfo.version.sdkInt >= 33;

// Notification check
bool canRequestNotification = isAndroid13Plus;
if (!canRequestNotification) {
  // Notifications enabled by default on Android 12-
}

// Check if permission needs special handling
bool isSpecialPermission(Permission p) {
  return [
    Permission.notification,
    Permission.bluetooth,
    Permission.manageExternalStorage,
    Permission.systemAlertWindow,
  ].contains(p);
}

// Batch request
Map<Permission, PermissionStatus> results = await [
  Permission.camera,
  Permission.microphone,
].request();
```

## Common Patterns

```dart
// Smart request
final status = await permission.status;
if (status.isPermanentlyDenied) {
  await openAppSettings();
} else if (status.isDenied) {
  await permission.request();
}

// Location with fallback
try {
  final locationStatus = await Permission.location.request();
  if (locationStatus.isDenied) {
    final position = await Geolocator.getCurrentPosition();
    // Has approximate permission
  }
} catch (e) {
  // No location access
}
```