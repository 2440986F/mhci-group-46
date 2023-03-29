import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../game_instance.dart';

class MapHomeState extends StatelessWidget {
  final Position userPosition;
  final LatLng targetPosition;
  final GameDifficulties difficulty;
  int sonarRadius = 25;

  late MapController mapController;

  MapHomeState(
      {super.key,
      required this.userPosition,
      required this.targetPosition,
      required this.difficulty}) {
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: LatLng(userPosition.latitude, userPosition.longitude),
        zoom: 18.0,
        rotation: userPosition.heading,
      ),
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap contributors',
          onSourceTapped: null,
        ),
        if (difficulty == GameDifficulties.EASY)
          Align(
              alignment: Alignment.topCenter,
              child: Transform.rotate(
                angle: Geolocator.bearingBetween(
                        userPosition.latitude,
                        userPosition.longitude,
                        targetPosition.latitude,
                        targetPosition.longitude) *
                    pi /
                    180,
                child: const Icon(
                  Icons.arrow_upward_outlined,
                  color: Colors.black,
                  size: 100,
                ),
              )),
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(userPosition.latitude, userPosition.longitude),
              builder: (ctx) => const Icon(Icons.my_location),
            ),
            Marker(
              point: targetPosition,
              builder: (ctx) => const Icon(Icons.location_on),
            )
          ],
        ),
        if (difficulty != GameDifficulties.HARD)
          CircleLayer(circles: [
            CircleMarker(
              point: targetPosition,
              useRadiusInMeter: true,
              radius: (DateTime.now().millisecondsSinceEpoch % 5000) + 25,
              borderColor: const Color.fromARGB(255, 255, 0, 0),
              borderStrokeWidth: 2,
              color: const Color.fromARGB(0, 255, 255, 255),
            ),
          ])
      ],
    );
  }
}
