// reminder_app.dart
// Demo app sử dụng notification service

import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().init();
  
  runApp(ReminderApp());
}

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ReminderHomePage(),
    );
  }
}

class ReminderHomePage extends StatefulWidget {
  @override
  _ReminderHomePageState createState() => _ReminderHomePageState();
}

class _ReminderHomePageState extends State<ReminderHomePage> {
  final NotificationService _notificationService = NotificationService();
  List<String> _activeReminders = [];

  @override
  void initState() {
    super.initState();
    _loadActiveReminders();
  }

  Future<void> _loadActiveReminders() async {
    final reminders = await ReminderService.getActiveReminders();
    setState(() {
      _activeReminders = reminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActiveRemindersSection(),
            SizedBox(height: 24),
            _buildQuickActionsSection(),
            SizedBox(height: 24),
            _buildReminderTypesSection(),
            SizedBox(height: 24),
            _buildTestSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRemindersSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Reminders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _activeReminders.isEmpty
                ? Text('No active reminders')
                : Column(
                    children: _activeReminders
                        .map((reminder) => ListTile(
                              leading: Icon(Icons.notifications_active),
                              title: Text(reminder),
                            ))
                        .toList(),
                  ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadActiveReminders,
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _notificationService.showInstantNotification(
                        title: 'Test Notification',
                        body: 'This is a test notification!',
                      );
                    },
                    child: Text('Test Now'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final scheduleTime = DateTime.now().add(Duration(seconds: 5));
                      await _notificationService.scheduleNotification(
                        id: 999,
                        title: 'Scheduled Test',
                        body: 'This notification was scheduled 5 seconds ago!',
                        scheduledTime: scheduleTime,
                      );
                    },
                    child: Text('Test in 5s'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await _notificationService.cancelAllNotifications();
                await _loadActiveReminders();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Cancel All'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTypesSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...ReminderType.all.map((type) => _buildReminderTypeCard(type)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTypeCard(ReminderType type) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(type.icon, style: TextStyle(fontSize: 24)),
        title: Text(type.name),
        subtitle: Text(type.defaultBody),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showScheduleDialog(type),
            ),
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () => _cancelReminder(type),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _notificationService.showBigTextNotification(
                  title: 'Big Text Notification',
                  body: 'Short description',
                  bigText: 'This is a very long text that will be shown in expanded view. '
                      'It can contain multiple lines and much more detailed information '
                      'about the notification content.',
                );
              },
              child: Text('Show Big Text'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                // Simulate progress
                for (int i = 0; i <= 100; i += 10) {
                  await _notificationService.showProgressNotification(
                    title: 'Download Progress',
                    progress: i,
                    maxProgress: 100,
                    id: 1001,
                  );
                  await Future.delayed(Duration(milliseconds: 500));
                }
              },
              child: Text('Show Progress'),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleDialog(ReminderType type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule ${type.name} Reminder'),
        content: Text('Do you want to schedule ${type.name.toLowerCase()} reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _scheduleReminder(type);
              Navigator.pop(context);
            },
            child: Text('Schedule'),
          ),
        ],
      ),
    );
  }

  Future<void> _scheduleReminder(ReminderType type) async {
    switch (type.id) {
      case 1: // Water
        await ReminderService.scheduleWaterReminder();
        break;
      case 2: // Workout
        await ReminderService.scheduleWorkoutReminder(hour: 6, minute: 0);
        break;
      case 3: // Break
        await ReminderService.scheduleBreakReminder();
        break;
      case 4: // Sleep
        await ReminderService.scheduleSleepReminder(hour: 22, minute: 0);
        break;
      case 5: // Medicine
        await ReminderService.scheduleMedicineReminder(
          medicineName: 'Vitamin D',
          hour: 8,
          minute: 0,
        );
        break;
    }
    await _loadActiveReminders();
  }

  Future<void> _cancelReminder(ReminderType type) async {
    switch (type.id) {
      case 1: // Water
        await ReminderService.cancelWaterReminder();
        break;
      case 2: // Workout
        await ReminderService.cancelWorkoutReminder();
        break;
      case 3: // Break
        await ReminderService.cancelBreakReminder();
        break;
      case 4: // Sleep
        await ReminderService.cancelSleepReminder();
        break;
      case 5: // Medicine
        await ReminderService.cancelMedicineReminder();
        break;
    }
    await _loadActiveReminders();
  }
}
