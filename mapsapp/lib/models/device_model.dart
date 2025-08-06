import 'package:equatable/equatable.dart';

class DeviceModel extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String status;
  final int speed;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.speed,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coords'] ?? {};
    return DeviceModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      latitude: (coords['lat'] ?? 0).toDouble(),
      longitude: (coords['lng'] ?? 0).toDouble(),
      status: json['status'] ?? 'unknown',
      speed: json['speed'] ?? 0,
    );
  }

  DeviceModel copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? status,
    int? speed,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      speed: speed ?? this.speed,
    );
  }

  @override
  List<Object?> get props => [id, name, latitude, longitude, status, speed];
}
