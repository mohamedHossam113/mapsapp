import 'package:google_maps_flutter/google_maps_flutter.dart';

extension MarkerExtensions on Marker {
  Marker copyWith({
    LatLng? positionParam,
    BitmapDescriptor? iconParam,
    InfoWindow? infoWindowParam,
  }) {
    return Marker(
      markerId: markerId,
      position: positionParam ?? position,
      icon: iconParam ?? icon,
      infoWindow: infoWindowParam ?? infoWindow,
      consumeTapEvents: consumeTapEvents,
      draggable: draggable,
      flat: flat,
      rotation: rotation,
      anchor: anchor,
      // infoWindowAnchor: infoWindowAnchor,
      alpha: alpha,
      visible: visible,
      zIndex: zIndex,
    );
  }
}// TODO Implement this library.