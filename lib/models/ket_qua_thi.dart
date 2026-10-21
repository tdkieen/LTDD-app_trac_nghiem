import 'dart:convert';
import 'de_thi.dart';

class ChiTietKetQua {
  final int maCauHoi;
  final String noiDung;
  final String? phuongAnA;
  final String? phuongAnB;
  final String? phuongAnC;
  final String? phuongAnD;
  final String? dapAnChon;
  final String? dapAnDung;
  final bool laDung;

  ChiTietKetQua({
    required this.maCauHoi,
    required this.noiDung,
    this.phuongAnA,
    this.phuongAnB,
    this.phuongAnC,
    this.phuongAnD,
    this.dapAnChon,
    this.dapAnDung,
    required this.laDung,
  });

  Map<String, dynamic> toJson() => {
    'maCauHoi': maCauHoi,
    'noiDung': noiDung,
    'phuongAnA': phuongAnA,
    'phuongAnB': phuongAnB,
    'phuongAnC': phuongAnC,
    'phuongAnD': phuongAnD,
    'dapAnChon': dapAnChon,
    'dapAnDung': dapAnDung,
    'laDung': laDung,
  };

  factory ChiTietKetQua.fromJson(Map<String, dynamic> json) => ChiTietKetQua(
    maCauHoi: json['maCauHoi'] ?? 0,
    noiDung: json['noiDung'] ?? '',
    phuongAnA: json['phuongAnA'],
    phuongAnB: json['phuongAnB'],
    phuongAnC: json['phuongAnC'],
    phuongAnD: json['phuongAnD'],
    dapAnChon: json['dapAnChon'],
    dapAnDung: json['dapAnDung'],
    laDung: json['laDung'] ?? false,
  );
}

class KetQuaThi {
  final int maKetQua;
  final String userId;
  final int maDeThi;
  final double tongDiem; // 0.0 - 10.0
  final int soCauDung;
  final int tongSoCau;
  final int thoiGianLamGiay;
  final DateTime ngayThi;
  final List<ChiTietKetQua> chiTiet;
  final DeThi? deThi;
  final String? userName;

  KetQuaThi({
    required this.maKetQua,
    required this.userId,
    required this.maDeThi,
    required this.tongDiem,
    required this.soCauDung,
    this.tongSoCau = 10,
    this.thoiGianLamGiay = 0,
    DateTime? ngayThi,
    this.chiTiet = const [],
    this.deThi,
    this.userName,
  }) : ngayThi = ngayThi ?? DateTime.now();

  int get soCauSai => tongSoCau - soCauDung;
  double get tiLeDung => tongSoCau > 0 ? (soCauDung / tongSoCau) * 100 : 0;

  String get danhGia {
    if (tongDiem >= 8.5) return 'Xuất sắc! 🎉';
    if (tongDiem >= 7.0) return 'Giỏi! 👏';
    if (tongDiem >= 5.0) return 'Đạt yêu cầu ✓';
    return 'Cần cố gắng thêm 💪';
  }

  Map<String, dynamic> toJson() => {
    'maKetQua': maKetQua,
    'userId': userId,
    'maDeThi': maDeThi,
    'tongDiem': tongDiem,
    'soCauDung': soCauDung,
    'tongSoCau': tongSoCau,
    'thoiGianLamGiay': thoiGianLamGiay,
    'ngayThi': ngayThi.toIso8601String(),
    'chiTietJson': jsonEncode(chiTiet.map((e) => e.toJson()).toList()),
  };

  factory KetQuaThi.fromJson(Map<String, dynamic> json, {DeThi? deThi, String? userName}) {
    List<ChiTietKetQua> details = [];
    if (json['chiTietJson'] != null && json['chiTietJson'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(json['chiTietJson']) as List;
        details = decoded.map((e) => ChiTietKetQua.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    return KetQuaThi(
      maKetQua: json['maKetQua'] ?? 0,
      userId: json['userId'] ?? '',
      maDeThi: json['maDeThi'] ?? 0,
      tongDiem: (json['tongDiem'] as num?)?.toDouble() ?? 0.0,
      soCauDung: json['soCauDung'] ?? 0,
      tongSoCau: json['tongSoCau'] ?? 10,
      thoiGianLamGiay: json['thoiGianLamGiay'] ?? 0,
      ngayThi: json['ngayThi'] != null ? DateTime.parse(json['ngayThi']) : DateTime.now(),
      chiTiet: details,
      deThi: deThi,
      userName: userName,
    );
  }
}
