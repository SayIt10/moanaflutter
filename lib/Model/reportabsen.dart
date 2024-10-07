import 'dart:convert';

class ReportAbsen {
  String? nip;
  DateTime? startDate;
  DateTime? endDate;
  String? tanggal;
  String? jamMas;
  String? jamKel;
  String? keterangan;

  ReportAbsen({
    this.nip,
    this.startDate,
    this.endDate,
    this.tanggal,
    this.jamMas,
    this.jamKel,
    this.keterangan,
  });

  factory ReportAbsen.fromJson(Map<String, dynamic> json) {
    return ReportAbsen(
      nip: json['NIP'],
      startDate: DateTime.parse(json['StartDate']),
      endDate: DateTime.parse(json['EndDate']),
      tanggal: json['Tanggal'],
      jamMas: json['JAMAS'],
      jamKel: json['JAMKEL'],
      keterangan: json['Keterangan'],
    );
  }

  static List<ReportAbsen> fromJsonList(String jsonString) {
    final data = json.decode(jsonString);
    return List<ReportAbsen>.from(data.map((item) => ReportAbsen.fromJson(item)));
  }
}
