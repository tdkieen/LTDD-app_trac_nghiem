class CauHoi {
  final int maCauHoi;
  final String noiDung;
  final String? phuongAnA;
  final String? phuongAnB;
  final String? phuongAnC;
  final String? phuongAnD;
  final String? dapAnDung; // "A", "B", "C", "D"
  final String? mucDoKho;
  final int maChuDe;
  final int? maDeThi;
  final String? audioPath;
  final bool laCauHoiNghe;
  final String? giaiThich;

  CauHoi({
    required this.maCauHoi,
    required this.noiDung,
    this.phuongAnA,
    this.phuongAnB,
    this.phuongAnC,
    this.phuongAnD,
    this.dapAnDung,
    this.mucDoKho = 'Trung bình',
    required this.maChuDe,
    this.maDeThi,
    this.audioPath,
    this.laCauHoiNghe = false,
    this.giaiThich,
  });

  String getOption(String key) {
    switch (key.toUpperCase().trim()) {
      case 'A':
        return phuongAnA ?? '';
      case 'B':
        return phuongAnB ?? '';
      case 'C':
        return phuongAnC ?? '';
      case 'D':
        return phuongAnD ?? '';
      default:
        return '';
    }
  }

  CauHoi copyWith({
    int? maCauHoi,
    String? noiDung,
    String? phuongAnA,
    String? phuongAnB,
    String? phuongAnC,
    String? phuongAnD,
    String? dapAnDung,
    String? mucDoKho,
    int? maChuDe,
    int? maDeThi,
    String? audioPath,
    bool? laCauHoiNghe,
    String? giaiThich,
  }) {
    return CauHoi(
      maCauHoi: maCauHoi ?? this.maCauHoi,
      noiDung: noiDung ?? this.noiDung,
      phuongAnA: phuongAnA ?? this.phuongAnA,
      phuongAnB: phuongAnB ?? this.phuongAnB,
      phuongAnC: phuongAnC ?? this.phuongAnC,
      phuongAnD: phuongAnD ?? this.phuongAnD,
      dapAnDung: dapAnDung ?? this.dapAnDung,
      mucDoKho: mucDoKho ?? this.mucDoKho,
      maChuDe: maChuDe ?? this.maChuDe,
      maDeThi: maDeThi ?? this.maDeThi,
      audioPath: audioPath ?? this.audioPath,
      laCauHoiNghe: laCauHoiNghe ?? this.laCauHoiNghe,
      giaiThich: giaiThich ?? this.giaiThich,
    );
  }

  Map<String, dynamic> toJson() => {
    'maCauHoi': maCauHoi,
    'noiDung': noiDung,
    'phuongAnA': phuongAnA,
    'phuongAnB': phuongAnB,
    'phuongAnC': phuongAnC,
    'phuongAnD': phuongAnD,
    'dapAnDung': dapAnDung,
    'mucDoKho': mucDoKho,
    'maChuDe': maChuDe,
    'maDeThi': maDeThi,
    'audioPath': audioPath,
    'laCauHoiNghe': laCauHoiNghe,
    'giaiThich': giaiThich,
  };

  factory CauHoi.fromJson(Map<String, dynamic> json) => CauHoi(
    maCauHoi: json['maCauHoi'] ?? 0,
    noiDung: json['noiDung'] ?? '',
    phuongAnA: json['phuongAnA'],
    phuongAnB: json['phuongAnB'],
    phuongAnC: json['phuongAnC'],
    phuongAnD: json['phuongAnD'],
    dapAnDung: json['dapAnDung'],
    mucDoKho: json['mucDoKho'] ?? 'Trung bình',
    maChuDe: json['maChuDe'] ?? 0,
    maDeThi: json['maDeThi'],
    audioPath: json['audioPath'],
    laCauHoiNghe: json['laCauHoiNghe'] ?? false,
    giaiThich: json['giaiThich'],
  );
}
