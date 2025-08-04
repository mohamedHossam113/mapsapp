import 'package:dio/dio.dart';
import 'package:mapsapp/management/token_manager.dart';
import '../models/device_model.dart';

class DeviceService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://10.0.2.2:8010/api/vehicle/all-devices';
  // final String _baseUrl = 'http://127.0.0.1:8010/api/vehicle/all-devices';

  Future<List<DeviceModel>> fetchDevices() async {
    try {
      final token = await TokenManager.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please login first.');
      }

      final response = await _dio.get(
        _baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final List<dynamic> vehicles = response.data['vehicles'];
      return vehicles.map((json) => DeviceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Dio error: ${e.response?.statusCode} | ${e.response?.data}');
      throw Exception('Failed to load devices: ${e.response?.data}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }
}
