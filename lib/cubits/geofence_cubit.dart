import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/services/geofence_service.dart';
import 'package:mapsapp/cubits/geofence_state.dart';
import 'package:mapsapp/management/token_manager.dart';

class GeofenceCubit extends Cubit<GeofenceState> {
  final GeofenceService _geofenceService;

  GeofenceCubit(this._geofenceService) : super(GeofenceInitial());

  Future<void> fetchGeofences() async {
    emit(GeofenceLoading());
    try {
      final token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        emit(GeofenceError('No token found. Please login first.'));
        return;
      }

      final geofences = await _geofenceService.fetchGeofences();
      emit(GeofenceLoaded(geofences));
    } catch (e) {
      emit(GeofenceError('Failed to load geofences: ${e.toString()}'));
    }
  }
}
