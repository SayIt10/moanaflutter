class FindClosestBranch {
  String cabangID;
  String namaCabang;
  double distance;
  String latitude;
  String longitude;

  FindClosestBranch({
    required this.cabangID,
    required this.namaCabang,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });

  factory FindClosestBranch.fromJson(Map<String, dynamic> json) {
    return FindClosestBranch(
      cabangID: json['CabangID'],
      namaCabang: json['NamaCabang'],
      distance: json['Distance'],
      latitude: json['Latitude'],
      longitude: json['Longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CabangID': cabangID,
      'NamaCabang': namaCabang,
      'Distance': distance,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }
}
