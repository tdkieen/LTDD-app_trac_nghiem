class ChuDe {
  final int maChuDe;
  final String tenChuDe;
  final int? maChuDeCha;
  final String? icon;

  const ChuDe({
    required this.maChuDe,
    required this.tenChuDe,
    this.maChuDeCha,
    this.icon,
  });

  ChuDe copyWith({
    int? maChuDe,
    String? tenChuDe,
    int? maChuDeCha,
    String? icon,
  }) {
    return ChuDe(
      maChuDe: maChuDe ?? this.maChuDe,
      tenChuDe: tenChuDe ?? this.tenChuDe,
      maChuDeCha: maChuDeCha ?? this.maChuDeCha,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() => {
    'maChuDe': maChuDe,
    'tenChuDe': tenChuDe,
    'maChuDeCha': maChuDeCha,
    'icon': icon,
  };

  factory ChuDe.fromJson(Map<String, dynamic> json) => ChuDe(
    maChuDe: json['maChuDe'] ?? 0,
    tenChuDe: json['tenChuDe'] ?? '',
    maChuDeCha: json['maChuDeCha'],
    icon: json['icon'],
  );
}
