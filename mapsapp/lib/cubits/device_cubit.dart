import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/models/device_model.dart';
import 'package:mapsapp/services/device_service.dart';
import 'package:mapsapp/management/token_manager.dart';
import 'package:mapsapp/cubits/devices_state.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DeviceCubit extends Cubit<DeviceState> {
  final DeviceService _deviceService;
  IO.Socket? _socket;

  DeviceCubit(this._deviceService) : super(DeviceInitial());

  void Function(String deviceId, Map<String, dynamic> deviceData)?
      _onDeviceUpdate;

  void setOnDeviceUpdate(
    void Function(String deviceId, Map<String, dynamic> deviceData) callback,
  ) {
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
      log('📱 Fetched ${devices.length} devices: ${devices.map((d) => '${d.name}(${d.id})').join(', ')}');

      if (!isClosed) emit(DeviceLoaded(devices));

      // Always try to initialize socket after fetching devices
      initializeSocket();
    } catch (e) {
      log('❌ Device fetch error: $e');
      if (!isClosed) emit(DeviceError('Failed to load devices: $e'));
    }
  }

  void initializeSocket() {
    // Disconnect existing socket first
    if (_socket?.connected == true) {
      log('🔌 Disconnecting existing socket...');
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    }

    if (isClosed) return;

    try {
      log('🔌 Initializing Socket.IO connection...');

      _socket = IO.io(
        'http://10.0.2.2:8089',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setExtraHeaders({'Connection': 'upgrade'})
            .build(),
      );

      _socket!.onConnect((_) {
        log('✅ Connected to Socket.IO successfully');
        _socket!.emit('subscribe');
        log('📡 Sent subscribe message');
      });

      _socket!.on('device-location-update', (data) {
        log('📡 Received device-location-update: $data');
        try {
          final Map<String, dynamic> parsed;

          if (data is String) {
            parsed = jsonDecode(data);
          } else if (data is Map<String, dynamic>) {
            parsed = data;
          } else {
            log('❌ Invalid data format: ${data.runtimeType}');
            return;
          }

          log('📍 Parsed update data: $parsed');

          final deviceId = parsed['deviceId'] ?? parsed['_id'] ?? parsed['id'];
          if (deviceId != null) {
            log('🎯 Updating device: $deviceId');
            updateDevice(deviceId.toString(), parsed);
          } else {
            log('❌ No deviceId found in update data. Keys: ${parsed.keys}');
          }
        } catch (e) {
          log('❌ Failed to parse socket update: $e');
          log('❌ Raw data was: $data');
        }
      });

      _socket!.on('connect', (_) {
        log('✅ Socket connected event fired');
      });

      _socket!.onConnectError((err) {
        log('❌ Socket connect error: $err');
      });

      _socket!.onError((err) {
        log('❌ Socket.IO error: $err');
      });

      _socket!.onDisconnect((reason) {
        log('🔌 Disconnected from Socket.IO. Reason: $reason');
      });

      _socket!.on('disconnect', (reason) {
        log('🔌 Socket disconnect event: $reason');
      });

      // Add more debugging events
      _socket!.on('connect_timeout', (_) {
        log('⏰ Socket connection timeout');
      });

      _socket!.on('reconnect', (_) {
        log('🔄 Socket reconnected');
      });

      _socket!.on('reconnecting', (_) {
        log('🔄 Socket reconnecting...');
      });

      _socket!.on('reconnect_error', (err) {
        log('❌ Socket reconnect error: $err');
      });

      // Listen to all events for debugging
      _socket!.onAny((event, data) {
        log('🎧 Socket event: $event, data: $data');
      });

      log('🔌 Starting socket connection...');
      _socket!.connect();
    } catch (e) {
      log('❌ Socket initialization error: $e');
    }
  }

  void updateDevice(String deviceId, Map<String, dynamic> updateData) {
    if (isClosed) return;

    log('🔄 Attempting to update device: $deviceId');
    log('🔄 Update data: $updateData');

    try {
      if (state is DeviceLoaded) {
        final currentState = state as DeviceLoaded;
        final devices = currentState.devices;

        log('📱 Current devices: ${devices.map((d) => '${d.name}(${d.id})').join(', ')}');
        log('🎯 Looking for device with ID: $deviceId');

        // Try multiple ways to find the device
        int index = -1;

        // Try exact ID match first
        index = devices.indexWhere((d) => d.id == deviceId);
        log('🔍 Exact ID match index: $index');

        // Try name match if ID doesn't work
        if (index == -1) {
          index = devices.indexWhere((d) => d.name == deviceId);
          log('🔍 Name match index: $index');
        }

        // Try partial match
        if (index == -1) {
          index = devices.indexWhere(
              (d) => d.id.contains(deviceId) || deviceId.contains(d.id));
          log('🔍 Partial match index: $index');
        }

        if (index != -1) {
          final device = devices[index];
          log('✅ Found device to update: ${device.name} (${device.id})');

          // Extract coordinates
          Map<String, dynamic>? coords;
          if (updateData['coords'] is Map) {
            coords = updateData['coords'] as Map<String, dynamic>;
          } else if (updateData.containsKey('lat') &&
              updateData.containsKey('lng')) {
            coords = {'lat': updateData['lat'], 'lng': updateData['lng']};
          } else if (updateData.containsKey('latitude') &&
              updateData.containsKey('longitude')) {
            coords = {
              'lat': updateData['latitude'],
              'lng': updateData['longitude']
            };
          }

          final updatedDevice = device.copyWith(
            latitude: coords != null
                ? (coords['lat'] ?? device.latitude).toDouble()
                : device.latitude,
            longitude: coords != null
                ? (coords['lng'] ?? device.longitude).toDouble()
                : device.longitude,
            speed: (updateData['speed'] ?? device.speed).toInt(),
            status: updateData['status'] ?? device.status,
            lastUpdated: DateTime.now(),
          );

          log('🆕 Updated device: ${updatedDevice.name} - Status: ${updatedDevice.status}, Speed: ${updatedDevice.speed}, Lat: ${updatedDevice.latitude}, Lng: ${updatedDevice.longitude}');

          final updatedDevices = List<DeviceModel>.from(devices);
          updatedDevices[index] = updatedDevice;

          // Force state update
          emit(DeviceLoaded(List.from(updatedDevices)));

          _onDeviceUpdate?.call(deviceId, updateData);

          log('✅ Device updated successfully and state emitted');
        } else {
          log('❌ Device not found in list for ID: $deviceId');
          log('Available devices: ${devices.map((d) => 'ID: ${d.id}, Name: ${d.name}').join('\n')}');
        }
      } else {
        log('⚠️ State is not DeviceLoaded (${state.runtimeType}), fetching devices...');
        fetchDevices();
      }
    } catch (e) {
      log('❌ Device update error: $e');
      log('❌ Stack trace: ${StackTrace.current}');
    }
  }

  // Add method to check socket status
  bool get isSocketConnected => _socket?.connected ?? false;

  void reconnectSocket() {
    log('🔄 Manually reconnecting socket...');
    disconnectSocket();
    initializeSocket();
  }

  void disconnectSocket() {
    if (_socket != null) {
      log('🧹 Disconnecting and disposing socket...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  @override
  Future<void> close() {
    log('🧹 Closing DeviceCubit...');
    disconnectSocket();
    return super.close();
  }
}
