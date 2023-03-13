import 'package:flutter/material.dart';
import 'package:flutter_application_2/game_controller.dart';
import 'map/map.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Geolocator.checkPermission().then((permissionAllowed) => {
    if(permissionAllowed == LocationPermission.denied) {
      Geolocator.requestPermission().then((value) => {})
    }
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GameController controller = GameController();
  Future<bool>? roundReady;

  MyApp({super.key}) {
    roundReady = controller.setTarget(5);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radsonar',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below toelow to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: roundReady,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if(snapshot.hasData) return Map(targetPosition: controller.target!);
          else return const Text("Loading");
        }
      ),
    );
  }
}
