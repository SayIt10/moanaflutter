class Registers {
  final String deviceId;
  final String fingerId;
  final String nip;
  final String dob;
  final String registerDate;
  final String employeeName;
  final String deviceModel;
  final String deviceOS;

  Registers({
    required this.deviceId,
    required this.fingerId,
    required this.nip,
    required this.dob,
    required this.registerDate,
    required this.employeeName,
    this.deviceModel = '', // Provide default values to avoid null errors
    this.deviceOS = '', // Provide default values
  });

  factory Registers.fromJson(Map<String, dynamic> json) {
    return Registers(
      deviceId: json['DeviceID'] ?? '', // Check for null and provide empty string if null
      fingerId: json['FingerId'] ?? '',
      nip: json['NIP'] ?? '',
      dob: json['DOB'] ?? '',
      registerDate: json['RegisterDate'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      deviceModel: json['DeviceModel'] ?? '',
      deviceOS: json['DeviceOS'] ?? '',
    );
  }
}
