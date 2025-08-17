import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapsapp/cubits/devices_state.dart';
import 'package:mapsapp/generated/l10n.dart';
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
          S.of(context).devices,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).error_loading_devices,
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // context.read<DeviceCubit>().fetchDevices();
                    },
                    child: Text(S.of(context).retry),
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
                      S.of(context).no_devices_found,
                      style:
                          TextStyle(color: theme.textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // context.read<DeviceCubit>().fetchDevices();
                      },
                      child: Text(S.of(context).refresh),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                // context.read<DeviceCubit>().fetchDevices();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8.0),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final isMoving =
                      device.status.toLowerCase() == S.of(context).moving;

                  return GestureDetector(
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
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  color: isMoving ? Colors.red : Colors.green,
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
                              '${S.of(context).state}: ${device.status}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${S.of(context).speed}: ${device.speed} km/h',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${S.of(context).updated}: ${_formatTime(device.lastUpdated)}',
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
      return S.of(context).just_now;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${S.of(context).m_ago}';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
