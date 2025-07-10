// todo_service.dart
// Service class để quản lý Todo với Hive CE

import 'package:hive_ce/hive.dart';

class TodoService {
  static const String _boxName = 'todos';
  
  // Khởi tạo box
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }
  
  // Lấy box
  static Box get _box => Hive.box(_boxName);
  
  // Thêm todo mới
  static Future<void> addTodo(String title) async {
    final todos = getAllTodos();
    todos.add(title);
    await _box.put('todoList', todos);
  }
  
  // Lấy tất cả todos
  static List<String> getAllTodos() {
    return _box.get('todoList', defaultValue: <String>[])?.cast<String>() ?? [];
  }
  
  // Cập nhật todo
  static Future<void> updateTodo(int index, String newTitle) async {
    final todos = getAllTodos();
    if (index < todos.length) {
      todos[index] = newTitle;
      await _box.put('todoList', todos);
    }
  }
  
  // Xóa todo
  static Future<void> deleteTodo(int index) async {
    final todos = getAllTodos();
    if (index < todos.length) {
      todos.removeAt(index);
      await _box.put('todoList', todos);
    }
  }
  
  // Đếm số lượng todo
  static int getTodoCount() {
    return getAllTodos().length;
  }
  
  // Xóa tất cả todos
  static Future<void> clearAllTodos() async {
    await _box.put('todoList', <String>[]);
  }
}
