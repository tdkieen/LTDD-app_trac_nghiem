# EDUTECH - Ứng Dụng Thi Trắc Nghiệm Trực Tuyến

Ứng dụng ôn luyện và thi trắc nghiệm đa nền tảng (Android & Web) được xây dựng bằng **Flutter** và quản lý trạng thái với **Provider**, thiết kế giao diện đáp ứng (Responsive UI) cho cả màn hình Desktop/Web và Mobile.

---

## 🚀 Tính Năng Chính

### 1. Tài khoản & Phân quyền (RBAC)
- Đăng nhập, đăng ký tài khoản và chuyển đổi nhanh tài khoản demo để kiểm thử.
- Hỗ trợ 3 vai trò người dùng:
  - **Học viên (Student)**: Tham gia thi, luyện tập, xem lịch sử thi, quản lý sổ tay câu sai và đề thi yêu thích.
  - **Giáo viên (Teacher)**: Quản lý chủ đề, tạo đề thi mới, quản lý ngân hàng câu hỏi (hỗ trợ đính kèm hình ảnh & âm thanh).
  - **Quản trị viên (Admin)**: Quản lý toàn bộ người dùng, chủ đề, đề thi, câu hỏi và xem bảng xếp hạng tổng thể.

### 2. Làm Bài Thi & Luyện Tập
- **Hỗ trợ đa phương tiện**: Câu hỏi trắc nghiệm văn bản, câu hỏi kèm hình ảnh minh họa và câu hỏi nghe (Listening Audio MP3 / Text-to-Speech).
- **Đồng hồ đếm ngược**: Theo dõi thời gian làm bài trực quan, cảnh báo gian lận khi rời khỏi màn hình thi.
- **Chế độ Luyện tập**: Ôn tập kiến thức không giới hạn thời gian.
- **Chấm điểm & Giải thích chi tiết**: Hiển thị điểm số trên thang điểm 10, thống kê số câu đúng/sai và xem lại đáp án kèm lời giải thích cho từng câu.

### 3. Sổ Tay Học Tập & Cá Nhân Hóa
- **Sổ câu sai (Mistake Notebook)**: Tự động lưu lại các câu trả lời sai trong quá trình thi để học viên ôn luyện lại.
- **Đề thi yêu thích (Bookmarks)**: Đánh dấu các bộ đề quan trọng để truy cập nhanh.
- **Nhật ký & Lịch sử thi**: Theo dõi tiến độ học tập, điểm mục tiêu và biểu đồ thành tích cá nhân.
- **Bảng xếp hạng (Leaderboard)**: Vinh danh các học viên có điểm số cao nhất theo từng đề thi và trên toàn hệ thống.

---

## 🛠 Công Nghệ & Thư Viện Sử Dụng

- **Framework**: Flutter SDK (`^3.13.3`)
- **State Management**: `provider`
- **Cơ sở dữ liệu & Xác thực**: `firebase_core`, `cloud_firestore`, `firebase_auth`, `shared_preferences`
- **Âm thanh & Đa phương tiện**: `audioplayers`, `flutter_tts`, `file_picker`
- **Định dạng & Tiện ích**: `intl`, `cupertino_icons`

---

## 📁 Cấu Trúc Thư Mục Hiện Tại

