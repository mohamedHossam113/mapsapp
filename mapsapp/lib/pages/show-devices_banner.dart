import 'package:flutter/material.dart';
import 'package:mapsapp/services/device_service.dart';

void showDevicesPanel(BuildContext context) async {
  final devices = await DeviceService().fetchDevices(); // افترض إنك عملت دي

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
          return ListView.builder(
            controller: scrollController,
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final isMoving = device.speed > 0;

              return Card(
                color: Colors.black,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    isMoving ? Icons.directions_car : Icons.stop_circle,
                    color: isMoving ? Colors.green : Colors.red,
                  ),
                  title: Text(device.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Speed: ${device.speed} km/h'),
                      Text('State: ${isMoving ? "Moving" : "Stopped"}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
