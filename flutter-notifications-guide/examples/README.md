# Flutter Notifications Guide Examples

Thư mục này chứa các file code example hoàn chỉnh để implement Flutter Local Notifications.

## 📁 Danh sách Files

### Core Files
- **`notification_service.dart`** - Service class chính để quản lý notifications
- **`reminder_service.dart`** - Service cho các loại reminder khác nhau
- **`reminder_app.dart`** - Demo app hoàn chỉnh với UI

## 🚀 Cách sử dụng

### 1. Copy code vào project
```bash
# Copy các file vào project Flutter của bạn
cp notification_service.dart your_project/lib/services/
cp reminder_service.dart your_project/lib/services/
cp reminder_app.dart your_project/lib/
```

### 2. Cập nhật dependencies
Đảm bảo `pubspec.yaml` có:
```yaml
dependencies:
  flutter_local_notifications: ^17.2.1+2
  flutter_timezone: ^3.0.1
  timezone: ^0.9.4
```

### 3. Configure native platforms
- Follow hướng dẫn trong `../configs/android_config.md`
- Follow hướng dẫn trong `../configs/ios_config.md`

### 4. Initialize trong main.dart
```dart
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().init();
  
  runApp(MyApp());
}
```

## 🎯 Ví dụ sử dụng

### Basic Notification
```dart
final notificationService = NotificationService();

// Gửi notification ngay lập tức
await notificationService.showInstantNotification(
  title: 'Hello!',
  body: 'This is a test notification',
);

// Schedule notification
await notificationService.scheduleNotification(
  id: 1,
  title: 'Reminder',
  body: 'Don\'t forget to drink water!',
  scheduledTime: DateTime.now().add(Duration(hours: 1)),
);
```

### Reminder Service
```dart
// Nhắc uống nước
await ReminderService.scheduleWaterReminder();

// Nhắc tập thể dục lúc 6:00 sáng
await ReminderService.scheduleWorkoutReminder(hour: 6, minute: 0);

// Hủy reminder
await ReminderService.cancelWaterReminder();
```

## 🔧 Customization

### Thay đổi notification sound
```dart
const androidDetails = AndroidNotificationDetails(
  'channel_id',
  'Channel Name',
  sound: RawResourceAndroidNotificationSound('custom_sound'),
);
```

### Thay đổi icon
```dart
const androidDetails = AndroidNotificationDetails(
  'channel_id',
  'Channel Name',
  icon: '@mipmap/custom_icon',
);
```

### Big text notification
```dart
await notificationService.showBigTextNotification(
  title: 'Long Title',
  body: 'Short body',
  bigText: 'This is a very long text that will be expanded...',
);
```

## 📝 Lưu ý

- **Lỗi compile**: Các file example này cần Flutter project hoàn chỉnh để compile
- **Imports**: Điều chỉnh import paths theo cấu trúc project của bạn
- **IDs**: Sử dụng unique IDs cho mỗi notification type
- **Testing**: Test trên real device, không phải emulator

## 🎨 UI Examples

File `reminder_app.dart` chứa:
- ✅ List active reminders
- ✅ Quick test actions
- ✅ Reminder type cards
- ✅ Schedule/cancel controls
- ✅ Progress notifications
- ✅ Big text notifications

## 🔄 Workflow

1. **Initialize** - Call `NotificationService().init()` trong main.dart
2. **Schedule** - Sử dụng các method trong `ReminderService`
3. **Manage** - Cancel, update, hoặc check pending notifications
4. **Handle** - Xử lý notification taps trong `onDidReceiveNotificationResponse`

## 🎓 Learning Path

1. **Bắt đầu** - Chạy `reminder_app.dart` để hiểu cách hoạt động
2. **Customize** - Thay đổi notification content và timing
3. **Extend** - Thêm reminder types mới
4. **Integrate** - Tích hợp vào app thực tế của bạn

Happy coding! 🚀
