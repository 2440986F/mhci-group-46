import 'dart:ffi';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class GameController {
  bool targetExists = false;
  LatLng? target;
  int gameTime = 0;

  Future<bool> setTarget(double range) async {
    Position userPosition = await Geolocator.getCurrentPosition();

    // About 111km in 1 degree of latitude/longitude.
    double maxOffset = range / 111;

    var r = Random();

    target = LatLng(
      userPosition.latitude + r.nextDouble() * 2 * maxOffset - maxOffset, 
      userPosition.longitude + r.nextDouble() * 2 * maxOffset - maxOffset,
    );

    targetExists = true;
    gameTime = 0;

    return true;
  }
}