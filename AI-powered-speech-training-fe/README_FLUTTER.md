# AI Speaking Practice App - Flutter

Ứng dụng luyện tập nói tiếng Anh với AI feedback, được xây dựng bằng Flutter.

## 🎯 Tính năng

### User Mode
- ✅ Xem danh sách topics luyện tập
- ✅ Lọc topics theo level (Beginner, Intermediate, Advanced)
- ✅ Tìm kiếm topics
- ✅ Xem lịch sử luyện tập
- ✅ Thống kê điểm số và tiến độ
- ✅ Xem chi tiết feedback từ AI

### Admin Mode
- ✅ Dashboard với thống kê tổng quan
- ✅ Biểu đồ hoạt động theo tuần
- ✅ Quản lý topics (CRUD)
- ✅ Phân loại topics theo level

## 🏗️ Cấu trúc project

```
lib/
├── main.dart                      # Entry point & navigation
├── models/                        # Data models
│   ├── topic.dart
│   ├── recording.dart
│   └── feedback.dart
├── screens/                       # Màn hình chính
│   ├── role_selection_screen.dart
│   ├── topic_feed_screen.dart
│   ├── history_screen.dart
│   ├── admin_dashboard_screen.dart
│   └── topic_management_screen.dart
└── theme/
    └── app_theme.dart            # Theme & colors
```

## 🚀 Cài đặt và chạy

### Prerequisites
- Flutter SDK (>= 3.10.4)
- Dart SDK
- Android Studio / VS Code với Flutter extension

### Các bước cài đặt

1. **Clone repository hoặc navigate đến folder:**
```bash
cd AI-powered-speech-training-fe
```

2. **Cài đặt dependencies:**
```bash
flutter pub get
```

3. **Chạy ứng dụng:**
```bash
flutter run
```

Hoặc chọn device và nhấn F5 trong VS Code/Android Studio.

## 🎨 Design System

### Colors
- **Primary:** Blue (#3B82F6) - Dùng cho user mode
- **Secondary:** Purple (#A855F7) - Dùng cho admin mode
- **Success:** Green (#10B981)
- **Warning:** Amber (#F59E0B)
- **Error:** Red (#EF4444)

### Level Colors
- **Beginner:** Green with light green background
- **Intermediate:** Blue with light blue background
- **Advanced:** Purple with light purple background

## 📱 Màn hình

### 1. Role Selection
Màn hình đầu tiên cho phép chọn role (User hoặc Admin)

### 2. User Interface
- **Topics Tab:** Hiển thị danh sách topics với filter và search
- **History Tab:** Hiển thị lịch sử luyện tập và statistics

### 3. Admin Interface
- **Dashboard Tab:** Hiển thị metrics và biểu đồ
- **Topics Management Tab:** CRUD operations cho topics

## 🔧 Dependencies chính

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.1              # State management
  google_fonts: ^6.2.1          # Custom fonts
  fl_chart: ^0.69.2             # Charts
  record: ^5.1.0                # Audio recording
  audioplayers: ^6.1.0          # Audio playback
  intl: ^0.19.0                 # Date formatting
```

## 📝 TODO - Các tính năng cần thêm

- [ ] Tích hợp API backend
- [ ] Audio recording và playback thực tế
- [ ] AI feedback integration
- [ ] Authentication & Authorization
- [ ] Profile management
- [ ] Dark mode
- [ ] Responsive design cho tablet
- [ ] Unit tests & Integration tests
- [ ] CI/CD pipeline

## 🎯 Cách sử dụng

1. **Khởi động app** - Chọn role (User/Admin)

2. **User Mode:**
   - Vào tab Topics để xem danh sách
   - Dùng filter để lọc theo level
   - Click "Bắt đầu luyện tập" để bắt đầu
   - Xem lịch sử trong tab History

3. **Admin Mode:**
   - Xem statistics trong Dashboard
   - Quản lý topics trong Topics Management
   - Click "Tạo Topic mới" để thêm topic
   - Edit/Delete topics bằng các icon tương ứng

## 🐛 Known Issues

- Mock data đang được sử dụng (chưa có API)
- Practice và Feedback screens chưa được implement đầy đủ
- Chưa có audio recording/playback thực tế

## 📄 License

MIT License

## 👨‍💻 Developer

Developed by [Your Name]

---

**Note:** Đây là phiên bản Flutter của ứng dụng, được thiết kế dựa trên UI từ phiên bản React web (fe-resourcs folder).
