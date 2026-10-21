import 'chu_de.dart';

class DeThi {
  final int maDeThi;
  final String tenDeThi;
  final int? soCauHoi;
  final int? thoiGian; // thời gian thi tính bằng phút
  final int maChuDe;
  final String? mucDoKho; // "Dễ", "Trung bình", "Khó"
  final ChuDe? chuDe;
  final int luotThi; // số lượt thí sinh đã thi
  final DateTime? ngayTao;

  DeThi({
    required this.maDeThi,
    required this.tenDeThi,
    this.soCauHoi = 10,
    this.thoiGian = 15,
    required this.maChuDe,
    this.mucDoKho = 'Trung bình',
    this.chuDe,
    this.luotThi = 0,
    this.ngayTao,
  });

  DeThi copyWith({
    int? maDeThi,
    String? tenDeThi,
    int? soCauHoi,
    int? thoiGian,
    int? maChuDe,
    String? mucDoKho,
    ChuDe? chuDe,
    int? luotThi,
    DateTime? ngayTao,
  }) {
    return DeThi(
      maDeThi: maDeThi ?? this.maDeThi,
      tenDeThi: tenDeThi ?? this.tenDeThi,
      soCauHoi: soCauHoi ?? this.soCauHoi,
      thoiGian: thoiGian ?? this.thoiGian,
      maChuDe: maChuDe ?? this.maChuDe,
      mucDoKho: mucDoKho ?? this.mucDoKho,
      chuDe: chuDe ?? this.chuDe,
      luotThi: luotThi ?? this.luotThi,
      ngayTao: ngayTao ?? this.ngayTao,
    );
  }

  Map<String, dynamic> toJson() => {
    'maDeThi': maDeThi,
    'tenDeThi': tenDeThi,
    'soCauHoi': soCauHoi,
    'thoiGian': thoiGian,
    'maChuDe': maChuDe,
    'mucDoKho': mucDoKho,
    'luotThi': luotThi,
    'ngayTao': ngayTao?.toIso8601String(),
  };

  factory DeThi.fromJson(Map<String, dynamic> json, {ChuDe? chuDe}) => DeThi(
    maDeThi: json['maDeThi'] ?? 0,
    tenDeThi: json['tenDeThi'] ?? '',
    soCauHoi: json['soCauHoi'] ?? 10,
    thoiGian: json['thoiGian'] ?? 15,
    maChuDe: json['maChuDe'] ?? 0,
    mucDoKho: json['mucDoKho'] ?? 'Trung bình',
    chuDe: chuDe,
    luotThi: json['luotThi'] ?? 0,
    ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
  );
}
