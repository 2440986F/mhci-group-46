import 'package:flutter/material.dart';
import 'package:flutter_application_2/game/game_instance.dart';
import 'game/screens/map/map.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Geolocator.checkPermission().then((permissionAllowed) => {
        if (permissionAllowed == LocationPermission.denied)
          {Geolocator.requestPermission().then((value) => {})}
      });
  runApp(MyApp());
}

final accountInfoKey = GlobalKey<_AccountWidgetState>();

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Center(
          child: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
        Container(
          height: 50,
          color: Colors.blue,
          child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/game_home');
              },
              child: const Text('Play')),
        ),
        const Divider(),
        Container(
          height: 50,
          color: Colors.blue,
          child:
              ElevatedButton(onPressed: () {
                Navigator.pushNamed(context, '/account');
              }, child: const Text('Account')),
        ),
        const Divider(),
        Container(
          height: 50,
          color: Colors.blue,
          child:
              ElevatedButton(onPressed: () {
                Navigator.pushNamed(context, '/leaderboard');
              }, child: const Text('Leaderboard')),
        ),
      ])),
    );
  }
}

class AccountWidget extends StatefulWidget {
  const AccountWidget({super.key});

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  String _username = "";
  String get username => _username;
  TextEditingController usernameController = TextEditingController();

  buildAccountPage(){
      if (_loggedIn){
        return <Widget>[
          SizedBox(child: Text("Hello, $_username \n"),),
          SizedBox(child: Text("You have 15 points. Check out the leaderboard to see how your friends are doing")),
          const Divider(),
          ElevatedButton(onPressed: () {
            Navigator.pushNamed(context, '/leaderboard');
            }, child: const Text('Leaderboard')),
      ];
      }else{
        return <Widget>[
          const SizedBox(child: Text("Please Log in"),),
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Username',
                
              ),
              controller: usernameController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Password',
                
              ),
              obscureText: true,
            ),
            ElevatedButton(onPressed: () {
               setState(() {
                _username = usernameController.text;
                _loggedIn = true;
                });
              
            }, child: const Text('Log In')),
          ];
        }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Center(
          child: ListView(padding: const EdgeInsets.all(8), children: buildAccountPage())),
    );

  }
}

class LeaderBoardWidget extends StatelessWidget {
  const LeaderBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Center(
          child: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
        Container(
          child: const Text("Alice: 155 points")
        ),
        const Divider(),
        Container(
          child: const Text("Bob: 70 points")
        ),
        const Divider(),
        Container(
          child: const Text("Charlie: 30 points")
        ),
      ])),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/game_home': (context) => GameInstance(),
        '/menu': (context) => const MenuScreen(),
        '/account': (context) => AccountWidget(),
        '/leaderboard': (context) => LeaderBoardWidget(),
      },
    );
  }
}
