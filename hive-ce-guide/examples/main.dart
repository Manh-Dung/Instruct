// main.dart
// Ví dụ setup hoàn chỉnh Hive CE trong Flutter

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'todo_service.dart';
import 'todo_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Hive
  await Hive.initFlutter();
  
  // Khởi tạo TodoService
  await TodoService.init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive CE Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoPage(),
    );
  }
}
