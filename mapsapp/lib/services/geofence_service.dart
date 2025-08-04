import 'package:dio/dio.dart';
import 'package:mapsapp/management/token_manager.dart';
import 'package:mapsapp/models/geofence_model.dart';

class GeofenceService {
  final Dio dio = Dio();
  final String baseUrl = 'http://10.0.2.2:8010/api/geofence/get-all';
  // final String webbaseUrl = 'http://127.0.0.1:8010/api/geofence/get-all';

  Future<List<Geofence>> fetchGeofences() async {
    try {
      final token = await TokenManager.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please login first.');
      }

      final response = await dio.get(
        baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        ),
      );

      final List<dynamic> geofences = response.data['geofences'];
      print(response);
      return geofences.map((json) => Geofence.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Dio error: ${e.response?.statusCode} | ${e.response?.data}');
      print(e);
      throw Exception('Failed to load geofence: ${e.response?.data}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }
}
