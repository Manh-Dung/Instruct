// reminder_service.dart
// Service để quản lý các loại reminder khác nhau

import 'notification_service.dart';

class ReminderService {
  static final NotificationService _notificationService = NotificationService();
  
  /// Reminder IDs
  static const int _waterReminderId = 1;
  static const int _workoutReminderId = 2;
  static const int _breakReminderId = 3;
  static const int _sleepReminderId = 4;
  static const int _medicineReminderId = 5;

  /// Schedule water reminder every 2 hours
  static Future<void> scheduleWaterReminder() async {
    await _notificationService.scheduleRepeatingNotification(
      id: _waterReminderId,
      title: '💧 Uống nước nào!',
      body: 'Đã 2 giờ rồi, nhớ uống nước để khỏe mạnh nhé!',
      interval: RepeatInterval.everyMinute, // Demo - thực tế có thể dùng custom interval
    );
  }

  /// Schedule workout reminder at specific time
  static Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
  }) async {
    await _notificationService.scheduleDailyNotification(
      id: _workoutReminderId,
      title: '🏃‍♂️ Workout Time!',
      body: 'Đã đến giờ tập thể dục. Hãy bắt đầu ngày mới với năng lượng!',
      time: TimeOfDay(hour: hour, minute: minute),
    );
  }

  /// Schedule break reminder every hour
  static Future<void> scheduleBreakReminder() async {
    await _notificationService.scheduleRepeatingNotification(
      id: _breakReminderId,
      title: '☕ Break Time!',
      body: 'Đã làm việc 1 giờ rồi, hãy nghỉ giải lao 5 phút nhé!',
      interval: RepeatInterval.hourly,
    );
  }

  /// Schedule sleep reminder
  static Future<void> scheduleSleepReminder({
    required int hour,
    required int minute,
  }) async {
    await _notificationService.scheduleDailyNotification(
      id: _sleepReminderId,
      title: '😴 Bedtime!',
      body: 'Đã đến giờ ngủ. Hãy chuẩn bị để có một giấc ngủ ngon!',
      time: TimeOfDay(hour: hour, minute: minute),
    );
  }

  /// Schedule medicine reminder
  static Future<void> scheduleMedicineReminder({
    required String medicineName,
    required int hour,
    required int minute,
  }) async {
    await _notificationService.scheduleDailyNotification(
      id: _medicineReminderId,
      title: '💊 Uống thuốc',
      body: 'Đã đến giờ uống $medicineName. Đừng quên nhé!',
      time: TimeOfDay(hour: hour, minute: minute),
    );
  }

  /// Cancel water reminder
  static Future<void> cancelWaterReminder() async {
    await _notificationService.cancelNotification(_waterReminderId);
  }

  /// Cancel workout reminder
  static Future<void> cancelWorkoutReminder() async {
    await _notificationService.cancelNotification(_workoutReminderId);
  }

  /// Cancel break reminder
  static Future<void> cancelBreakReminder() async {
    await _notificationService.cancelNotification(_breakReminderId);
  }

  /// Cancel sleep reminder
  static Future<void> cancelSleepReminder() async {
    await _notificationService.cancelNotification(_sleepReminderId);
  }

  /// Cancel medicine reminder
  static Future<void> cancelMedicineReminder() async {
    await _notificationService.cancelNotification(_medicineReminderId);
  }

  /// Cancel all reminders
  static Future<void> cancelAllReminders() async {
    await _notificationService.cancelNotification(_waterReminderId);
    await _notificationService.cancelNotification(_workoutReminderId);
    await _notificationService.cancelNotification(_breakReminderId);
    await _notificationService.cancelNotification(_sleepReminderId);
    await _notificationService.cancelNotification(_medicineReminderId);
  }

  /// Get all active reminders
  static Future<List<String>> getActiveReminders() async {
    final pending = await _notificationService.getPendingNotifications();
    final activeReminders = <String>[];

    for (final notification in pending) {
      switch (notification.id) {
        case _waterReminderId:
          activeReminders.add('Water Reminder');
          break;
        case _workoutReminderId:
          activeReminders.add('Workout Reminder');
          break;
        case _breakReminderId:
          activeReminders.add('Break Reminder');
          break;
        case _sleepReminderId:
          activeReminders.add('Sleep Reminder');
          break;
        case _medicineReminderId:
          activeReminders.add('Medicine Reminder');
          break;
      }
    }

    return activeReminders;
  }

  /// Test immediate notification
  static Future<void> testReminderNotification() async {
    await _notificationService.showInstantNotification(
      title: '🧪 Test Reminder',
      body: 'Đây là notification test để kiểm tra hệ thống!',
    );
  }
}

// Helper class for different reminder types
class ReminderType {
  final int id;
  final String name;
  final String icon;
  final String defaultTitle;
  final String defaultBody;

  const ReminderType({
    required this.id,
    required this.name,
    required this.icon,
    required this.defaultTitle,
    required this.defaultBody,
  });

  static const water = ReminderType(
    id: 1,
    name: 'Water',
    icon: '💧',
    defaultTitle: 'Uống nước nào!',
    defaultBody: 'Đã đến giờ uống nước để khỏe mạnh!',
  );

  static const workout = ReminderType(
    id: 2,
    name: 'Workout',
    icon: '🏃‍♂️',
    defaultTitle: 'Workout Time!',
    defaultBody: 'Đã đến giờ tập thể dục!',
  );

  static const break_ = ReminderType(
    id: 3,
    name: 'Break',
    icon: '☕',
    defaultTitle: 'Break Time!',
    defaultBody: 'Hãy nghỉ giải lao 5 phút!',
  );

  static const sleep = ReminderType(
    id: 4,
    name: 'Sleep',
    icon: '😴',
    defaultTitle: 'Bedtime!',
    defaultBody: 'Đã đến giờ ngủ!',
  );

  static const medicine = ReminderType(
    id: 5,
    name: 'Medicine',
    icon: '💊',
    defaultTitle: 'Uống thuốc',
    defaultBody: 'Đừng quên uống thuốc!',
  );

  static const List<ReminderType> all = [
    water,
    workout,
    break_,
    sleep,
    medicine,
  ];
}
