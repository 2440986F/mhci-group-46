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

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Container(
              height: 50,
              color: Colors.blue,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/map');
                },
                child: const Text('Go to map view')
              ),
            ),
            const Divider(),
            Container(
              height: 50,
              color: Colors.blue,
              child: ElevatedButton(
                onPressed: () {
                  
                },
                child: const Text('Go nowhere')
              ),

            ),
          ]
        )
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final GameController controller = GameController();
  Future<bool>? roundReady;

  MyApp({super.key}) {
    roundReady = controller.setTarget(5); //ada asks: what does this do?
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radsonar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialRoute: '/menu',

      routes: {
        '/map': (context) => FutureBuilder(
        future: roundReady,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if(snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: Map(targetPosition: controller.target!),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/menu');
                },
                tooltip: 'Menu',
                child: const Icon(Icons.list),
              ),
            );
          } else {
            return const Text("Loading");
          }
        }
      ),
      '/menu': (context) => const MenuScreen(),
      },
    );
  }
}
