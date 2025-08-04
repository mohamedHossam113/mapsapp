import 'package:google_maps_flutter/google_maps_flutter.dart';

class Geofence {
  final String id;
  final String name;
  final String shape;
  final List<LatLng> coords;
  final double? radius; // nullable for polygons

  Geofence({
    required this.id,
    required this.name,
    required this.shape,
    required this.coords,
    this.radius,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    final coordsList = json['coords'] as List;

    return Geofence(
      id: json['_id'],
      name: json['name'],
      shape: json['shape'],
      coords: coordsList.map<LatLng>((c) {
        return LatLng(c['lat'], c['lng']);
      }).toList(),
      radius: json['shape'] == 'circle'
          ? (json['radius'] ?? 1000).toDouble()
          : null,
    );
  }
}
