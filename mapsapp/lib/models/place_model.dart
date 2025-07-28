import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final int id;
  final String name;
  final LatLng latLng;

  PlaceModel({
    required this.id,
    required this.name,
    required this.latLng,
  });
}

List<PlaceModel> places = [
  PlaceModel(
      id: 1,
      name: 'shooting club Dokki',
      latLng: const LatLng(30.045416502401693, 31.201888603981057)),
  PlaceModel(
      id: 2,
      name: 'Maadi grand city',
      latLng: const LatLng(29.98115178905258, 31.325736930068164)),
  PlaceModel(
      id: 3,
      name: 'Manaret AlFarouk',
      latLng: const LatLng(30.058010342281737, 31.41715530397161)),
  PlaceModel(
      id: 4,
      name: 'Dusit Thani LakeView',
      latLng: const LatLng(30.026194090898933, 31.45537783005691))
];
