# Flutter Local Notifications - Hướng dẫn Setup và Sử dụng

## 🎯 Tổng quan
Flutter Local Notifications giúp gửi thông báo local (không qua server) để nhắc nhở người dùng về:
- Công việc hàng ngày
- Thói quen cần duy trì  
- Sự kiện quan trọng
- Deadline dự án

## 📦 Cài đặt nhanh

### 1. Dependencies trong `pubspec.yaml`:
```yaml
dependencies:
  flutter_local_notifications: ^17.2.1+2
  flutter_timezone: ^3.0.1
  timezone: ^0.9.4
```

### 2. Android Setup:
#### `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />

<application>
    <!-- Receivers -->
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"/>
            <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        </intent-filter>
    </receiver>
</application>
```

### 3. iOS Setup:
#### `ios/Runner/Info.plist`:
```xml
<dict>
    <key>UIBackgroundModes</key>
    <array>
        <string>background-fetch</string>
        <string>background-processing</string>
    </array>
</dict>
```

## ⚙️ Setup cơ bản

### 1. Tạo NotificationService:
```dart
// notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Setup timezone
    await _configureTimezone();
    
    // Initialize notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    
    // Request permissions
    await _requestPermissions();
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }
}
```

### 2. Khởi tạo trong `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().init();
  
  runApp(MyApp());
}
```

## 🚀 Các loại notification cơ bản

### 1. Instant Notification (Ngay lập tức):
```dart
Future<void> showInstantNotification({
  required String title,
  required String body,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'instant_channel',
    'Instant Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );
  
  const iosDetails = DarwinNotificationDetails();
  
  await _notifications.show(
    0,
    title,
    body,
    const NotificationDetails(android: androidDetails, iOS: iosDetails),
  );
}
```

### 2. Scheduled Notification (Hẹn giờ):
```dart
Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'scheduled_channel',
    'Scheduled Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );
  
  await _notifications.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledTime, tz.local),
    const NotificationDetails(android: androidDetails),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

### 3. Recurring Notification (Lặp lại):
```dart
Future<void> scheduleRepeatingNotification({
  required int id,
  required String title,
  required String body,
  required RepeatInterval interval,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'repeat_channel',
    'Repeating Notifications',
    importance: Importance.high,
  );
  
  await _notifications.periodicallyShow(
    id,
    title,
    body,
    interval,
    const NotificationDetails(android: androidDetails),
  );
}
```

## 💡 Ví dụ thực tế

### 1. Reminder App - Nhắc nhở công việc

```dart
// reminder_service.dart
class ReminderService {
  static final NotificationService _notificationService = NotificationService();
  
  // Nhắc uống nước mỗi 2 giờ
  static Future<void> scheduleWaterReminder() async {
    await _notificationService.scheduleRepeatingNotification(
      id: 1,
      title: '💧 Uống nước nào!',
      body: 'Đã 2 giờ rồi, nhớ uống nước để khỏe mạnh nhé!',
      interval: RepeatInterval.everyMinute, // Demo - thực tế dùng custom interval
    );
  }
  
  // Nhắc tập thể dục
  static Future<void> scheduleWorkoutReminder() async {
    // Tập thể dục lúc 6:00 sáng hàng ngày
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, 6, 0);
    
    await _notificationService.scheduleNotification(
      id: 2,
      title: '🏃‍♂️ Workout Time!',
      body: 'Đã đến giờ tập thể dục. Hãy bắt đầu ngày mới với năng lượng!',
      scheduledTime: scheduledTime,
    );
  }
  
  // Nhắc nghỉ giải lao khi làm việc
  static Future<void> scheduleBreakReminder() async {
    await _notificationService.scheduleRepeatingNotification(
      id: 3,
      title: '☕ Break Time!',
      body: 'Đã làm việc 1 giờ rồi, hãy nghỉ giải lao 5 phút nhé!',
      interval: RepeatInterval.hourly,
    );
  }
}
```

### 2. Event Notifier - Thông báo sự kiện

