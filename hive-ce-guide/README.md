# Hive CE - Hướng dẫn Setup và Sử dụng

## 🎯 Tổng quan
Hive CE là database local siêu nhẹ và nhanh cho Flutter. Thay thế SQLite khi bạn cần lưu trữ đơn giản mà không muốn viết SQL.

## 📦 Cài đặt

### 1. Thêm dependencies vào `pubspec.yaml`:
```yaml
dependencies:
  hive_ce: ^2.11.3
  hive_ce_flutter: ^2.3.1

dev_dependencies:
  hive_ce_generator: ^1.9.2
  build_runner: ^2.4.15
```

### 2. Cài đặt packages:
```bash
flutter pub get
```

## ⚙️ Setup cơ bản

### 1. Khởi tạo Hive trong `main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Hive
  await Hive.initFlutter();
  
  // Mở box (giống như tạo bảng trong database)
  await Hive.openBox('myBox');
  
  runApp(MyApp());
}
```

### 2. Tạo model đơn giản:
```dart
// models/user.dart
class User {
  User({required this.name, required this.age});
  
  final String name;
  final int age;
}
```

### 3. Tạo adapter config:
```dart
// hive_adapters.dart
import 'package:hive_ce/hive.dart';
import 'models/user.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<User>(),
])
class HiveAdapters {}
```

### 4. Generate code:
```bash
flutter packages pub run build_runner build
```

### 5. Đăng ký adapter:
```dart
// main.dart - thêm vào main() function
Hive.registerAdapter(UserAdapter());
```

## 🚀 Sử dụng cơ bản

### Lưu và đọc dữ liệu:
```dart
// Lấy box
var box = Hive.box('myBox');

// Lưu dữ liệu
await box.put('name', 'John');
await box.put('age', 25);
await box.put('user', User(name: 'Alice', age: 30));

// Đọc dữ liệu
String? name = box.get('name');
int? age = box.get('age');
User? user = box.get('user');

// Xóa dữ liệu
await box.delete('name');

// Xóa tất cả
await box.clear();
```

### Làm việc với List:
```dart
// Lưu list
List<String> fruits = ['apple', 'banana', 'orange'];
await box.put('fruits', fruits);

// Đọc list
List<String>? savedFruits = box.get('fruits')?.cast<String>();
```

## 💡 Ví dụ thực tế - Todo App

### Service class:
```dart
// todo_service.dart
class TodoService {
  static const String _boxName = 'todos';
  
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }
  
  static Box get _box => Hive.box(_boxName);
  
  // Thêm todo
  static Future<void> addTodo(String title) async {
    final todos = getAllTodos();
    todos.add(title);
    await _box.put('todoList', todos);
  }
  
  // Lấy tất cả todos
  static List<String> getAllTodos() {
    return _box.get('todoList', defaultValue: <String>[])?.cast<String>() ?? [];
  }
  
  // Xóa todo
  static Future<void> deleteTodo(int index) async {
    final todos = getAllTodos();
    if (index < todos.length) {
      todos.removeAt(index);
      await _box.put('todoList', todos);
    }
  }
}
```

### Sử dụng trong Widget:
```dart
class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<String> todos = [];
  
  @override
  void initState() {
    super.initState();
    _loadTodos();
  }
  
  void _loadTodos() {
    setState(() {
      todos = TodoService.getAllTodos();
    });
  }
  
  void _addTodo() async {
    await TodoService.addTodo('New Todo ${todos.length + 1}');
    _loadTodos();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo with Hive')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(todos[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await TodoService.deleteTodo(index);
                _loadTodos();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## 🔧 Tips quan trọng

### 1. Kiểm tra box đã mở chưa:
```dart
if (!Hive.isBoxOpen('myBox')) {
  await Hive.openBox('myBox');
}
```

### 2. Xử lý lỗi:
```dart
try {
  var box = Hive.box('myBox');
  var data = box.get('key');
} catch (e) {
  print('Lỗi Hive: $e');
}
```

### 3. Đóng box khi không dùng:
```dart
await box.close();
```

## ❌ Lỗi thường gặp

### 1. **"No adapter registered"**
```
Lỗi: No adapter registered for TypeId xxx
```
**Fix**: Nhớ gọi `Hive.registerAdapter()` trước khi mở box.

### 2. **"Box already open"**
```
Lỗi: Box is already open
```
**Fix**: Kiểm tra trước khi mở:
```dart
if (!Hive.isBoxOpen('myBox')) {
  await Hive.openBox('myBox');
}
```

### 3. **Type casting error**
```
Lỗi: type 'List<dynamic>' is not a subtype of type 'List<String>'
```
**Fix**: Sử dụng `.cast<String>()` hoặc kiểm tra type:
```dart
List<String>? data = box.get('key')?.cast<String>();
```

## 📝 Lưu ý

- **Đơn giản**: Chỉ dùng Hive cho dữ liệu đơn giản, không phức tạp
- **Performance**: Hive rất nhanh cho read/write cơ bản
- **Size**: Không lưu file quá lớn (>10MB)
- **Backup**: Hive tự động backup, nhưng nên có strategy riêng

## 🔗 Tham khảo
- [Hive CE Documentation](https://pub.dev/packages/hive_ce)
- [Flutter Local Storage Options](https://docs.flutter.dev/cookbook/persistence)

---

**Hữu ích?** ⭐ Star repo này để ủng hộ!
