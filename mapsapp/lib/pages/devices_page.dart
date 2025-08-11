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
  bool _showDebugInfo = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DeviceCubit>();
    cubit.fetchDevices();
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
        actions: [
          // Debug toggle button
          IconButton(
            icon: Icon(
                _showDebugInfo ? Icons.bug_report : Icons.bug_report_outlined),
            onPressed: () {
              setState(() {
                _showDebugInfo = !_showDebugInfo;
              });
            },
          ),
          // Socket reconnect button
          IconButton(
            icon: const Icon(Icons.wifi_protected_setup),
            onPressed: () {
              context.read<DeviceCubit>().reconnectSocket();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reconnecting socket...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Debug info panel
          if (_showDebugInfo) _buildDebugPanel(),

          // Main content
          Expanded(
            child: BlocBuilder<DeviceCubit, DeviceState>(
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
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(color: colorScheme.error),
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
                          Icon(
                            Icons.devices,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
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

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<DeviceCubit>().fetchDevices();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: devices.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 4 / 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          final isMoving =
                              device.status.toLowerCase() == 'moving';
                          final timeSinceUpdate =
                              DateTime.now().difference(device.lastUpdated);
                          final isRecent = timeSinceUpdate.inMinutes < 5;

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
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.directions_car,
                                              color: isMoving
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                device.name,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
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
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: isRecent
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                        if (_showDebugInfo) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: ${device.id}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Colors.blue,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Live indicator
                                  if (isRecent)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Text(
                                              'LIVE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildDebugPanel() {
    final cubit = context.read<DeviceCubit>();

    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Information',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                cubit.isSocketConnected ? Icons.wifi : Icons.wifi_off,
                color: cubit.isSocketConnected ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Socket: ${cubit.isSocketConnected ? 'Connected' : 'Disconnected'}',
                style: TextStyle(
                  color: cubit.isSocketConnected ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  cubit.reconnectSocket();
                },
                child: const Text(
                  'Reconnect',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
          Text(
            'Last update: ${DateTime.now().toString().substring(11, 19)}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
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