```dart
// event_service.dart
class EventService {
  static final NotificationService _notificationService = NotificationService();
  
  // Nhắc meeting
  static Future<void> scheduleMeetingReminder({
    required String title,
    required DateTime meetingTime,
    required int minutesBefore,
  }) async {
    final reminderTime = meetingTime.subtract(Duration(minutes: minutesBefore));
    
    await _notificationService.scheduleNotification(
      id: meetingTime.millisecondsSinceEpoch ~/ 1000,
      title: '📅 Meeting Reminder',
      body: '$title sẽ bắt đầu sau $minutesBefore phút',
      scheduledTime: reminderTime,
    );
  }
  
  // Nhắc deadline
  static Future<void> scheduleDeadlineReminder({
    required String taskName,
    required DateTime deadlineDate,
  }) async {
    // Nhắc trước 1 ngày
    final reminderTime = deadlineDate.subtract(const Duration(days: 1));
    
    await _notificationService.scheduleNotification(
      id: deadlineDate.millisecondsSinceEpoch ~/ 1000,
      title: '⏰ Deadline Alert',
      body: '$taskName sẽ hết hạn vào ngày mai!',
      scheduledTime: reminderTime,
    );
  }
}
```

### 3. Habit Tracker - Theo dõi thói quen

```dart
// habit_service.dart
class HabitService {
  static final NotificationService _notificationService = NotificationService();
  
  // Nhắc đọc sách
  static Future<void> scheduleReadingReminder() async {
    // Đọc sách lúc 9:00 PM hàng ngày
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, 21, 0);
    
    await _notificationService.scheduleNotification(
      id: 101,
      title: '📚 Reading Time',
      body: 'Đã đến giờ đọc sách. Hãy dành 30 phút để học hỏi!',
      scheduledTime: scheduledTime,
    );
  }
  
  // Nhắc viết nhật ký
  static Future<void> scheduleJournalReminder() async {
    // Viết nhật ký lúc 10:00 PM
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, 22, 0);
    
    await _notificationService.scheduleNotification(
      id: 102,
      title: '✍️ Journal Time',
      body: 'Hãy ghi lại những điều đặc biệt trong ngày hôm nay!',
      scheduledTime: scheduledTime,
    );
  }
  
  // Nhắc thiền
  static Future<void> scheduleMeditationReminder() async {
    await _notificationService.scheduleRepeatingNotification(
      id: 103,
      title: '🧘‍♀️ Meditation Time',
      body: 'Hãy dành 10 phút để thư giãn và tĩnh tâm',
      interval: RepeatInterval.daily,
    );
  }
}
```

## 🔧 Quản lý notifications

### 1. Hủy notification:
```dart
// Hủy 1 notification
await _notifications.cancel(id);

// Hủy tất cả
await _notifications.cancelAll();

// Hủy theo tag
await _notifications.cancel(id, tag: 'reminder');
```

### 2. Kiểm tra pending notifications:
```dart
Future<void> checkPendingNotifications() async {
  final pending = await _notifications.pendingNotificationRequests();
  print('Có ${pending.length} notification đang chờ');
  
  for (final notification in pending) {
    print('ID: ${notification.id}, Title: ${notification.title}');
  }
}
```

### 3. Xử lý khi tap notification:
```dart
// Trong init()
await _notifications.initialize(
  const InitializationSettings(android: android, iOS: ios),
  onDidReceiveNotificationResponse: (NotificationResponse response) {
    // Xử lý khi user tap notification
    print('Notification tapped: ${response.payload}');
    
    // Navigate to specific screen
    if (response.payload == 'meeting') {
      // Navigate to meeting screen
    }
  },
);
```

## 🎨 Tùy chỉnh notification

### 1. Custom sound:
```dart
const androidDetails = AndroidNotificationDetails(
  'custom_channel',
  'Custom Notifications',
  sound: RawResourceAndroidNotificationSound('custom_sound'),
);
```

### 2. Custom icon:
```dart
const androidDetails = AndroidNotificationDetails(
  'custom_channel',
  'Custom Notifications',
  icon: '@mipmap/custom_icon',
);
```

