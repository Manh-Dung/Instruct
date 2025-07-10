# Hive CE Examples

Thư mục này chứa các ví dụ code hoàn chỉnh để sử dụng Hive CE trong Flutter project.

## 📁 Danh sách files

### 1. `main.dart`
- Setup và khởi tạo Hive CE
- Entry point của ứng dụng
- Khởi tạo TodoService

### 2. `todo_service.dart`
- Service class để quản lý dữ liệu Todo
- Các method CRUD cơ bản
- Ví dụ về cách tổ chức code với Hive

### 3. `todo_page.dart`
- Widget UI hoàn chỉnh
- Tương tác với TodoService
- Ví dụ về setState và rebuild UI

## 🚀 Cách sử dụng

1. **Copy code**: Sao chép code từ các file trên vào Flutter project của bạn
2. **Đảm bảo dependencies**: Kiểm tra `pubspec.yaml` có đủ dependencies
3. **Adjust imports**: Điều chỉnh import paths cho phù hợp với project structure
4. **Run**: Chạy `flutter pub get` và `flutter run`

## 📝 Lưu ý

- Code examples này chỉ mang tính chất demo
- Trong production app, nên thêm error handling
- Có thể tùy chỉnh UI theo design system của bạn
- Nên tách service ra file riêng để dễ maintain

## 🔧 Customization

### Thay đổi data model:
```dart
// Thay vì String, bạn có thể dùng custom class
class TodoItem {
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  
  TodoItem({required this.title, this.isCompleted = false, required this.createdAt});
}
```

### Thêm features:
- Search todos
- Mark as completed
- Categories/Tags
- Due dates
- Priority levels

Happy coding! 🎉
