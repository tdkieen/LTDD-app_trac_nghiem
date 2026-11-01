# EDUTECH - Nền Tảng Thi & Ôn Luyện Trắc Nghiệm Trực Tuyến

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Cloud Firestore](https://img.shields.io/badge/Cloud%20Firestore-FFA000?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com/docs/firestore)
[![Firebase Auth](https://img.shields.io/badge/Firebase%20Auth-4285F4?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com/docs/auth)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20Windows-brightgreen?style=for-the-badge)](#)
[![Tests](https://img.shields.io/badge/Tests-8%2F8%20Passed-success?style=for-the-badge)](#)

Ứng dụng ôn luyện và thi trắc nghiệm trực tuyến đa nền tảng (**Android**, **Web**, **Windows Desktop**), được xây dựng bằng **Flutter**, quản lý trạng thái bằng **Provider**, và tích hợp đầy đủ backend trên nền tảng **Google Firebase** (**Cloud Firestore** + **Firebase Authentication**). Giao diện đáp ứng (Responsive UI) mượt mà, tối ưu trải nghiệm cho cả màn hình Desktop/Web (Sidebar) và Điện thoại di động (Bottom Navigation / Drawer).

---

## 📑 Mục Lục
1. [Tính Năng Chính](#-tính-năng-chính)
2. [Kiến Trúc & Công Nghệ](#-kiến-trúc--công-nghệ)
3. [Cấu Trúc Thư Mục](#-cấu-trúc-thư-mục)
4. [Tài Khoản Thử Nghiệm & Seed Dữ Liệu](#-tài-khoản-thử-nghiệm--seed-dữ-liệu)
5. [Cài Đặt & Khởi Chạy Ứng Dụng](#-cài-đặt--khởi-chạy-ứng-dụng)
6. [Cấu Hình & Triển Khai Firebase](#-cấu-hình--triển-khai-firebase)
7. [Kiểm Thử (Unit & Widget Tests)](#-kiểm-thử-unit--widget-tests)
8. [Hướng Dẫn Push Code Lên GitHub](#-hướng-dẫn-push-code-lên-github)

---

## 🚀 Tính Năng Chính

### 1. Xác thực & Phân quyền Người dùng (RBAC)
- **Đăng ký & Đăng nhập**: Xác thực thời gian thực qua **Firebase Authentication** (Email & Mật khẩu). Hồ sơ người dùng lưu tại collection `users` với Document ID là `UID`.
- **Phân quyền 3 cấp độ (Role-Based Access Control)**:
  - 🎓 **Học viên (Student)**: Xem danh sách đề thi, làm bài thi trắc nghiệm, luyện tập tự do, xem lại lịch sử thi, quản lý sổ câu sai, đánh dấu đề thi yêu thích.
  - 👩‍🏫 **Giáo viên (Teacher)**: Toàn quyền của học viên, bổ sung thêm quyền quản lý danh mục chủ đề, tạo đề thi mới, quản lý ngân hàng câu hỏi (hỗ trợ văn bản, đính kèm ảnh minh họa và âm thanh).
  - 👑 **Quản trị viên (Admin)**: Toàn quyền hệ thống, quản lý tất cả người dùng, đổi quyền (Role) tài khoản, xem bảng xếp hạng tổng thể, khởi tạo dữ liệu mẫu (Seed Data).
- **Bộ chuyển đổi vai trò (Role Switcher)**: Chỉ hiển thị ở môi trường phát triển (`kDebugMode`) giúp kiểm thử nhanh luồng giao diện giữa các vai trò.

### 2. Thi Trắc Nghiệm & Luyện Tập Chuyên Sâu
- **Đa phương tiện phong phú**: Hỗ trợ câu hỏi thuần văn bản, câu hỏi kèm hình ảnh (URL mạng hoặc nén Base64 < 300KB) và câu hỏi nghe tiếng Anh (Audio MP3 URL / Text-to-Speech tự động).
- **Thuật toán Xáo trộn thông minh**: Tuỳ chọn xáo trộn thứ tự câu hỏi và phương án trả lời khi bắt đầu thi, tự động ánh xạ lại đáp án đúng chính xác tuyệt đối.
- **Đồng hồ đếm ngược & Tự động nộp bài**: Đếm ngược thời gian thực, khi hết giờ tự động chấm bài và chuyển sang màn hình kết quả qua Callback/ValueNotifier.
- **Giám sát chống gian lận (Anti-Cheat)**: Cảnh báo người dùng khi rời màn hình thi. Nếu vi phạm từ 3 lần trở lên, hệ thống tự động thu bài và ghi nhận số lần vi phạm vào kết quả thi.
- **Chống mất bài (Session Auto-Recovery)**: Tự động lưu tiến trình làm bài dở (câu trả lời, câu hiện tại, thời gian còn lại) vào bộ nhớ cục bộ (`shared_preferences`). Khi vào lại đề thi, hệ thống sẽ hỏi: *"Tiếp tục bài đang làm?"*.
- **Chế độ Luyện câu sai**:
  - Tự động ghi nhận các câu trả lời sai vào Sổ câu sai (`mistakes`).
  - Luyện tập riêng các câu sai (mã đề `9999`).
  - Chấm điểm chính xác theo danh sách câu hỏi thực tế của phiên.
  - Khi trả lời đúng trong chế độ luyện câu sai, hệ thống tự động giảm số lần sai (`lanSai`), khi về `0` sẽ tự động xóa câu hỏi khỏi sổ tay.
- **Chế độ Luyện tập**: Ôn tập tự do không tính giờ, không lưu kết quả vào lịch sử, không tăng lượt thi của đề thi.

### 3. Đồng Bộ Thời Gian Thực & Ngoại Tuyến (Firebase Realtime & Offline Persistence)
- **Realtime Sync**: Dùng `snapshots()` lắng nghe thay đổi của `exams`, `questions`, `notifications` để các thiết bị cập nhật tức thì.
- **Offline Persistence**: Bật lưu bộ nhớ đệm Firestore cục bộ. Ứng dụng đọc/ghi mượt mà cả khi mất kết nối mạng.
- **Doc ID sinh tự động**: Sử dụng `doc().id` phân tán thay cho số thứ tự tự tăng `max + 1`, chống xung đột khi nhiều thiết bị cùng tạo dữ liệu.
- **Giám sát kết nối Firebase thời gian thực**: Header và Profile hiển thị trạng thái kết nối thật bằng cách truy vấn thử Firestore với timeout 5 giây.

### 4. Xử Lý Đa Phương Tiện Không Tốn Chi Phí
- Không sử dụng Firebase Storage (yêu cầu gói cước Blaze trả phí).
- **Hình ảnh**: Hỗ trợ nhập trực tiếp URL ảnh (http/https) hoặc tải ảnh từ thiết bị (tự động nén dưới 300KB, mã hóa Base64 Data URI lưu trực tiếp trong Firestore). Hỗ trợ mượt mà trên cả Web và Di động.
- **Âm thanh**: Hỗ trợ đường dẫn URL file MP3 hoặc tự động đọc câu hỏi bằng Google Text-to-Speech (`flutter_tts`).

---

## 🛠 Kiến Trúc & Công Nghệ

| Thành Phần | Công Nghệ / Thư Viện | Mục Đích Sử Dụng |
| :--- | :--- | :--- |
| **Framework** | Flutter SDK (`^3.13.3` / `3.x`) | Phát triển ứng dụng đa nền tảng từ một mã nguồn |
| **State Management** | `provider` (`^6.1.1`) | Quản lý trạng thái theo mô hình Reactive (MultiProvider, ChangeNotifier) |
| **Authentication** | `firebase_auth` (`^5.0.0`) | Xác thực người dùng bằng Email & Mật khẩu |
| **Database** | `cloud_firestore` (`^5.0.0`) | Cơ sở dữ liệu NoSQL đám mây, đồng bộ thời gian thực & cache offline |
| **Core Firebase** | `firebase_core` (`^3.0.0`) | Khởi tạo cấu hình đa nền tảng qua `DefaultFirebaseOptions` |
| **Local Cache** | `shared_preferences` (`^2.2.2`) | Lưu trữ tiến trình phiên thi và trạng thái đăng nhập cục bộ |
| **Media & Audio** | `audioplayers` (`^6.0.0`), `flutter_tts` (`^4.2.0`), `file_picker` (`^13.3.0`) | Phát âm thanh câu hỏi nghe, đọc giọng nói, chọn tệp hình ảnh |
| **UI & Format** | `intl` (`^0.19.0`), `cupertino_icons` (`^1.0.6`) | Định dạng ngày tháng, tiền tệ, biểu tượng chuẩn iOS & Android |

---

## 📁 Cấu Trúc Thư Mục

```text
LTDD-app_trac_nghiem/
├── android/                            # Cấu hình Gradle & Android App (Application ID: vn.edutech.app_trac_nghiem)
│   └── app/
│       ├── build.gradle.kts            # Cấu hình plugin google-services có điều kiện
│       └── google-services.json        # File cấu hình Firebase cho nền tảng Android
├── web/                                # Cấu hình ứng dụng chạy trên trình duyệt Web
├── assets/                             # Tài nguyên tĩnh (Hình ảnh & Âm thanh mẫu)
├── firestore.rules                     # Bộ quy tắc bảo mật Cloud Firestore (RBAC & Document Owner)
├── firebase.json                       # Cấu hình Firebase CLI & Firestore Rules deploy target
├── lib/
│   ├── firebase_options.dart           # File tự động sinh bởi FlutterFire CLI kết nối Firebase đa nền tảng
│   ├── main.dart                       # Khởi tạo Firebase với Persistence, cấu hình MultiProvider, Entry point
│   ├── core/
│   │   ├── responsive/
│   │   │   └── responsive_layout.dart  # Tự động co giãn bố cục: Mobile (<768px), Tablet, Desktop (>1024px)
│   │   └── theme/
│   │       ├── app_colors.dart         # Bảng màu chủ đạo Material 3
│   │       └── app_theme.dart          # Cấu hình Typography, CardTheme, InputDecorationTheme
│   ├── models/                         # Các mô hình dữ liệu (hỗ trợ String ID & JSON serialization)
│   │   ├── app_user.dart               # Người dùng & phân quyền (Student / Teacher / Admin)
│   │   ├── chu_de.dart                 # Danh mục môn học / chủ đề
│   │   ├── de_thi.dart                 # Thông tin đề thi, thời gian, số câu, lượt thi
│   │   ├── cau_hoi.dart                # Câu hỏi trắc nghiệm (LoaiCauHoi: text, image, audio)
│   │   ├── ket_qua_thi.dart            # Kết quả thi, điểm số, danh sách câu trả lời, số lần vi phạm
│   │   ├── cau_hoi_sai.dart            # Sổ tay câu sai (quản lý số lần sai lanSai)
│   │   ├── de_thi_yeu_thich.dart       # Đề thi đánh dấu yêu thích
│   │   └── thong_bao.dart              # Thông báo gửi đến người dùng
│   ├── providers/                      # Tầng State Management
│   │   ├── auth_provider.dart          # Xác thực FirebaseAuth, đăng nhập, đăng ký, đồng bộ user profile
│   │   ├── quiz_provider.dart          # Quản lý đề thi, câu hỏi, chủ đề, kết quả, sổ câu sai, bookmarks
│   │   ├── exam_session_provider.dart  # Phiên thi, đồng hồ đếm ngược, xáo trộn câu hỏi, auto-submit, recovery
│   │   └── notification_provider.dart  # Quản lý danh sách thông báo & đánh dấu đã đọc
│   ├── services/                       # Tầng xử lý dữ liệu & nghiệp vụ
│   │   ├── firebase_service.dart       # CRUD Firestore trực tiếp cho 8 collection
│   │   ├── quiz_repository.dart        # Kho dữ liệu trung gian: Cache bộ nhớ + Đồng bộ Firestore + Offline Mock
│   │   └── mock_data.dart              # Dữ liệu hạt giống (Seed Data) chuẩn
│   └── views/                          # Giao diện người dùng
│       ├── main_layout_shell.dart      # Shell điều hướng chung (Sidebar Web / BottomNav Mobile)
│       ├── auth/auth_screen.dart       # Màn hình Đăng nhập / Đăng ký & Nút chọn nhanh tài khoản demo
│       ├── home/home_screen.dart       # Trang chủ tổng quan thống kê, đề thi nổi bật
│       ├── exam/                       # Luồng làm bài thi và luyện tập
│       │   ├── exam_list_screen.dart
│       │   ├── exam_taking_screen.dart
│       │   ├── exam_result_screen.dart
│       │   ├── history_screen.dart
│       │   ├── mistake_notebook_screen.dart
│       │   └── bookmarks_screen.dart
│       ├── admin/                      # Quản trị viên & Giáo viên
│       │   ├── create_exam_screen.dart
│       │   ├── manage_questions_screen.dart
│       │   ├── add_question_sheet.dart
│       │   ├── manage_categories_screen.dart
│       │   ├── manage_users_screen.dart
│       │   └── overall_leaderboard_screen.dart
│       ├── profile/profile_screen.dart # Hồ sơ người dùng, đổi thông tin, kiểm tra kết nối Firebase
│       └── widgets/                    # Các thành phần tái sử dụng (AppHeader, ExamCard, MediaView,...)
├── test/
│   ├── exam_logic_test.dart            # Unit test logic chấm điểm, luyện câu sai, hết giờ tự nộp bài (Offline Mock)
│   └── widget_test.dart                # Widget smoke test kiểm thử luồng đăng nhập trên Desktop & Mobile
├── pubspec.yaml                        # Danh mục dependencies & assets
└── README.md                           # Tài liệu hướng dẫn chi tiết dự án
```

---

## 👥 Tài Khoản Thử Nghiệm & Seed Dữ Liệu

Ứng dụng tích hợp sẵn 3 tài khoản thử nghiệm tương ứng 3 vai trò. Mật khẩu mặc định cho tất cả tài khoản là: **`123456`**

| Vai Trò | Tên đăng nhập | Email Đăng Nhập | Mật Khẩu | Quyền Hạn Nổi Bật |
| :--- | :--- | :--- | :--- | :--- |
| **Học viên** | `duyki` | `duyki@edutech.vn` | `123456` | Thi trắc nghiệm, luyện câu sai, xem bảng xếp hạng |
| **Giáo viên** | `gv_huong` | `huong.gv@edutech.vn` | `123456` | Toàn bộ quyền học viên + Thêm/Sửa đề thi, câu hỏi, chủ đề |
| **Quản trị viên** | `admin` | `admin@edutech.vn` | `123456` | Toàn quyền hệ thống + Quản trị người dùng + Seed dữ liệu mẫu |

### 🌱 Khởi Tạo Dữ Liệu Mẫu Lên Firebase (Seed Data)
1. Đăng nhập bằng tài khoản **Admin** (`admin` / `123456`).
2. Trên thanh **Header** hoặc tại trang **Hồ sơ cá nhân**, nhấn nút **"Tạo dữ liệu mẫu"**.
3. Hệ thống sẽ tự động:
   - Tạo sẵn 3 tài khoản mẫu trên `Firebase Authentication`.
   - Đẩy toàn bộ danh mục chủ đề, bộ đề thi, ngân hàng câu hỏi đa phương tiện, lịch sử thi và sổ câu sai mẫu lên 8 collection trên `Cloud Firestore`.

---

## ▶️ Cài Đặt & Khởi Chạy Ứng Dụng

### 1. Yêu Cầu Môi Trường
- Flutter SDK: `>= 3.13.3` (khuyến nghị Flutter 3.24 trở lên).
- Dart SDK: `>= 3.1.0`.
- Thiết bị thử nghiệm: Trình duyệt Google Chrome, Android Emulator/Thiết bị thật, hoặc Windows Desktop.

### 2. Cài Đặt Thư Viện
Mở terminal tại thư mục gốc của dự án:
```bash
flutter pub get
```

### 3. Khởi Chạy Ứng Dụng
- **Chạy trên trình duyệt Web (Google Chrome):**
  ```bash
  flutter run -d chrome
  ```
- **Chạy trên thiết bị di động Android:**
  ```bash
  flutter run
  ```
- **Chạy trên nền tảng Windows:**
  ```bash
  flutter run -d windows
  ```

---

## 🔥 Cấu Hình & Triển Khai Firebase

Dự án đã được cấu hình sẵn với Firebase Project: **`ltdd-app-trac-nghiem`** và Application ID Android: **`vn.edutech.app_trac_nghiem`**.

### 1. Cấu hình tự động bằng FlutterFire CLI (Nếu cấu hình sang Project mới)
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<TEN_FIREBASE_PROJECT_CUA_BAN> --platforms=android,web,windows -y
```

### 2. Bật Dịch Vụ Trên Firebase Console
Vào [Firebase Console](https://console.firebase.google.com/):
1. **Authentication**:
   - Truy cập **Build -> Authentication -> Sign-in method**.
   - Bật phương thức **Email/Password**.
2. **Cloud Firestore**:
   - Truy cập **Build -> Firestore Database -> Create database**.
   - Chọn vị trí máy chủ (ví dụ `asia-southeast1` hoặc `nam5 (us-central)`).
   - Chọn chế độ ban đầu (Production hoặc Test mode).

### 3. Triển Khai Quy Tắc Bảo Mật (`firestore.rules`)
Quy tắc bảo mật đã được thiết kế sẵn trong file `firestore.rules`:
- Học viên chỉ được xem và ghi kết quả, câu sai, bookmark, thông báo của chính mình (`request.auth.uid == userId`).
- Người dùng đăng nhập đều có thể đọc đề thi, câu hỏi và chủ đề.
- Chỉ Giáo viên và Admin mới có quyền tạo, sửa, xóa đề thi, câu hỏi, chủ đề.
- Chỉ Admin mới có quyền thay đổi vai trò (`role`) của người dùng trong collection `users`.

Để deploy rules lên Firebase:
```bash
firebase deploy --only firestore:rules
```

---

## 🧪 Kiểm Thử (Unit & Widget Tests)

Toàn bộ logic nghiệp vụ và giao diện cốt lõi được bảo đảm thông qua bộ test tự động độc lập mạng (sử dụng Repository giả lập):

1. **`test/exam_logic_test.dart`**:
   - Chấm điểm chính xác câu đúng, câu sai và câu bỏ trống theo thang điểm 10.
   - Chế độ luyện câu sai (`maDeThi=9999`) chấm điểm trực tiếp theo danh sách câu hỏi của phiên thi.
   - Hết giờ tự động nộp bài và kích hoạt callback/ValueNotifier.
   - Chế độ luyện tập (`isPractice`) không ghi kết quả, không tăng lượt thi, không ghi nhận sổ câu sai.
   - Trả lời đúng trong chế độ luyện câu sai tự động giảm số lần sai và loại khỏi sổ khi về 0.

2. **`test/widget_test.dart`**:
   - Smoke test giao diện Desktop: Đăng nhập bằng tài khoản mẫu, hiển thị Header, Sidebar, danh sách đề thi.
   - Smoke test giao diện Mobile: Đăng nhập tài khoản, hiển thị Bottom Navigation, mở form tạo đề thi và nhập liệu.

### Chạy kiểm thử:
```bash
# Kiểm tra phân tích tĩnh (Clean 100% không cảnh báo)
flutter analyze

# Chạy toàn bộ bộ test tự động
flutter test
```
*Kết quả kiểm thử thực tế: `All tests passed! (8/8)`.*

---

## 📤 Hướng Dẫn Push Code Lên GitHub

Mã nguồn hoàn chỉnh với toàn bộ tính năng và kết nối Firebase hiện đang nằm trên nhánh **`firebase`**.

### Cách 1: Đẩy nhánh `firebase` lên GitHub (Khuyến nghị)
```bash
# 1. Đảm bảo đang ở nhánh firebase
git checkout firebase

# 2. Đẩy nhánh firebase lên remote repository
git push -u origin firebase
```
*Sau đó, bạn có thể tạo Pull Request trên GitHub từ nhánh `firebase` vào nhánh `main`.*

### Cách 2: Hợp nhất (Merge) vào nhánh `main` rồi đẩy lên
Nếu bạn muốn cập nhật trực tiếp mã nguồn mới vào nhánh `main`:
```bash
# 1. Chuyển sang nhánh main
git checkout main

# 2. Hợp nhất nhánh firebase vào main
git merge firebase

# 3. Đẩy nhánh main lên GitHub
git push origin main
```

---

## 👨‍💻 Tác Giả & Bản Quyền
- **Dự án**: Ứng dụng thi trắc nghiệm trực tuyến Edutech.
- **Học phần**: Lập trình thiết bị di động (LTDD).
- Giữ nguyên bản quyền giao diện và tài sản dự án © 2026.
