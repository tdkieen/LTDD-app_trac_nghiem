class ThongBao {
  final int id;
  final String? userId; // null = gửi toàn hệ thống
  final String noiDung;
  final String? duongDan;
  final String loaiIcon; // "info", "success", "warning"
  final bool daDoc;
  final DateTime thoiGian;

  ThongBao({
    required this.id,
    this.userId,
    required this.noiDung,
    this.duongDan,
    this.loaiIcon = 'info',
    this.daDoc = false,
    DateTime? thoiGian,
  }) : thoiGian = thoiGian ?? DateTime.now();

  ThongBao copyWith({
    int? id,
    String? userId,
    String? noiDung,
    String? duongDan,
    String? loaiIcon,
    bool? daDoc,
    DateTime? thoiGian,
  }) {
    return ThongBao(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      noiDung: noiDung ?? this.noiDung,
      duongDan: duongDan ?? this.duongDan,
      loaiIcon: loaiIcon ?? this.loaiIcon,
      daDoc: daDoc ?? this.daDoc,
      thoiGian: thoiGian ?? this.thoiGian,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'noiDung': noiDung,
    'duongDan': duongDan,
    'loaiIcon': loaiIcon,
    'daDoc': daDoc,
    'thoiGian': thoiGian.toIso8601String(),
  };

  factory ThongBao.fromJson(Map<String, dynamic> json) => ThongBao(
    id: json['id'] ?? 0,
    userId: json['userId'],
    noiDung: json['noiDung'] ?? '',
    duongDan: json['duongDan'],
    loaiIcon: json['loaiIcon'] ?? 'info',
    daDoc: json['daDoc'] ?? false,
    thoiGian: json['thoiGian'] != null ? DateTime.parse(json['thoiGian']) : DateTime.now(),
  );
}
