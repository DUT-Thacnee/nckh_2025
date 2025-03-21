class LocationData {
  final String deviceId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;  // Thêm timestamp để theo dõi thời gian nhận dữ liệu

  LocationData({
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      deviceId: json['deviceId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 