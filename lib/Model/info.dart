class Info {
  final int id;
  final String infoText;
  final String createdBy;
  final DateTime createdDate;
  final String? modifiedBy;
  final DateTime? modifiedDate;
  final bool isActive;

  Info({
    required this.id,
    required this.infoText,
    required this.createdBy,
    required this.createdDate,
    this.modifiedBy,
    this.modifiedDate,
    required this.isActive,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      id: json['id'],
      infoText: json['InfoText'] ?? '',
      createdBy: json['CreatedBy'] ?? '',
      createdDate: DateTime.parse(json['CreatedDate']),
      modifiedBy: json['ModifiedBy'], // Nullable field
      modifiedDate: json['ModifiedDate'] != "0001-01-01T00:00:00"
          ? DateTime.parse(json['ModifiedDate'])
          : null, // Handle default value
      isActive: json['IsActive'],
    );
  }
}