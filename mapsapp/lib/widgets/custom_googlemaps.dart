import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapsapp/widgets/device_list.dart';
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

    final cubit = context.read<DeviceCubit>();
    cubit.setOnDeviceUpdate((deviceId, data) {
      if (!_isMounted || !mounted) return;

      final coords = data['coords'];
      final lat = coords['lat'];
      final lng = coords['lng'];
      final speed = (data['speed'] ?? 0).toDouble();
      final status = data['status'] ?? 'unknown';
      final newPos = LatLng(lat, lng);

      setState(() {
        // Update marker
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
          ),
        };
      });
    });

    cubit.fetchDevices();
    context.read<GeofenceCubit>().fetchGeofences();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = colorScheme.onSurface;
    final cardColor = theme.cardColor;

    return MultiBlocListener(
      listeners: [
        BlocListener<DeviceCubit, DeviceState>(
          listener: (context, state) {
            if (!_isMounted || !mounted) return;

            if (state is DeviceLoaded) {
              initDeviceMarkers(state.devices);

              // Update selected device if still showing
              if (selectedDevice != null) {
                final updated = state.devices.firstWhere(
                  (d) => d.id == selectedDevice!.id,
                  orElse: () => selectedDevice!,
                );
                setState(() {
                  selectedDevice = updated;
                });
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
        backgroundColor: theme.colorScheme.surface,
        body: SlidingUpPanel(
          backdropColor: theme.colorScheme.surface,
          controller: _panelController,
          minHeight: 80,
          maxHeight: selectedDevice != null
              ? 250
              : MediaQuery.of(context).size.height * 0.5,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: theme.bottomSheetTheme.backgroundColor ??
              theme.colorScheme.surface,
          panelBuilder: (ScrollController sc) => selectedDevice != null
              ? _buildSelectedDeviceCard(theme, textColor, cardColor)
              : DeviceListWidget(
                  scrollController: sc,
                  searchController: _searchController,
                  searchFocusNode: _searchFocusNode,
                  onDeviceTap: (device) async {
                    await googleMapController?.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(device.latitude, device.longitude),
                      ),
                    );
                    setState(() {
                      selectedDevice = device;
                    });
                  },
                ),
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

  Widget _buildSelectedDeviceCard(
      ThemeData theme, Color textColor, Color cardColor) {
    final isMoving = selectedDevice!.speed > 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: cardColor,
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
                  icon: Icon(Icons.close, color: textColor),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Speed: ${selectedDevice!.speed} km/h',
                  style: TextStyle(color: textColor)),
              Text('State: ${isMoving ? "Moving" : "Stopped"}',
                  style: TextStyle(color: textColor)),
              Text(
                  'lat and lng: ${selectedDevice!.latitude}, ${selectedDevice!.longitude}',
                  style: TextStyle(color: textColor)),
            ],
          ),
        ),
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

  void initDeviceMarkers(List<DeviceModel> devices) {
    final deviceMarkers = devices.map((device) {
      return Marker(
        markerId: MarkerId(device.name),
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
      markers.removeWhere((m) => m.markerId.value.startsWith('device-'));
      markers.addAll(deviceMarkers);
    });
  }
}
