import 'package:flutter/material.dart';
import 'package:mapsapp/widgets/custom_googlemaps.dart';

void main() {
  runApp(const TestGoogleMapsWithFlutter());
}

class TestGoogleMapsWithFlutter extends StatelessWidget {
  const TestGoogleMapsWithFlutter({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CustomGooglemaps(),
    );
  }
}