```text
LTDD-app_trac_nghiem/
├── android/                        # Cấu hình nền tảng Android
├── web/                            # Cấu hình nền tảng Web
├── assets/
│   ├── audio/                      # Tài nguyên âm thanh câu hỏi nghe
│   └── images/                     # Tài nguyên hình ảnh minh họa
├── lib/
│   ├── main.dart                   # Điểm khởi chạy ứng dụng & cấu hình MultiProvider
│   ├── core/
│   │   ├── responsive/
│   │   │   └── responsive_layout.dart  # Tự động điều chỉnh giao diện Mobile / Tablet / Desktop
│   │   └── theme/
│   │       ├── app_colors.dart         # Bảng màu chuẩn của hệ thống
│   │       └── app_theme.dart          # Cấu hình Typography & Material 3 Theme
│   ├── models/                     # Các lớp mô hình dữ liệu
│   │   ├── app_user.dart               # Thông tin người dùng & phân quyền (UserRole)
│   │   ├── chu_de.dart                 # Chủ đề / Môn học
│   │   ├── de_thi.dart                 # Đề thi trắc nghiệm
│   │   ├── cau_hoi.dart                # Câu hỏi trắc nghiệm (Text, Image, Audio)
│   │   ├── ket_qua_thi.dart            # Kết quả bài thi & chi tiết từng câu
│   │   ├── cau_hoi_sai.dart            # Dữ liệu sổ tay câu sai
│   │   ├── de_thi_yeu_thich.dart       # Đề thi đã lưu (Bookmark)
│   │   └── thong_bao.dart              # Thông báo hệ thống
│   ├── providers/                  # Quản lý trạng thái ứng dụng (ChangeNotifier)
│   │   ├── auth_provider.dart          # Trạng thái đăng nhập, đăng ký & phân quyền
│   │   ├── quiz_provider.dart          # Quản lý danh sách đề thi, câu hỏi, chủ đề, kết quả
│   │   ├── exam_session_provider.dart  # Trạng thái phiên làm bài thi & bộ đếm giờ
│   │   └── notification_provider.dart  # Quản lý thông báo người dùng
│   ├── services/                   # Tầng dữ liệu & nghiệp vụ
│   │   ├── mock_data.dart              # Bộ dữ liệu khởi tạo mẫu (Users, Exams, Questions,...)
│   │   └── quiz_repository.dart        # Kho lưu trữ và xử lý truy vấn dữ liệu
│   └── views/                      # Giao diện người dùng (Screens & Widgets)
│       ├── main_layout_shell.dart      # Khung bố cục chính (Sidebar cho Web / BottomNav cho Mobile)
│       ├── auth/
│       │   └── auth_screen.dart            # Màn hình Đăng nhập / Đăng ký
│       ├── home/
│       │   └── home_screen.dart            # Trang chủ tổng quan học tập
│       ├── exam/
│       │   ├── exam_list_screen.dart       # Danh sách & tìm kiếm đề thi
│       │   ├── exam_taking_screen.dart     # Màn hình làm bài thi trắc nghiệm
│       │   ├── exam_result_screen.dart     # Màn hình kết quả & xem lại đáp án
│       │   ├── history_screen.dart         # Nhật ký / Lịch sử làm bài
│       │   ├── mistake_notebook_screen.dart# Sổ tay câu hỏi sai
│       │   └── bookmarks_screen.dart       # Danh sách đề thi yêu thích
│       ├── admin/
│       │   ├── create_exam_screen.dart     # Tạo đề thi mới
│       │   ├── manage_questions_screen.dart# Quản lý ngân hàng câu hỏi
│       │   ├── add_question_sheet.dart     # Biểu mẫu thêm/sửa câu hỏi
│       │   ├── manage_categories_screen.dart # Quản lý danh mục chủ đề
│       │   ├── manage_users_screen.dart    # Quản lý danh sách người dùng
│       │   └── overall_leaderboard_screen.dart # Bảng xếp hạng tổng thể
│       ├── profile/
│       │   └── profile_screen.dart         # Hồ sơ cá nhân & cài đặt mục tiêu
│       └── widgets/                    # Các thành phần giao diện dùng chung
│           ├── app_header.dart
│           ├── exam_card.dart
│           ├── listening_audio_player.dart
│           ├── mobile_drawer.dart
│           ├── notification_dialog.dart
│           ├── question_media_view.dart
│           ├── role_switcher_dialog.dart
│           ├── stat_card.dart
│           └── web_sidebar.dart
├── test/
│   └── widget_test.dart            # Kiểm thử giao diện (Smoke test Desktop & Mobile)
└── pubspec.yaml                    # Khai báo cấu hình & thư viện dự án
```

---

## ▶️ Hướng Dẫn Cài Đặt & Chạy Ứng Dụng

### 1. Cài đặt các gói thư viện
```bash
flutter pub get
```

### 2. Chạy ứng dụng
- **Chạy trên trình duyệt Web (Chrome):**
  ```bash
  flutter run -d chrome
  ```
- **Chạy trên máy ảo / thiết bị Android:**
  ```bash
  flutter run
  ```

### 3. Tài khoản Demo tích hợp sẵn
Trên màn hình Đăng nhập, bạn có thể nhấn chọn nhanh 1 trong 3 tài khoản mẫu:
- **Học viên**: `duyki` (`duyki@edutech.vn`, Mật khẩu: `123456`)
- **Giáo viên**: `gv_huong` (`huong.gv@edutech.vn`, Mật khẩu: `123456`)
- **Quản trị viên (Admin)**: `admin` (`admin@edutech.vn`, Mật khẩu: `123456`)

---

## 🔥 Cấu Hình Firebase (Firestore + FirebaseAuth)

### 1. Kết nối project với Firebase bằng FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Lệnh trên sẽ sinh/cập nhật file `lib/firebase_options.dart` và `android/app/google-services.json` (Application ID Android: `vn.edutech.app_trac_nghiem`).

### 2. Bật dịch vụ trên Firebase Console
1. **Authentication**: Vào **Build -> Authentication -> Sign-in method**, bật phương thức **Email/Password**.
2. **Cloud Firestore**: Vào **Build -> Firestore Database**, nhấn **Create database** để khởi tạo cơ sở dữ liệu cho 8 collection (`users`, `categories`, `exams`, `questions`, `results`, `mistakes`, `bookmarks`, `notifications`).

### 3. Deploy quy tắc bảo mật (`firestore.rules`)
Đảm bảo đã cài đặt `firebase-tools` và đăng nhập (`firebase login`), sau đó chạy lệnh:
```bash
firebase deploy --only firestore:rules
```

### 4. Khởi tạo dữ liệu mẫu (Seed Data)
- Đăng nhập bằng tài khoản **Admin** ở chế độ Debug (`flutter run`), sau đó nhấn nút **"Tạo dữ liệu mẫu"** trên thanh Header hoặc trong trang Hồ sơ cá nhân để tự động tạo các tài khoản mẫu qua `FirebaseAuth` và đẩy dữ liệu mẫu từ `lib/services/mock_data.dart` lên `Cloud Firestore`.
