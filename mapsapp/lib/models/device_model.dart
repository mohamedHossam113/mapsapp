class DeviceModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String status;
  final int speed;

  DeviceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.speed,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['_id'],
      name: json['name'],
      latitude: json['coords']['lat'],
      longitude: json['coords']['lng'],
      status: json['status'],
      speed: json['speed'],
    );
  }
}