### 3. Big text:
```dart
const androidDetails = AndroidNotificationDetails(
  'big_text_channel',
  'Big Text Notifications',
  styleInformation: BigTextStyleInformation(
    'Đây là nội dung dài của notification...',
    contentTitle: 'Tiêu đề custom',
  ),
);
```

## 🔧 Sử dụng trong Widget

```dart
// reminder_page.dart
class ReminderPage extends StatefulWidget {
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final NotificationService _notificationService = NotificationService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reminder App')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await _notificationService.showInstantNotification(
                title: 'Test Notification',
                body: 'Đây là notification test!',
              );
            },
            child: Text('Gửi notification ngay'),
          ),
          
          ElevatedButton(
            onPressed: () async {
              final scheduleTime = DateTime.now().add(Duration(seconds: 5));
              await _notificationService.scheduleNotification(
                id: 1,
                title: 'Scheduled Test',
                body: 'Notification sau 5 giây',
                scheduledTime: scheduleTime,
              );
            },
            child: Text('Gửi notification sau 5 giây'),
          ),
          
          ElevatedButton(
            onPressed: () async {
              await ReminderService.scheduleWaterReminder();
            },
            child: Text('Bật nhắc uống nước'),
          ),
          
          ElevatedButton(
            onPressed: () async {
              await _notificationService.cancelAll();
            },
            child: Text('Hủy tất cả notification'),
          ),
        ],
      ),
    );
  }
}
```

## ❌ Lỗi thường gặp

### 1. **Không có permission**
```
Error: Notifications are not allowed
```
**Fix**: Kiểm tra permissions trong AndroidManifest.xml và request runtime permissions

### 2. **Timezone không đúng**
```
Error: Invalid timezone
```
**Fix**: Initialize timezone trước khi schedule:
```dart
tz.initializeTimeZones();
final timeZoneName = await FlutterTimezone.getLocalTimezone();
tz.setLocalLocation(tz.getLocation(timeZoneName));
```

### 3. **Notification không hiện khi app bị kill**
```
Problem: Notification không hoạt động khi app không chạy
```
**Fix**: Sử dụng `exactAllowWhileIdle` và đảm bảo có BootReceiver:
```dart
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
```

### 4. **ID bị trùng**
```
Problem: Notification bị ghi đè
```
**Fix**: Sử dụng unique ID cho mỗi notification:
```dart
final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
```

## 📱 Platform khác biệt

| Feature | Android | iOS |
|---------|---------|-----|
| Exact timing | ✅ | ✅ |
| Background | ✅ | ✅ |
| After reboot | ✅ | ❌ |
| Custom sound | ✅ | ✅ |
| Big text | ✅ | ❌ |
| Actions | ✅ | ✅ |

## 🔍 Debug tips

### 1. Log pending notifications:
```dart
Future<void> debugNotifications() async {
  final pending = await _notifications.pendingNotificationRequests();
  print('=== PENDING NOTIFICATIONS ===');
  for (final notif in pending) {
    print('ID: ${notif.id}');
    print('Title: ${notif.title}');
    print('Body: ${notif.body}');
    print('---');
  }
}
```

### 2. Test với delay ngắn:
```dart
// Test notification sau 5 giây thay vì 1 ngày
final testTime = DateTime.now().add(Duration(seconds: 5));
```

## 📝 Best Practices

1. **Unique IDs**: Luôn sử dụng unique ID cho mỗi notification
2. **Cancel old**: Hủy notification cũ trước khi schedule mới
3. **Handle permissions**: Kiểm tra permission trước khi schedule
4. **Test thoroughly**: Test trên cả Android và iOS
5. **User control**: Cho phép user tắt/bật notifications

## 🔗 Tham khảo

- [Official Documentation](https://pub.dev/packages/flutter_local_notifications)
- [Android Notification Guide](https://developer.android.com/develop/ui/views/notifications)
- [iOS Notification Guide](https://developer.apple.com/documentation/usernotifications)

---

**Hữu ích?** ⭐ Star repository này để ủng hộ!
