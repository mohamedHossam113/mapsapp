import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapsapp/models/place_model.dart';

class CustomGooglemaps extends StatefulWidget {
  const CustomGooglemaps({super.key});

  @override
  State<CustomGooglemaps> createState() => _CustomGooglemapsState();
}

class _CustomGooglemapsState extends State<CustomGooglemaps> {
  late CameraPosition initialCameraPosition;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  @override
  void initState() {
    initPolygons();
    initMarkers();
    initialCameraPosition = const CameraPosition(
        zoom: 12, target: LatLng(30.04501634880077, 31.23425547067458));
    super.initState();
  }

  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GoogleMap(
        circles: circles,
        markers: markers,
        onMapCreated: (controller) {
          googleMapController = controller;
          initMapStyle();
        },
        // cameraTargetBounds: CameraTargetBounds(LatLngBounds(
        //     southwest: const LatLng(
        //       29.946207887913168,
        //       30.926159840187257,
        //     ),
        //     northeast: const LatLng(30.412754932817926, 32.3145570119751))),
        initialCameraPosition: initialCameraPosition,
      ),
      Positioned(
          bottom: 16,
          left: 55,
          right: 55,
          child: ElevatedButton(
            onPressed: () {
              googleMapController.animateCamera(CameraUpdate.newLatLng(
                  const LatLng(30.4513010859998, 31.181894238053275)));
            },
            child: const Text('Change Location'),
          ))
    ]);
  }

  void initMapStyle() async {
    var nightMapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_styles/aubergine_map_style.json');
    // ignore: deprecated_member_use
    googleMapController.setMapStyle(nightMapStyle);
  }

  void initMarkers() {
    var myMarkers = places
        .map(
          (placeModel) => Marker(
            infoWindow: InfoWindow(title: placeModel.name),
            position: placeModel.latLng,
            markerId: MarkerId(
              placeModel.id.toString(),
            ),
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
}

        // world view: 0 => 3
        // country view: 4 => 6
        // city view: 10 => 12
        // city view: 13 => 17