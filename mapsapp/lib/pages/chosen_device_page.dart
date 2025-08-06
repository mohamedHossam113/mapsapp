// chosendevice_page.dart
import 'package:mapsapp/models/device_model.dart';
import 'package:flutter/material.dart';

class ChosenDevicePage extends StatelessWidget {
  final DeviceModel device;

  const ChosenDevicePage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMoving = device.status.toLowerCase() == 'moving';
    final textColor = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          device.name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: cardColor,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    Text(
                      isMoving ? 'Moving' : 'Stopped',
                      style: TextStyle(fontSize: 18, color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Speed: ${device.speed.toStringAsFixed(1)} km/h',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  'Latitude: ${device.latitude}',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  'Longitude: ${device.longitude}',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
