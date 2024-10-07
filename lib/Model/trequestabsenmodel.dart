class TRequestAbsen {
  // Halaman request absent
  String? objId;
  DateTime? tglAwal;
  DateTime? tglAkhir;
  String? kdAbsen;
  String? nmAbsen;
  String? jenisKota;
  String? jenisCuti;
  double jmlHari;
  double jmlPotong;
  String? keterangan;
  String? requester;
  String? nik;
  String? status;
  String? userId;

  TRequestAbsen({
    this.objId,
    this.tglAwal,
    this.tglAkhir,
    this.kdAbsen,
    this.nmAbsen,
    this.jenisKota,
    this.jenisCuti,
    required this.jmlHari,
    required this.jmlPotong,
    this.keterangan,
    this.requester,
    this.nik,
    this.status,
    this.userId,
  });

  // You can add fromJson and toJson methods if you need to handle JSON data
  factory TRequestAbsen.fromJson(Map<String, dynamic> json) {
    return TRequestAbsen(
      objId: json['OBJ_ID'],
      tglAwal: DateTime.tryParse(json['TglAwal'] ?? ''),
      tglAkhir: DateTime.tryParse(json['TglAkhir'] ?? ''),
      kdAbsen: json['KD_ABSEN'],
      nmAbsen: json['NM_ABSEN'],
      jenisKota: json['JenisKota'],
      jenisCuti: json['JenisCuti'],
      jmlHari: (json['JmlHari'] ?? 0).toDouble(),
      jmlPotong: (json['JmlPotong'] ?? 0).toDouble(),
      keterangan: json['Keterangan'],
      requester: json['Requester'],
      nik: json['NIK'],
      status: json['Status'],
      userId: json['UserID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OBJ_ID': objId,
      'TglAwal': tglAwal?.toIso8601String(),
      'TglAkhir': tglAkhir?.toIso8601String(),
      'KD_ABSEN': kdAbsen,
      'NM_ABSEN': nmAbsen,
      'JenisKota': jenisKota,
      'JenisCuti': jenisCuti,
      'JmlHari': jmlHari,
      'JmlPotong': jmlPotong,
      'Keterangan': keterangan,
      'Requester': requester,
      'NIK': nik,
      'Status': status,
      'UserID': userId,
    };
  }
}
