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
    context.read<DeviceCubit>().fetchDevices();
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
              MaterialPageRoute(builder: (_) => const MainPage()),
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
        builder: (context, state) {
          if (state is DeviceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DeviceError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          if (state is DeviceLoaded) {
            final devices = state.devices;

            if (devices.isEmpty) {
              return Center(
                child: Text(
                  'No devices found.',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChosenDevicePage(device: device),
                        ),
                      );
                    },
                    child: Card(
                      color: theme.cardColor,
                      clipBehavior: Clip.none,
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
                              'Speed: ${device.speed.toStringAsFixed(1)} km/h',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
