import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mapsapp/models/place_model.dart';
import 'package:mapsapp/services/location_service.dart';
import 'package:mapsapp/models/device_model.dart';
import 'package:mapsapp/cubits/device_cubit.dart';
import 'package:mapsapp/cubits/geofence_cubit.dart';
import 'package:mapsapp/models/geofence_model.dart';
import '../cubits/devices_state.dart';
import '../cubits/geofence_state.dart';

class CustomGooglemaps extends StatefulWidget {
  const CustomGooglemaps({super.key});

  @override
  State<CustomGooglemaps> createState() => _CustomGooglemapsState();
}

class _CustomGooglemapsState extends State<CustomGooglemaps>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<DeviceModel> allDevices = [];
  List<DeviceModel> filteredDevices = [];
  late CameraPosition initialCameraPosition;
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Set<Polygon> polygons = {};

  late LocationService locationService;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final PanelController _panelController = PanelController();
  DeviceModel? selectedDevice;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    locationService = LocationService();
    initPolygons();
    initMarkers();

    initialCameraPosition = const CameraPosition(
      zoom: 12,
      target: LatLng(30.0444, 31.2357),
    );

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _panelController.open();
      }
    });

    _searchController.addListener(() {
      filterDevices(_searchController.text);
    });

    final cubit = context.read<DeviceCubit>();
    cubit.setOnDeviceUpdate((deviceId, data) {
      if (!_isMounted || !mounted) return;

      final coords = data['coords'];
      final lat = coords['lat'];
      final lng = coords['lng'];
      final speed = (data['speed'] ?? 0).toDouble();
      final status = data['status'] ?? 'unknown';
      final newPos = LatLng(lat, lng);

      // <--- REPLACE THIS setState BLOCK WITH THE ONE I PROVIDED
      setState(() {
        markers = {
          for (final marker in markers)
            if (marker.markerId.value != deviceId) marker,
          Marker(
            markerId: MarkerId(deviceId),
            position: newPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              status.toLowerCase() == 'moving'
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: deviceId,
              snippet: 'Speed: $speed km/h\nStatus: $status',
            ),
          )
        };

        final index = allDevices.indexWhere((d) => d.id == deviceId);
        if (index != -1) {
          final updated = allDevices[index].copyWith(
            latitude: lat,
            longitude: lng,
            speed: speed.toInt(),
            status: status,
          );
          allDevices = [
            for (int i = 0; i < allDevices.length; i++)
              if (i == index) updated else allDevices[i]
          ];
          filteredDevices = [
            for (final d in filteredDevices) d.id == deviceId ? updated : d
          ];
        }

        if (selectedDevice?.id == deviceId) {
          selectedDevice = selectedDevice!.copyWith(
            latitude: lat,
            longitude: lng,
            speed: speed.toInt(),
            status: status,
          );
        }
      });
    });

    cubit.fetchDevices();
    context.read<GeofenceCubit>().fetchGeofences();
  }

  void filterDevices(String query) {
    final filtered = allDevices.where((device) {
      final name = device.name.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    if (!_isMounted || !mounted) return;
    setState(() {
      filteredDevices = filtered;
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    googleMapController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocListener(
      listeners: [
        // In CustomGooglemaps build method, update the BlocListener
        BlocListener<DeviceCubit, DeviceState>(
          listener: (context, state) {
            if (!_isMounted || !mounted) return;

            if (state is DeviceLoaded) {
              setState(() {
                allDevices = state.devices;
                filteredDevices = state.devices;
              });
              initDeviceMarkers(state.devices);

              // Keep selected device in sync
              if (selectedDevice != null) {
                final updatedDevice = state.devices.firstWhere(
                  (d) => d.id == selectedDevice!.id,
                  orElse: () => selectedDevice!,
                );
                selectedDevice = updatedDevice;
              }
            }
          },
        ),
        BlocListener<GeofenceCubit, GeofenceState>(
          listener: (context, state) {
            if (!_isMounted || !mounted) return;

            if (state is GeofenceLoaded) {
              loadGeofences(state.geofences);
            }
          },
        ),
      ],
      child: Scaffold(
        body: SlidingUpPanel(
          backdropColor: Colors.black,
          controller: _panelController,
          minHeight: 80,
          maxHeight: selectedDevice != null
              ? 250
              : MediaQuery.of(context).size.height * 0.5,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: Colors.black,
          panelBuilder: (ScrollController sc) => selectedDevice != null
              ? _buildSelectedDeviceCard()
              : _buildDeviceList(sc),
          body: GoogleMap(
            zoomControlsEnabled: false,
            circles: circles,
            polygons: polygons,
            markers: markers,
            onMapCreated: (controller) {
              googleMapController = controller;
            },
            initialCameraPosition: initialCameraPosition,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDeviceCard() {
    final isMoving = selectedDevice!.speed > 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      selectedDevice = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isMoving ? Icons.directions_car : Icons.stop_circle,
                    color: isMoving ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedDevice!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Speed: ${selectedDevice!.speed} km/h',
                  style: const TextStyle(color: Colors.white)),
              Text('State: ${isMoving ? "Moving" : "Stopped"}',
                  style: const TextStyle(color: Colors.white)),
              Text(
                  'lat and lng: ${selectedDevice!.latitude}, ${selectedDevice!.longitude}',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList(ScrollController sc) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                hintText: 'Search devices...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: filteredDevices.isEmpty
                ? const Center(
                    child: Text('No devices found.',
                        style: TextStyle(color: Colors.white)),
                  )
                : ListView.builder(
                    controller: sc,
                    itemCount: filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = filteredDevices[index];
                      final isMoving = device.speed > 0;

                      return Card(
                        color: Colors.grey.shade900,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          onTap: () async {
                            await googleMapController?.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(device.latitude, device.longitude),
                              ),
                            );
                            setState(() {
                              selectedDevice = device;
                            });
                          },
                          leading: Icon(
                            isMoving ? Icons.directions_car : Icons.stop_circle,
                            color: isMoving ? Colors.green : Colors.red,
                          ),
                          title: Text(device.name,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Speed: ${device.speed} km/h',
                                  style: const TextStyle(color: Colors.white)),
                              Text('State: ${isMoving ? "Moving" : "Stopped"}',
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  'lat and lng: ${device.latitude}, ${device.longitude}',
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void initMarkers() {
    var myMarkers = places
        .map((placeModel) => Marker(
              infoWindow: InfoWindow(title: placeModel.name),
              position: placeModel.latLng,
              markerId: MarkerId(placeModel.id.toString()),
            ))
        .toSet();

    markers.addAll(myMarkers);
  }

  void initPolygons() {}

  void loadGeofences(List<Geofence> geofences) {
    final circleGeofences = <Circle>{};
    final polygonGeofences = <Polygon>{};

    for (final g in geofences) {
      if (g.shape == 'circle' && g.coords.isNotEmpty && g.radius != null) {
        circleGeofences.add(
          Circle(
            circleId: CircleId(g.id),
            center: g.coords.first,
            radius: g.radius!,
            strokeColor: Colors.red,
            fillColor: Colors.red.withOpacity(0.2),
            strokeWidth: 5,
          ),
        );
      } else if (g.shape == 'polygon' && g.coords.length >= 3) {
        polygonGeofences.add(
          Polygon(
            polygonId: PolygonId(g.id),
            points: g.coords,
            strokeColor: Colors.orange,
            fillColor: Colors.orange.withOpacity(0.2),
            strokeWidth: 5,
          ),
        );
      }
    }

    setState(() {
      circles = circleGeofences;
      polygons = polygonGeofences;
    });
  }

// Update initDeviceMarkers in custom_googlemaps.dart
  void initDeviceMarkers(List<DeviceModel> devices) {
    final deviceMarkers = devices.map((device) {
      return Marker(
        markerId: MarkerId(device.id),
        position: LatLng(device.latitude, device.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          device.status.toLowerCase() == 'moving'
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: device.name,
          snippet: 'Speed: ${device.speed} km/h\nStatus: ${device.status}',
        ),
      );
    }).toSet();

    setState(() {
      // Clear only device markers (keep places markers)
      markers.removeWhere((m) => m.markerId.value.startsWith('device-'));
      markers.addAll(deviceMarkers);
    });
  }
}
