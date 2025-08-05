// chosendevice_page.dart
import 'package:mapsapp/models/device_model.dart';
import 'package:flutter/material.dart';

class ChosenDevicePage extends StatelessWidget {
  final DeviceModel device;

  const ChosenDevicePage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final isMoving = device.status.toLowerCase() == 'moving';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          device.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.grey.shade900,
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
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Speed: ${device.speed.toStringAsFixed(1)} km/h',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Latitude: ${device.latitude}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Longitude: ${device.longitude}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
