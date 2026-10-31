# Kế Hoạch & Bộ Prompt Tối Ưu UI/UX App Trắc Nghiệm
> **Phiên bản Dành Cho Fresher (Người Mới Học Flutter)**  
> *Định hướng: Giao diện Tối Giản Hiện Đại - Trải Nghiệm Mượt Mà - Dễ Hiểu, Dễ Sửa, Không Bị Rối Code*

---

## 💡 Lời Mở Đầu Dành Cho Bạn (Fresher)

Khi mới làm quen với Flutter, bạn không cần phải dùng những kiến trúc quá phức tạp hay các thư viện hiệu ứng cao siêu. 
Bí quyết để app **đẹp mắt, mượt mà và tối giản** chỉ nằm ở 4 quy tắc cơ bản:
1. **Không gian thở (Spacing & Padding)**: Không nhồi nhét, các phần tử cách nhau đều đặn (8px, 12px, 16px, 24px).
2. **Bo góc & Viền nhẹ nhàng (Radius & Border)**: Dùng `BorderRadius.circular(12)` hoặc `16`, viền mỏng màu xám nhạt (`Color(0xFFE2E8F0)`), hạn chế bóng đổ đen sì.
3. **Màu sắc tập trung**: Chọn 1 màu chính (Xanh Dương Cobalt `0xFF2563EB`) và nền xám trắng sáng sủa (`0xFFF8FAFC`).
4. **Hiệu ứng mượt mà đơn giản**: Dùng các Widget có sẵn của Flutter như `AnimatedContainer`, `InkWell` với độ trễ ngắn (150ms - 200ms) để khi bấm chọn đáp án thì đổi màu êm ái.

> ⚠️ **NGUYÊN TẮC VÀNG CHO FRESHER: "ĐỔI ÁO (UI) - KHÔNG ĐỔI RUỘT (LOGIC)"**  
> Khi sửa giao diện, bạn chỉ thay đổi phần `build()`, các Widget hiển thị (`Container`, `Card`, `Text`, `Row`, `Column`).  
> **Tuyệt đối giữ nguyên** các biến dữ liệu, các hàm gọi `context.read<QuizProvider>()`, `context.read<ExamSessionProvider>()` và các sự kiện `onTap`, `onPressed` hiện có!

---

## 🎨 1. BẢNG MÀU & THÔNG SỐ ĐƠN GIẢN (COPY VÀO DÙNG NGAY)

