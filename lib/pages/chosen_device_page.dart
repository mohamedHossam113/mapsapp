// chosendevice_page.dart
import 'package:mapsapp/models/device_model.dart';
import 'package:mapsapp/cubits/device_cubit.dart';
import 'package:mapsapp/cubits/devices_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../generated/l10n.dart';

class ChosenDevicePage extends StatefulWidget {
  final DeviceModel device;

  const ChosenDevicePage({super.key, required this.device});

  @override
  State<ChosenDevicePage> createState() => _ChosenDevicePageState();
}

class _ChosenDevicePageState extends State<ChosenDevicePage> {
  late DeviceModel currentDevice;

  @override
  void initState() {
    super.initState();
    currentDevice = widget.device;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "",
          style: theme.textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DeviceCubit>().fetchDevices();
            },
          ),
        ],
      ),
      body: BlocListener<DeviceCubit, DeviceState>(
        // Listen for device updates
        listener: (context, state) {
          if (state is DeviceLoaded) {
            // Find the updated device
            final updatedDevice = state.devices.firstWhere(
              (d) => d.id == currentDevice.id,
              orElse: () => currentDevice,
            );

            if (updatedDevice != currentDevice) {
              setState(() {
                currentDevice = updatedDevice;
              });
            }
          }
        },
        child: BlocBuilder<DeviceCubit, DeviceState>(
          buildWhen: (previous, current) {
            // Only rebuild if our specific device has changed
            if (current is DeviceLoaded && previous is DeviceLoaded) {
              final oldDevice = previous.devices.firstWhere(
                (d) => d.id == currentDevice.id,
                orElse: () => currentDevice,
              );
              final newDevice = current.devices.firstWhere(
                (d) => d.id == currentDevice.id,
                orElse: () => currentDevice,
              );
              return oldDevice != newDevice;
            }
            return true;
          },
          builder: (context, state) {
            // Update currentDevice if state has changed
            if (state is DeviceLoaded) {
              final updatedDevice = state.devices.firstWhere(
                (d) => d.id == currentDevice.id,
                orElse: () => currentDevice,
              );
              currentDevice = updatedDevice;
            }

            final isMoving =
                currentDevice.status.toLowerCase() == S.of(context).moving;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: cardColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 30,
                                color: isMoving ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  currentDevice.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(S.of(context).speed,
                              '${currentDevice.speed} km/h', textColor),
                          const SizedBox(height: 10),
                          _buildInfoRow(S.of(context).state,
                              currentDevice.status, textColor),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                              S.of(context).latitude,
                              currentDevice.latitude.toStringAsFixed(6),
                              textColor),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                              S.of(context).longitude,
                              currentDevice.longitude.toStringAsFixed(6),
                              textColor),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                              S.of(context).last_updated,
                              _formatTime(currentDevice.lastUpdated),
                              textColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Add some action buttons if needed
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: textColor),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return S.of(context).just_now;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${S.of(context).m_ago}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
