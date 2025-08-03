import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mapsapp/models/place_model.dart';
import 'package:mapsapp/services/location_service.dart';
import 'package:mapsapp/services/device_service.dart';
import 'package:mapsapp/models/device_model.dart';

class CustomGooglemaps extends StatefulWidget {
  const CustomGooglemaps({super.key});

  @override
  State<CustomGooglemaps> createState() => _CustomGooglemapsState();
}

class _CustomGooglemapsState extends State<CustomGooglemaps> {
  List<DeviceModel> allDevices = [];
  List<DeviceModel> filteredDevices = [];
  late CameraPosition initialCameraPosition;
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  late LocationService locationService;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final PanelController _panelController = PanelController();
  DeviceModel? selectedDevice;

  @override
  void initState() {
    super.initState();
    locationService = LocationService();
    initPolygons();
    initMarkers();
    initDeviceMarkers();
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

    fetchAndSetDevices();
  }

  void fetchAndSetDevices() async {
    final devices = await DeviceService().fetchDevices();
    setState(() {
      allDevices = devices;
      filteredDevices = devices;
    });
  }

  void filterDevices(String query) {
    final filtered = allDevices.where((device) {
      final name = device.name?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredDevices = filtered;
    });
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          markers: markers,
          onMapCreated: (controller) {
            googleMapController = controller;
            initMapStyle();
          },
          initialCameraPosition: initialCameraPosition,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedDevice!.name ?? 'Unnamed Device',
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
              Text(
                'Speed: ${selectedDevice!.speed} km/h',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'State: ${isMoving ? "Moving" : "Stopped"}',
                style: const TextStyle(color: Colors.white),
              ),
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
                fillColor: Colors.white,
                hintText: 'Search devices...',
                hintStyle: TextStyle(color: Colors.grey),
                iconColor: Colors.white,
                prefixIcon: Icon(Icons.search),
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
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                          title: Text(
                            device.name ?? 'Unnamed Device',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Speed: ${device.speed} km/h',
                                  style: const TextStyle(color: Colors.white)),
                              Text('State: ${isMoving ? "Moving" : "Stopped"}',
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

  void initMapStyle() async {
    var nightMapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_styles/aubergine_map_style.json');
    googleMapController?.setMapStyle(nightMapStyle);
  }

  void initMarkers() {
    var myMarkers = places
        .map(
          (placeModel) => Marker(
            infoWindow: InfoWindow(title: placeModel.name),
            position: placeModel.latLng,
            markerId: MarkerId(placeModel.id.toString()),
          ),
        )
        .toSet();

    markers.addAll(myMarkers);
  }

  void initPolygons() {
    Circle circle = Circle(
      strokeWidth: 3,
      center: const LatLng(30.057642791973688, 31.417043637443197),
      radius: 1000,
      fillColor: Colors.blue.withOpacity(.1),
      circleId: const CircleId('1'),
    );
    circles.add(circle);
  }

  void initDeviceMarkers() async {
    try {
      final deviceService = DeviceService();
      final devices = await deviceService.fetchDevices();

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
        markers.addAll(deviceMarkers);
      });
    } catch (e) {
      debugPrint('\u274c Failed to load devices: $e');
    }
  }
}











  // void updatedLocation() async {
  //   await locationService.checkAndRequestLocationService();
  //   var hasPermission =
  //       await locationService.checkAndRequestLocationPermission();
  //   if (hasPermission) {
  //     locationService.getRealTimeLocationData((locationData) {
  //       var cameraPostiton = CameraPosition(
  //           zoom: 12,
  //           target: LatLng(locationData.latitude!, locationData.longitude!));
  //       googleMapController
  //           ?.animateCamera(CameraUpdate.newCameraPosition(cameraPostiton));

  //       // var myLocationMarker = Marker(
  //       //     markerId: const MarkerId('my_location_marker'),
  //       //     position: LatLng(locationData.latitude!, locationData.longitude!));

  //       // markers.add(myLocationMarker);
  //       // setState(() {});
  //     });
  //   }
  // }


        // world view: 0 => 3
        // country view: 4 => 6
        // city view: 10 => 12
        // city view: 13 => 17