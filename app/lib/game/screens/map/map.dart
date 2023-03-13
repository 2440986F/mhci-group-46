import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../game_instance.dart';

class MapHomeState extends StatelessWidget {
  final Stream<Position> positionStream;
  final LatLng targetPosition;

  late MapController mapController;

  MapHomeState(
      {super.key, required this.positionStream, required this.targetPosition}) {
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position>(
        stream: positionStream,
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center:
                      LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                  zoom: 18.0,
                  rotation: snapshot.data!.heading,
                ),
                nonRotatedChildren: [
                  AttributionWidget.defaultWidget(
                    source: 'OpenStreetMap contributors',
                    onSourceTapped: null,
                  ),
                ],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                            snapshot.data!.latitude, snapshot.data!.longitude),
                        builder: (ctx) => const Icon(Icons.my_location),
                      ),
                      Marker(
                        point: targetPosition,
                        builder: (ctx) => const Icon(Icons.location_on),
                      )
                    ],
                  )
                ],
              )
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[const Text("Error")];
          } else {
            children = <Widget>[const Text("Loading")];
          }
          return Scaffold(
              appBar: AppBar(title: const Text("Radsonar")),
              body: Center(
                child: Stack(
                  children: children,
                ),
              ));
        });
  }
}
