import '../models/geofence_model.dart';

abstract class GeofenceState {}

class GeofenceInitial extends GeofenceState {}

class GeofenceLoading extends GeofenceState {}

class GeofenceLoaded extends GeofenceState {
  final List<Geofence> geofences;

  GeofenceLoaded(this.geofences);
}

class GeofenceError extends GeofenceState {
  final String message;

  GeofenceError(this.message);
}
