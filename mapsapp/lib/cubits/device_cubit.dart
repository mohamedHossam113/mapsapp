import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mapsapp/cubits/devices_state.dart';
import 'package:mapsapp/services/device_service.dart';
import 'package:mapsapp/management/token_manager.dart';

class DeviceCubit extends Cubit<DeviceState> {
  final DeviceService _deviceService;
  IO.Socket? _socket;

  DeviceCubit(this._deviceService) : super(DeviceInitial());

  void Function(String deviceId, Map<String, dynamic> deviceData)?
      _onDeviceUpdate;

  void setOnDeviceUpdate(
      void Function(String deviceId, Map<String, dynamic> deviceData)
          callback) {
    _onDeviceUpdate = callback;
  }

  Future<void> fetchDevices() async {
    if (isClosed) return;

    emit(DeviceLoading());

    try {
      final token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        if (!isClosed) emit(DeviceError('No token found. Please login first.'));
        return;
      }

      final devices = await _deviceService.fetchDevices();
      if (!isClosed) emit(DeviceLoaded(devices));

      initializeSocket();
    } catch (e) {
      log('❌ Device fetch error: $e');
      if (!isClosed) emit(DeviceError('Failed to load devices: $e'));
    }
  }

  void initializeSocket() {
    if (_socket?.connected == true || isClosed) return;

    try {
      log('🔌 Connecting to Socket.IO...');

      _socket = IO.io(
        'http://10.0.2.2:8089',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        log('✅ Connected to Socket.IO');
        _socket!.emit('subscribe');
      });

      _socket!.on('device-location-update', (data) {
        log('📡 Received device update: $data');

        try {
          final parsed = data is String ? jsonDecode(data) : data;
          final messageStr = parsed['message'];
          final messageJson = jsonDecode(messageStr);
          final device = messageJson['device'];
          final deviceId = device['deviceId'];

          _onDeviceUpdate?.call(deviceId, device);
        } catch (e) {
          log('❌ Failed to parse message: $e');
        }
      });

      _socket!.onConnectError((err) => log('❌ Connect error: $err'));
      _socket!.onError((err) => log('❌ Socket.IO error: $err'));
      _socket!.onDisconnect((_) => log('🔌 Disconnected from Socket.IO'));

      _socket!.connect();
    } catch (e) {
      log('❌ Socket initialization error: $e');
    }
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    log('🧹 Socket.IO cleaned up');
  }

  @override
  Future<void> close() {
    disconnectSocket();
    return super.close();
  }
}
