// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mapsapp/models/device_model.dart';
// import 'package:mapsapp/services/device_service.dart';
// import 'package:mapsapp/management/token_manager.dart';
// import 'package:mapsapp/cubits/devices_state.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class DeviceCubit extends Cubit<DeviceState> {
//   final DeviceService _deviceService;
//   IO.Socket? _socket;
//   bool _isSocketInitialized = false;

//   DeviceCubit(this._deviceService) : super(DeviceInitial());

//   void Function(String deviceId, Map<String, dynamic> deviceData)?
//       _onDeviceUpdate;

//   void setOnDeviceUpdate(
//     void Function(String deviceId, Map<String, dynamic> deviceData) callback,
//   ) {
//     _onDeviceUpdate = callback;
//   }

//   Future<void> fetchDevices() async {
//     if (isClosed) return;

//     emit(DeviceLoading());

//     try {
//       final token = await TokenManager.getToken();
//       if (token == null || token.isEmpty) {
//         if (!isClosed) emit(DeviceError('No token found. Please login first.'));
//         return;
//       }

//       final devices = await _deviceService.fetchDevices();
//       if (!isClosed) emit(DeviceLoaded(devices));

//       // Initialize socket if not already done
//       if (!_isSocketInitialized) {
//         initializeSocket();
//         _isSocketInitialized = true;
//       }
//     } catch (e) {
//       log('❌ Device fetch error: $e');
//       if (!isClosed) emit(DeviceError('Failed to load devices: $e'));
//     }
//   }

//   void initializeSocket() {
//     if (_socket?.connected == true || isClosed) return;

//     try {
//       log('🔌 Connecting to Socket.IO...');

//       _socket = IO.io(
//         'http://10.0.2.2:8089',
//         IO.OptionBuilder()
//             .setTransports(['websocket'])
//             .disableAutoConnect()
//             .build(),
//       );

//       _socket!.onConnect((_) {
//         log('✅ Connected to Socket.IO');
//         _socket!.emit('subscribe');
//       });

//       _socket!.on('device-location-update', (data) {
//         log('📡 Received device update: $data');

//         try {
//           dynamic parsed = data;
//           if (data is String) parsed = jsonDecode(data);

//           if (parsed['message'] != null) {
//             final messageStr = parsed['message'];
//             final messageJson = jsonDecode(messageStr);
//             final deviceData = messageJson['device'];
//             final deviceId = deviceData['deviceId'];

//             updateDevice(deviceId, deviceData);
//             _onDeviceUpdate?.call(deviceId, deviceData);
//           }
//         } catch (e) {
//           log('❌ Failed to parse message: $e');
//         }
//       });

//       _socket!.onConnectError((err) => log('❌ Connect error: $err'));
//       _socket!.onError((err) => log('❌ Socket.IO error: $err'));
//       _socket!.onDisconnect((_) => log('🔌 Disconnected from Socket.IO'));

//       _socket!.connect();
//     } catch (e) {
//       log('❌ Socket initialization error: $e');
//     }
//   }

//   void updateDevice(String deviceId, Map<String, dynamic> updateData) {
//     if (state is DeviceLoaded) {
//       final currentState = state as DeviceLoaded;
//       final devices = currentState.devices;

//       final index = devices.indexWhere((d) => d.id == deviceId);
//       if (index != -1) {
//         final device = devices[index];
//         final updatedDevice = device.copyWith(
//           latitude: (updateData['coords']['lat'] ?? device.latitude).toDouble(),
//           longitude:
//               (updateData['coords']['lng'] ?? device.longitude).toDouble(),
//           speed: (updateData['speed'] ?? device.speed).toInt(),
//           status: updateData['status'] ?? device.status,
//         );

//         final updatedDevices = List<DeviceModel>.from(devices);
//         updatedDevices[index] = updatedDevice;

//         emit(DeviceLoaded(updatedDevices)); // 🔥 emits new list
//         _onDeviceUpdate?.call(deviceId, updateData); // optional
//       }
//     }
//   }

//   // void updateDevice(String deviceId, Map<String, dynamic> updateData) {
//   //   if (state is! DeviceLoaded) return;

//   //   final currentState = state as DeviceLoaded;
//   //   final devices = currentState.devices;

//   //   final index = devices.indexWhere((d) => d.id == deviceId);
//   //   if (index == -1) return;

//   //   final device = devices[index];

//   //   final updatedDevice = device.copyWith(
//   //     latitude: (updateData['coords']['lat'] ?? device.latitude).toDouble(),
//   //     longitude: (updateData['coords']['lng'] ?? device.longitude).toDouble(),
//   //     speed: (updateData['speed'] ?? device.speed).toInt(),
//   //     status: updateData['status'] ?? device.status,
//   //   );

//   //   final updatedDevices = List<DeviceModel>.from(devices);
//   //   updatedDevices[index] = updatedDevice;

//   //   log('🟢 Updating device $deviceId: '
//   //       'lat=${updatedDevice.latitude}, '
//   //       'lng=${updatedDevice.longitude}, '
//   //       'speed=${updatedDevice.speed}, '
//   //       'status=${updatedDevice.status}');

//   //   emit(DeviceLoaded(updatedDevices));

//   //   _onDeviceUpdate?.call(deviceId, updateData);
//   // }

//   void disconnectSocket() {
//     _socket?.disconnect();
//     _socket?.dispose();
//     _socket = null;
//     log('🧹 Socket.IO cleaned up');
//   }

//   @override
//   Future<void> close() {
//     disconnectSocket();
//     return super.close();
//   }
// }

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/devices_state.dart';
import 'package:mapsapp/management/token_manager.dart';
import 'package:mapsapp/models/device_model.dart';
import 'package:mapsapp/services/device_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DeviceCubit extends Cubit<DeviceState> {
  final DeviceService _deviceService;
  IO.Socket? _socket;
  bool _isSocketInitialized = false;

  DeviceCubit(this._deviceService) : super(DeviceInitial()) {
    // ✅ Initialize socket once when cubit is created
    if (!_isSocketInitialized) {
      initializeSocket();
      _isSocketInitialized = true;
    }
  }

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
      if (!isClosed) emit(DeviceLoaded(devices));
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
          dynamic parsed = data;
          if (data is String) parsed = jsonDecode(data);

          if (parsed['message'] != null) {
            final messageStr = parsed['message'];
            final messageJson = jsonDecode(messageStr);
            final deviceData = messageJson['device'];
            final deviceId = deviceData['deviceId'];

            updateDevice(deviceId, deviceData);
            _onDeviceUpdate?.call(deviceId, deviceData);
          }
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

  void updateDevice(String deviceId, Map<String, dynamic> updateData) {
    if (state is DeviceLoaded) {
      final currentState = state as DeviceLoaded;
      final devices = currentState.devices;

      final index = devices.indexWhere((d) => d.id == deviceId);
      if (index != -1) {
        final device = devices[index];
        final updatedDevice = device.copyWith(
          latitude: (updateData['coords']['lat'] ?? device.latitude).toDouble(),
          longitude:
              (updateData['coords']['lng'] ?? device.longitude).toDouble(),
          speed: (updateData['speed'] ?? device.speed).toInt(),
          status: updateData['status'] ?? device.status,
        );

        final updatedDevices = List<DeviceModel>.from(devices);
        updatedDevices[index] = updatedDevice;

        emit(DeviceLoaded(updatedDevices));
        _onDeviceUpdate?.call(deviceId, updateData);
      }
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
