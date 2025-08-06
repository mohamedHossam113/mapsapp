import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/device_cubit.dart';
import 'package:mapsapp/cubits/devices_state.dart';
import 'package:mapsapp/models/device_model.dart';

class DeviceListWidget extends StatelessWidget {
  final ScrollController scrollController;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(DeviceModel) onDeviceTap;

  const DeviceListWidget({
    super.key,
    required this.scrollController,
    required this.searchController,
    required this.searchFocusNode,
    required this.onDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = colorScheme.onSurface;
    final cardColor = theme.cardColor;

    return BlocBuilder<DeviceCubit, DeviceState>(
      builder: (context, state) {
        log('🟢 DeviceListWidget rebuilding with state: $state');

        if (state is DeviceLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DeviceLoaded) {
          final devices = state.devices;
          final query = searchController.text.toLowerCase();
          final filteredDevices = devices.where((d) {
            return d.name.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorScheme.surface,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    hintText: 'Search devices...',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search, color: textColor),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),
              ),
              Expanded(
                child: filteredDevices.isEmpty
                    ? Center(
                        child: Text(
                          'No devices found.',
                          style: TextStyle(color: textColor),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: filteredDevices.length,
                        itemBuilder: (context, index) {
                          final device = filteredDevices[index];
                          final isMoving = device.speed > 0;

                          return Card(
                            key: ValueKey(device.id), // 🟢 ADD THIS LINE

                            color: cardColor,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () => onDeviceTap(device),
                              leading: Icon(
                                isMoving
                                    ? Icons.directions_car
                                    : Icons.stop_circle,
                                color: isMoving ? Colors.green : Colors.red,
                              ),
                              title: Text(
                                device.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Speed: ${device.speed} km/h',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: textColor),
                                  ),
                                  Text(
                                    'State: ${isMoving ? "Moving" : "Stopped"}',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: textColor),
                                  ),
                                  Text(
                                    'lat and lng: ${device.latitude}, ${device.longitude}',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: textColor),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }

        return const SizedBox.shrink(); // default fallback
      },
    );
  }
}
