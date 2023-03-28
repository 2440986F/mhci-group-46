import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/game/screens/map/map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

enum _GameStates { SELECT_DISTANCE, SELECT_DIFFICULTY, PLAYING, FOUND_OBJECT }

enum _GameDifficulties { EASY, MEDIUM, HARD }

class GameInstance extends StatefulWidget {
  _GameStates state = _GameStates.SELECT_DISTANCE;
  LatLng? targetPosition;
  Isolate? pingIsolate;
  ReceivePort receiveFromPingIsolate = ReceivePort();
  SendPort? sendToPingIsolate;
  AudioPlayer audioPlayer = AudioPlayer();

  Stream<Position> positionStream = Geolocator.getPositionStream(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.high));

  Timer? timer;

  bool pingDone = false;

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
        return Scaffold(
            appBar: AppBar(title: const Text('Select Max Distance')),
            body: Center(
                child: ListView(padding: const EdgeInsets.all(8), children: [
              Container(
                  height: 50,
                  color: Colors.blue,
                  child: ElevatedButton(
                      child: const Text('2.5km'),
                      onPressed: () {
                        _setTarget(2.5).then((value) => setState(() {
                              widget.state = _GameStates.SELECT_DIFFICULTY;
                              widget.targetPosition = value;
                            }));
                      })),
              const Divider(),
              Container(
                  height: 50,
                  color: Colors.blue,
                  child: ElevatedButton(
                      child: const Text('5km'),
                      onPressed: () {
                        _setTarget(5).then((value) => setState(() {
                              widget.state = _GameStates.SELECT_DIFFICULTY;
                              widget.targetPosition = value;
                            }));
                      })),
              const Divider(),
              Container(
                  height: 50,
                  color: Colors.blue,
                  child: ElevatedButton(
                      child: const Text('10km'),
                      onPressed: () {
                        _setTarget(10).then((value) => setState(() {
                              widget.state = _GameStates.SELECT_DIFFICULTY;
                              widget.targetPosition = value;
                            }));
                      })),
            ])));
      case _GameStates.SELECT_DIFFICULTY:
        // This spawns a thread that keeps track of when to
        // play the ping sound.
        Isolate.spawn(_playSonarPing, [
          widget.receiveFromPingIsolate.sendPort,
          widget.targetPosition!,
          widget.audioPlayer,
        ]).then((isolate) => widget.pingIsolate = isolate);

        // Can't play sound from within a thread so we need to
        // get the new thread to send a message back to the main
        // thread so that it can play the sound.
        widget.receiveFromPingIsolate.listen((message) {
          if (message is SendPort) {
            widget.sendToPingIsolate = message;
          } else {
            widget.audioPlayer.play(AssetSource('sounds/sonar-ping-95840.mp3'));
            Geolocator.getLastKnownPosition().then((value) {
              widget.sendToPingIsolate
                  ?.send([value!.latitude, value.longitude]);
            });
          }
        });
        return Scaffold(
            appBar: AppBar(title: const Text('Select Difficulty')),
            body: Center(
                child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Container(
                  height: 50,
                  color: Colors.blue,
                  child: ElevatedButton(
                      child: const Text('Easy'),
                      onPressed: () {
                        setState(() => widget.state = _GameStates.PLAYING);
                      }),
                ),
                const Divider(),
                Container(
                  height: 50,
                  color: Colors.blue,
                  child: ElevatedButton(
                      child: const Text('Hard'),
                      onPressed: () {
                        setState(() => widget.state = _GameStates.PLAYING);
                      }),
                ),
              ],
            )));
      case _GameStates.PLAYING:
        // This is the timer that updates the sonar ping on the map.
        // Might find a better way of doing this, it is very laggy atm.
        widget.timer = Timer(const Duration(milliseconds: 50), () {
          setState(() {});
        });

        // Return a map when positionStream gets new data, an error
        // if something goes wrong, and a loading thing if we are still
        // waiting.
        return StreamBuilder<Position>(
            stream: widget.positionStream,
            builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                //widget.sendToPingIsolate?.send(snapshot.data);
                children = <Widget>[
                  MapHomeState(
                    userPosition: snapshot.data!,
                    targetPosition: widget.targetPosition!,
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
      case _GameStates.FOUND_OBJECT:
        widget.pingIsolate?.kill(priority: Isolate.beforeNextEvent);
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

void _playSonarPing(List<dynamic> args) async {
  SendPort sendToMain = args[0];
  LatLng targetPosition = args[1];

  ReceivePort receiver = ReceivePort();
  sendToMain.send(receiver.sendPort);

  int timeBetweenPings = 1000;

  // We change the delay between pings every time the user's position updates.
  receiver.listen((message) => () async {
        print("D");
        LatLng userPosition = LatLng(message[0], message[1]);

        double distance = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            targetPosition.latitude,
            targetPosition.longitude);

        timeBetweenPings = (distance * 100).toInt();
      });

  while (true) {
    print(timeBetweenPings);

    await Future.delayed(Duration(milliseconds: timeBetweenPings));

    sendToMain.send(timeBetweenPings);
  }
}

_playSonarPing1(List<dynamic> args) async {
  SendPort sendToMain = args[0];
  LatLng targetPosition = args[1];

  ReceivePort receiver = ReceivePort();
  sendToMain.send(receiver.sendPort);

  int timeBetweenPings = 1000;

  while (true) {
    print(timeBetweenPings);
    sendToMain.send(timeBetweenPings);

    await Future.delayed(Duration(milliseconds: timeBetweenPings));

    var r = await receiver.take(1).first;
    LatLng userPosition = LatLng(r[0], r[1]);

    print(userPosition);

    double distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        targetPosition.latitude,
        targetPosition.longitude);

    timeBetweenPings = (distance).toInt();
  }
}
