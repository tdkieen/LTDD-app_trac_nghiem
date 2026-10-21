import 'cau_hoi.dart';

class CauHoiSai {
  final int id;
  final String userId;
  final int maCauHoi;
  final CauHoi? cauHoi;
  final String? dapAnDaChon;
  final int lanSai;
  final DateTime lanCuoiSai;

  CauHoiSai({
    required this.id,
    required this.userId,
    required this.maCauHoi,
    this.cauHoi,
    this.dapAnDaChon,
    this.lanSai = 1,
    DateTime? lanCuoiSai,
  }) : lanCuoiSai = lanCuoiSai ?? DateTime.now();

  CauHoiSai copyWith({
    int? id,
    String? userId,
    int? maCauHoi,
    CauHoi? cauHoi,
    String? dapAnDaChon,
    int? lanSai,
    DateTime? lanCuoiSai,
  }) {
    return CauHoiSai(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      maCauHoi: maCauHoi ?? this.maCauHoi,
      cauHoi: cauHoi ?? this.cauHoi,
      dapAnDaChon: dapAnDaChon ?? this.dapAnDaChon,
      lanSai: lanSai ?? this.lanSai,
      lanCuoiSai: lanCuoiSai ?? this.lanCuoiSai,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'maCauHoi': maCauHoi,
    'dapAnDaChon': dapAnDaChon,
    'lanSai': lanSai,
    'lanCuoiSai': lanCuoiSai.toIso8601String(),
  };

  factory CauHoiSai.fromJson(Map<String, dynamic> json, {CauHoi? cauHoi}) => CauHoiSai(
    id: json['id'] ?? 0,
    userId: json['userId'] ?? '',
    maCauHoi: json['maCauHoi'] ?? 0,
    cauHoi: cauHoi,
    dapAnDaChon: json['dapAnDaChon'],
    lanSai: json['lanSai'] ?? 1,
    lanCuoiSai: json['lanCuoiSai'] != null ? DateTime.parse(json['lanCuoiSai']) : DateTime.now(),
  );
}
