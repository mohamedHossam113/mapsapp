import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/devices_state.dart';
import 'package:mapsapp/pages/chosen_device_page.dart';
import 'package:mapsapp/widgets/main_page.dart';
import '../cubits/device_cubit.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  void initState() {
    super.initState();
    // Fetch devices and initialize socket
    // final cubit = context.read<DeviceCubit>();
    // cubit.fetchDevices();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ??
            IconThemeData(color: colorScheme.onSurface),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<DeviceCubit>(),
                  child: const MainPage(),
                ),
              ),
              (route) => false,
            );
          },
        ),
        title: Text(
          'Devices',
          style: theme.appBarTheme.titleTextStyle ??
              TextStyle(color: colorScheme.onSurface),
        ),
      ),
      body: BlocBuilder<DeviceCubit, DeviceState>(
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
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // context.read<DeviceCubit>().fetchDevices();
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
                      style:
                          TextStyle(color: theme.textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // context.read<DeviceCubit>().fetchDevices();
                      },
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                // context.read<DeviceCubit>().fetchDevices();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: devices.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4 / 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isMoving = device.status.toLowerCase() == 'moving';

                    return GestureDetector(
                      // Use unique key with timestamp for proper rebuilding
                      key: ValueKey(
                          '${device.id}_${device.lastUpdated.millisecondsSinceEpoch}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<DeviceCubit>(),
                              child: ChosenDevicePage(device: device),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    color: isMoving ? Colors.green : Colors.red,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      device.name,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'State: ${device.status}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Speed: ${device.speed} km/h',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Updated: ${_formatTime(device.lastUpdated)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
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
}
