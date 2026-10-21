import 'de_thi.dart';

class DeThiYeuThich {
  final int id;
  final String userId;
  final int maDeThi;
  final DeThi? deThi;
  final DateTime ngayLuu;

  DeThiYeuThich({
    required this.id,
    required this.userId,
    required this.maDeThi,
    this.deThi,
    DateTime? ngayLuu,
  }) : ngayLuu = ngayLuu ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'maDeThi': maDeThi,
    'ngayLuu': ngayLuu.toIso8601String(),
  };

  factory DeThiYeuThich.fromJson(Map<String, dynamic> json, {DeThi? deThi}) => DeThiYeuThich(
    id: json['id'] ?? 0,
    userId: json['userId'] ?? '',
    maDeThi: json['maDeThi'] ?? 0,
    deThi: deThi,
    ngayLuu: json['ngayLuu'] != null ? DateTime.parse(json['ngayLuu']) : DateTime.now(),
  );
}
