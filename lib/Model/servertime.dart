class ServerTime {
  DateTime datetime;

  ServerTime({required this.datetime});

  factory ServerTime.fromJson(Map<String, dynamic> json) {
    return ServerTime(
      datetime: DateTime.parse(json['datetime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime.toIso8601String(),
    };
  }
}
