// todo_page.dart
// Widget demo sử dụng TodoService với Hive CE

import 'package:flutter/material.dart';
import 'todo_service.dart';

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<String> todos = [];
  final TextEditingController _controller = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadTodos();
  }
  
  // Load todos từ Hive
  void _loadTodos() {
    setState(() {
      todos = TodoService.getAllTodos();
    });
  }
  
  // Thêm todo mới
  void _addTodo() async {
    if (_controller.text.isNotEmpty) {
      await TodoService.addTodo(_controller.text);
      _controller.clear();
      _loadTodos();
    }
  }
  
  // Xóa todo
  void _deleteTodo(int index) async {
    await TodoService.deleteTodo(index);
    _loadTodos();
  }
  
  // Hiển thị dialog để thêm todo
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm Todo'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Nhập công việc...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                _addTodo();
                Navigator.pop(context);
              },
              child: Text('Thêm'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo with Hive CE'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: () async {
              await TodoService.clearAllTodos();
              _loadTodos();
            },
          ),
        ],
      ),
      body: todos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chưa có công việc nào!', style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                      backgroundColor: Colors.blue,
                    ),
                    title: Text(todos[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTodo(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
