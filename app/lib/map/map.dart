import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Map extends StatefulWidget {
  const Map({super.key, initalLocation});

  @override
  State<StatefulWidget> createState() {
    return _MapHomeState();
  }
}

class _MapHomeState extends State<Map> {
  late final MapController mapController;
  Future<Position> currentLocation =
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
        future: currentLocation,
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center:
                      LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                  zoom: 9.2,
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
