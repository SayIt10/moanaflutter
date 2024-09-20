class FotoAbsen {
  double latitude;
  double longitude;
  String fingerId;

  FotoAbsen({
    required this.latitude,
    required this.longitude,
    required this.fingerId,
  });

  factory FotoAbsen.fromJson(Map<String, dynamic> json) {
    return FotoAbsen(
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      fingerId: json['FingerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Latitude': latitude,
      'Longitude': longitude,
      'FingerId': fingerId,
    };
  }
}
