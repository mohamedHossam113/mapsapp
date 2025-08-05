import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/device_cubit.dart';
import 'package:mapsapp/cubits/devices_state.dart';

void showDevicesPanel(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: Colors.black,
    context: context,
    isScrollControlled: true,
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
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (state is DeviceLoaded) {
                final devices = state.devices;

                if (devices.isEmpty) {
                  return const Center(
                    child: Text(
                      'No devices found.',
                      style: TextStyle(color: Colors.white),
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
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          isMoving ? Icons.directions_car : Icons.stop_circle,
                          color: isMoving ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          device.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Speed: ${device.speed.toStringAsFixed(1)} km/h',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'State: ${device.status}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink(); // fallback
            },
          );
        },
      );
    },
  );
}
