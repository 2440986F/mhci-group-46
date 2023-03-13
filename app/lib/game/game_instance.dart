import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/game/screens/map/map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

enum _GameStates { SELECT_DISTANCE, SELECT_DIFFICULTY, PLAYING, FOUND_OBJECT }

enum _GameDifficulties { EASY, MEDIUM, HARD }

class GameInstance extends StatefulWidget {
  _GameStates state = _GameStates.SELECT_DISTANCE;

  LatLng? targetPosition;

  Stream<Position> positionStream = Geolocator.getPositionStream(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.high));

  @override
  State<StatefulWidget> createState() {
    return GameState();
  }
}

class GameState extends State<GameInstance> {
  @override
  Widget build(BuildContext context) {
    switch (widget.state) {
      case _GameStates.SELECT_DISTANCE:
        return Center(
          child: FloatingActionButton(onPressed: () {
            _setTarget(5).then((value) => setState(() {
                  widget.state = _GameStates.PLAYING;
                  widget.targetPosition = value;
                }));
          }),
        );
      case _GameStates.SELECT_DIFFICULTY:
        break;
      case _GameStates.PLAYING:
        return MapHomeState(
          positionStream: widget.positionStream,
          targetPosition: widget.targetPosition!,
        );
      case _GameStates.FOUND_OBJECT:
        break;
    }
    return const Text("Not implemented");
  }
}

Future<LatLng> _setTarget(double range) async {
  Position userPosition = await Geolocator.getCurrentPosition();

  // About 111km in 1 degree of latitude/longitude.
  double maxOffset = range / 111;

  var r = Random();

  LatLng target = LatLng(
    userPosition.latitude + r.nextDouble() * 2 * maxOffset - maxOffset,
    userPosition.longitude + r.nextDouble() * 2 * maxOffset - maxOffset,
  );

  return target;
}
