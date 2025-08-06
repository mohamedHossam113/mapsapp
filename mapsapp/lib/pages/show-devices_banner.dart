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
            builder: (context, state) {
              if (state is DeviceLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DeviceError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }

              if (state is DeviceLoaded) {
                final devices = state.devices;

                if (devices.isEmpty) {
                  return Center(
                    child: Text(
                      'No devices found.',
                      style:
                          TextStyle(color: theme.textTheme.bodyMedium?.color),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isMoving = device.speed > 0;

                    return Card(
                      color: theme.cardColor,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          isMoving ? Icons.directions_car : Icons.stop_circle,
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
                                  color: theme.textTheme.bodyMedium?.color),
                            ),
                            Text(
                              'State: ${device.status}',
                              style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