Bạn hãy cập nhật hoặc tham chiếu các màu sắc này trong file [`lib/core/theme/app_colors.dart`](file:///d:/LTDD-app_trac_nghiem/lib/core/theme/app_colors.dart):

```dart
// lib/core/theme/app_colors.dart (Phiên bản Tối Giản - Dễ Nhớ)
import 'package:flutter/material.dart';

class AppColors {
  // 1. Màu nền & Bề mặt (Sáng sủa, sạch sẽ)
  static const Color background = Color(0xFFF8FAFC);    // Nền toàn app (Xám ngọc trai nhẹ)
  static const Color surface = Color(0xFFFFFFFF);       // Nền của thẻ Card (Trắng tinh)
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Nền ô nhập liệu hoặc ô hover

  // 2. Màu chữ (Phân cấp rõ ràng)
  static const Color textPrimary = Color(0xFF0F172A);   // Chữ tiêu đề chính (Đen than đậm)
  static const Color textSecondary = Color(0xFF475569); // Chữ mô tả, nội dung câu hỏi
  static const Color textMuted = Color(0xFF94A3B8);     // Chữ phụ, ngày giờ, số câu

  // 3. Đường viền mỏng (Tạo nét sắc sảo, không thô)
  static const Color border = Color(0xFFE2E8F0);        // Viền thẻ thông thường (1px)
  static const Color borderLight = Color(0xFFF1F5F9);   // Đường kẻ phân cách (Divider)

  // 4. Màu chủ đạo (Xanh Cobalt hiện đại)
  static const Color primary = Color(0xFF2563EB);       // Nút bấm chính, viền khi chọn
  static const Color primarySoft = Color(0xFFEFF6FF);   // Nền xanh rất nhạt khi chọn đáp án

  // 5. Màu kết quả & trạng thái
  static const Color success = Color(0xFF10B981);       // Câu đúng (Xanh lá)
  static const Color successSoft = Color(0xFFECFDF5);   // Nền câu đúng
  static const Color danger = Color(0xFFEF4444);        // Câu sai / Hết giờ (Đỏ)
  static const Color dangerSoft = Color(0xFFFEE2E2);    // Nền câu sai
  static const Color warning = Color(0xFFF59E0B);       // Huy chương vàng / Đếm ngược
}
```

---

## 🗺️ 2. LỘ TRÌNH 4 BƯỚC THỰC HIỆN DÀNH CHO FRESHER

Đừng sửa tất cả cùng lúc! Hãy làm từng bước một theo thứ tự sau:

```
[Bước 1: Học tập]  --->  [Bước 2: Cá nhân]  --->  [Bước 3: Bảng vàng]  --->  [Bước 4: Quản lý]
(Trang chủ, Thi,        (Hồ sơ, Nhật ký        (Bục Top 3,             (Tạo đề, Sửa câu,
 Kết quả, Câu sai)       học tập)               Danh sách xếp hạng)     Danh mục, User)
```

Mỗi bước dưới đây đã chuẩn bị sẵn **Prompt** để bạn copy gửi cho AI. AI sẽ viết code mẫu rõ ràng, có chú thích tiếng Việt và dùng các Widget thân thiện nhất cho bạn.

---

## 🤖 3. BỘ PROMPT CHI TIẾT (COPY GỬI CHO AI HỖ TRỢ CODE)

---

### PROMPT 1: PHÂN HỆ HỌC TẬP (Mục quan trọng nhất của App)

> **Copy toàn bộ đoạn bên dưới gửi cho AI khi bạn muốn làm mới giao diện Học tập:**

```markdown
Chào bạn, tôi là Fresher mới tiếp cận lập trình Flutter.
Tôi muốn làm lại giao diện (UI) và trải nghiệm (UX) cho PHÂN HỆ HỌC TẬP trong app thi trắc nghiệm Edutech.

Các file liên quan trong dự án:
- `lib/views/home/home_screen.dart` (Trang chủ học tập)
- `lib/views/exam/exam_list_screen.dart` (Danh sách đề thi)
- `lib/views/exam/exam_taking_screen.dart` (Màn hình làm bài thi)
- `lib/views/exam/exam_result_screen.dart` (Màn hình kết quả & xem lại đáp án)
- `lib/views/exam/mistake_notebook_screen.dart` (Sổ tay câu sai)
- `lib/views/widgets/exam_card.dart` (Thẻ hiển thị đề thi)

YÊU CẦU ĐẶC BIỆT DÀNH CHO FRESHER:
1. GIỮ NGUYÊN 100% LOGIC CŨ:
   - Giữ nguyên các hàm: bắt đầu thi (`onStartExam`), nộp bài, đồng hồ đếm ngược, cảnh báo khi thoát màn hình thi.
   - Giữ nguyên hiển thị âm thanh nghe (Audio MP3, TTS) và hình ảnh câu hỏi.
   - Giữ nguyên logic lưu sổ câu sai và danh sách đề yêu thích.
2. PHONG CÁCH TỐI GIẢN & MƯỢT MÀ:
   - Sử dụng màu từ `AppColors`: nền trắng `AppColors.surface`, viền mỏng `AppColors.border`, màu chính `AppColors.primary`.
   - Trang chủ: Bỏ các gradient màu mè gây chói mắt. Làm Hero banner màu xanh trang nhã, các thẻ thống kê (Điểm TB, Đã thi, Câu sai) dùng card bo góc 16px, icon gọn gàng.
   - Màn hình làm bài (`ExamTakingScreen`):
     + Header đếm ngược thời gian gọn nhẹ, dễ nhìn.
     + Câu hỏi hiển thị chữ to rõ (17px - 18px), khoảng cách dòng thoáng.
     + Các nút chọn đáp án A, B, C, D: Dùng `AnimatedContainer` để khi người dùng ấn vào sẽ đổi sang nền xanh nhạt `AppColors.primarySoft` và viền xanh `AppColors.primary` một cách mượt mà (thời gian 150ms).
     + Thanh điều hướng dưới cùng: Nút "Câu trước", "Đánh dấu cờ", "Câu tiếp", "Nộp bài" to rõ, dễ bấm bằng ngón cái.
   - Màn hình kết quả (`ExamResultScreen`):
     + Hiển thị điểm số dạng vòng tròn hoặc thẻ to rõ ràng (thang điểm 10).
     + Phân biệt câu đúng (màu xanh lá nhạt) và câu sai (màu đỏ nhạt), bấm vào từng câu để xem lời giải thích chi tiết.
3. CÁCH VIẾT CODE:
   - Hãy dùng các Widget cơ bản của Flutter: `Container`, `Card`, `Column`, `Row`, `AnimatedContainer`, `InkWell`, `ListView`.
   - Viết code sạch, chia thành các hàm nhỏ (ví dụ: `_buildHeader()`, `_buildOptionItem()`, `_buildQuestionBody()`).
   - Thêm chú thích (comment) tiếng Việt ở các đoạn quan trọng để tôi học hỏi và hiểu được code.
```

---

### PROMPT 2: PHÂN HỆ CÁ NHÂN (Hồ sơ & Nhật ký làm bài)

> **Copy đoạn bên dưới gửi cho AI khi bạn làm mục Cá nhân:**

```markdown
Chào bạn, tôi là Fresher mới học Flutter.
Tôi muốn làm lại giao diện cho PHÂN HỆ CÁ NHÂN trong app trắc nghiệm Edutech.

Các file liên quan trong dự án:
- `lib/views/profile/profile_screen.dart` (Hồ sơ cá nhân)
- `lib/views/exam/history_screen.dart` (Nhật ký làm bài thi)
- `lib/views/widgets/role_switcher_dialog.dart` (Hộp thoại đổi vai trò demo)

YÊU CẦU ĐẶC BIỆT DÀNH CHO FRESHER:
1. GIỮ NGUYÊN CHỨC NĂNG:
   - Giữ nguyên Form sửa thông tin: Họ tên, Số điện thoại, Điểm mục tiêu.
   - Giữ nguyên các hàm cập nhật `auth.updateProfile(...)` và logic xem lại chi tiết bài thi cũ (`onViewResult`).
   - Giữ nguyên nút chuyển đổi tài khoản demo (Học viên, Giáo viên, Admin) và nút Đăng xuất.
2. THIẾT KẾ TỐI GIẢN & THÂN THIỆN:
   - Màn hình Hồ sơ (`ProfileScreen`):
     + Phần trên cùng: Avatar tròn đơn giản, hiển thị họ tên to rõ và huy hiệu vai trò (Học viên / Giáo viên) nhỏ nhắn bên dưới.
     + Thẻ "Mục tiêu học tập": Hiển thị điểm mục tiêu (ví dụ: 8.5/10) kèm một thanh `LinearProgressIndicator` bo tròn để so sánh với điểm trung bình hiện tại.
     + Form thông tin: Các ô `TextFormField` có viền xám nhạt `AppColors.border`, khi bấm vào gõ chữ thì viền chuyển sang màu xanh `AppColors.primary`.
     + Nút "Chỉnh sửa" và "Lưu thay đổi" bố trí rõ ràng, dễ thấy.
   - Màn hình Nhật ký (`HistoryScreen`):
     + Hiển thị danh sách các bài thi đã làm dưới dạng các thẻ Card trắng sạch sẽ (`ListView.separated`).
     + Mỗi thẻ hiển thị: Tên bài thi, ngày giờ thi, thời gian làm bài, và Badge điểm số ở bên phải (>= 8 điểm màu xanh, < 5 điểm màu đỏ).
     + Khi bấm vào thẻ sẽ mở lại màn hình xem lại kết quả chi tiết.
     + Nếu chưa làm bài thi nào, hiển thị icon nhẹ nhàng và chữ: "Bạn chưa làm bài thi nào, hãy bắt đầu ngay nhé!".
3. CÁCH VIẾT CODE:
   - Sử dụng các Widget dễ hiểu: `TextFormField`, `Card`, `ListTile`, `ElevatedButton`, `Divider`.
   - Có comment giải thích các phần xử lý `TextEditingController` và `FormState` để tôi dễ nắm bắt.
```

---

### PROMPT 3: PHÂN HỆ BẢNG VÀNG (Bảng xếp hạng & Bục vinh danh)

> **Copy đoạn bên dưới gửi cho AI khi làm mục Bảng vàng:**

```markdown
Chào bạn, tôi là Fresher mới học Flutter.
Tôi muốn làm lại giao diện cho PHÂN HỆ BẢNG VÀNG (Bảng xếp hạng thành tích) trong app trắc nghiệm.

File liên quan trong dự án:
- `lib/views/admin/overall_leaderboard_screen.dart` (Màn hình Bảng xếp hạng)

YÊU CẦU ĐẶC BIỆT DÀNH CHO FRESHER:
1. GIỮ NGUYÊN CHỨC NĂNG:
   - Lấy dữ liệu danh sách người dùng từ `quiz.getOverallLeaderboard()`.
   - Hiển thị đầy đủ: Thứ hạng, Avatar/Tên, số bài thi đã làm, điểm trung bình.
   - Nút mũi tên quay lại trang chủ (`onBack`).
2. THIẾT KẾ TỐI GIẢN NHƯNG ĐẸP MẮT:
   - Bục vinh danh Top 3 (Podium):
     + Dùng 1 `Row` với 3 cột (`Column`) đặt cạnh nhau theo chiều cao tăng dần:
       * Hạng 2 (Bạc): Đặt bên trái, cao vừa phải (khoảng 140px).
       * Hạng 1 (Vàng): Đặt ở giữa, cao nhất (khoảng 175px), có viền vàng cam nhẹ `0xFFF59E0B`.
       * Hạng 3 (Đồng): Đặt bên phải, thấp hơn hạng 2 một chút (khoảng 120px).
     + Mỗi bục có Avatar, Tên học viên, icon huy chương (🥇, 🥈, 🥉) và điểm số trung bình.
   - Danh sách từ Hạng 4 trở đi:
     + Nằm trong một `Container` nền trắng, bo góc 16px, viền mỏng `AppColors.border`.
     + Dùng `ListView.builder` hiển thị từng dòng: Số thứ tự (#4, #5,...), Avatar tròn nhỏ, Tên học viên, Điểm trung bình.
     + Nếu dòng nào là tài khoản của người đang đăng nhập, hãy đổi nền sang màu xanh nhạt `AppColors.primarySoft` để người dùng dễ nhận ra vị trí của mình.
3. CÁCH VIẾT CODE:
   - Viết hàm `_buildPodiumItem(...)` nhận các tham số (thứ hạng, tên, điểm, chiều cao cột) để tái sử dụng, giúp code ngắn và dễ đọc.
   - Tránh dùng các thư viện ngoài, chỉ dùng Widget thuần của Flutter.
```

---

### PROMPT 4: PHÂN HỆ QUẢN LÝ (Dành cho Giáo viên & Admin)

> **Copy đoạn bên dưới gửi cho AI khi làm mục Quản lý:**

```markdown
Chào bạn, tôi là Fresher mới học Flutter.
Tôi muốn làm lại giao diện cho PHÂN HỆ QUẢN LÝ (Dành cho Giáo viên & Admin) trong app trắc nghiệm Edutech.

Các file liên quan:
- `lib/views/admin/create_exam_screen.dart` (Tạo & Sửa đề thi)
- `lib/views/admin/manage_questions_screen.dart` (Danh sách câu hỏi trong đề)
- `lib/views/admin/add_question_sheet.dart` (Biểu mẫu thêm/sửa câu hỏi trắc nghiệm)
- `lib/views/admin/manage_categories_screen.dart` (Quản lý môn học/chủ đề)
- `lib/views/admin/manage_users_screen.dart` (Quản lý người dùng)

YÊU CẦU ĐẶC BIỆT DÀNH CHO FRESHER:
1. GIỮ NGUYÊN CHỨC NĂNG QUAN TRỌNG:
   - Giữ nguyên toàn bộ logic thêm/sửa/xóa câu hỏi với các loại media:
     + Câu hỏi chữ (Text).
     + Câu hỏi đính kèm hình ảnh.
     + Câu hỏi âm thanh (File MP3 nghe hoặc Text-to-Speech).
     + 4 đáp án A, B, C, D, chọn 1 đáp án đúng và lời giải thích.
   - Giữ nguyên các thao tác lưu vào `QuizProvider` và kiểm tra form validation (không bỏ trống tên đề, thời gian, đáp án).
2. THIẾT KẾ TỐI GIẢN, GỌN GÀNG, KHÔNG RỐI MẮT:
   - Màn hình Tạo/Sửa đề thi (`CreateExamScreen`):
     + Các ô nhập: Tên đề thi, Thời gian làm bài (phút), Độ khó (Dễ/TB/Khó), Chủ đề môn học được sắp xếp thẳng hàng, khoảng cách đều 16px.
     + Nút chuyển đổi (Switch) "Công khai đề thi" mượt mà.
     + Nút "Quản lý câu hỏi trong đề thi" thiết kế to rõ, dễ bấm.
   - Màn hình Quản lý câu hỏi (`ManageQuestionsScreen`):
     + Mỗi câu hỏi hiển thị trong một Card trắng, có đánh số (Câu 1, Câu 2,...).
     + Có biểu tượng nhỏ cho biết loại câu hỏi (Ảnh 📷, Audio 🎧, Chữ 📝).
     + Hiển thị 4 phương án, phương án đúng có dấu tích xanh lá.
     + Hai nút "Sửa" và "Xóa" đặt ở góc phải, khi bấm "Xóa" hiện `AlertDialog` hỏi lại để tránh xóa nhầm.
   - Biểu mẫu Thêm câu hỏi (`AddQuestionSheet`):
     + Thiết kế dạng Bottom Sheet kéo lên từ dưới hoặc Dialog giữa màn hình.
     + Ô nhập đáp án A, B, C, D có sẵn nút chọn tròn (Radio) ở đầu dòng để chọn ngay đáp án đúng một cách tiện lợi.
3. CÁCH VIẾT CODE:
   - Dùng các Widget thân thiện: `TextFormField`, `DropdownButtonFormField`, `SwitchListTile`, `Card`, `showModalBottomSheet`.
   - Có comment tiếng Việt hướng dẫn cách xử lý tránh lỗi tràn màn hình khi bật bàn phím ảo (`SingleChildScrollView` + `bottom: MediaQuery.of(context).viewInsets.bottom`).
```

---

## ✅ 4. BẢNG CHECKLIST KIỂM TRA DÀNH CHO BẠN (Sau khi sửa code)

Sau khi dán code mới vào, bạn hãy kiểm tra 5 điều này trên máy ảo hoặc trình duyệt:

- [ ] **1. Không có vạch vàng đen (No Overflow Error)**: Khi mở bàn phím gõ chữ hoặc xoay ngang màn hình, app không bị lỗi `A RenderFlex overflowed by ... pixels`.
- [ ] **2. Bấm nút không bị đơ**: Mọi nút bấm (Làm bài, Chọn đáp án, Nộp bài) đều có hiệu ứng phản hồi và chuyển trang mượt mà.
- [ ] **3. Chữ đọc rõ ràng**: Khoảng cách chữ thoải mái, màu chữ đen than dễ đọc trên nền xám trắng sáng.
- [ ] **4. Điểm số và thời gian chạy đúng**: Đồng hồ đếm ngược chạy bình thường, nộp bài tính đúng điểm thang 10.
- [ ] **5. Thử nghiệm trên cả Mobile và Web**: Màn hình điện thoại hiển thị gọn gàng, màn hình Web mở rộng canh giữa không bị méo mó.

---
*Kế hoạch được cập nhật và tối ưu cho Fresher tại [`UI_UX_REDESIGN_PLAN.md`](file:///d:/LTDD-app_trac_nghiem/UI_UX_REDESIGN_PLAN.md).*
