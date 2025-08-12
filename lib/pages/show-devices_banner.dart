import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/device_cubit.dart';
import 'package:mapsapp/cubits/devices_state.dart';

void showDevicesPanel(BuildContext context) {
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.5,
        builder: (context, scrollController) {
          return BlocBuilder<DeviceCubit, DeviceState>(
            // Force rebuild on every state change
            buildWhen: (previous, current) => true,
            builder: (context, state) {
              if (state is DeviceLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DeviceError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<DeviceCubit>().fetchDevices();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is DeviceLoaded) {
                final devices = state.devices;

                if (devices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No devices found.',
                          style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DeviceCubit>().fetchDevices();
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Panel handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Devices (${devices.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              context.read<DeviceCubit>().fetchDevices();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Device list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          final isMoving = device.speed > 0;

                          return Card(
                            // Use unique key with timestamp for proper rebuilding
                            key: ValueKey(
                                '${device.id}_${device.lastUpdated.millisecondsSinceEpoch}'),
                            color: theme.cardColor,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                isMoving
                                    ? Icons.directions_car
                                    : Icons.stop_circle,
                                color: isMoving ? Colors.green : Colors.red,
                              ),
                              title: Text(
                                device.name,
                                style: TextStyle(
                                    color: theme.textTheme.titleLarge?.color),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Speed: ${device.speed.toStringAsFixed(1)} km/h',
                                    style: TextStyle(
                                        color:
                                            theme.textTheme.bodyMedium?.color),
                                  ),
                                  Text(
                                    'State: ${device.status}',
                                    style: TextStyle(
                                        color:
                                            theme.textTheme.bodyMedium?.color),
                                  ),
                                  Text(
                                    'Updated: ${_formatTime(device.lastUpdated)}',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.location_on,
                                color: theme.colorScheme.primary,
                              ),
                              onTap: () {
                                Navigator.pop(context); // Close the panel first
                                // You can add navigation to device details here if needed
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      );
    },
  );
}

String _formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
