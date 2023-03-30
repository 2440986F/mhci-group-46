import 'package:flutter/material.dart';
import 'package:radsonar/game/game_instance.dart';
import 'game/screens/map/map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Geolocator.checkPermission().then((permissionAllowed) => {
        if (permissionAllowed == LocationPermission.denied)
          {Geolocator.requestPermission().then((value) => {})}
      });
  runApp(
    ChangeNotifierProvider(
      create: (context) => AccountDataModel(),
      child: const MyApp(),
    ));
}

class AccountDataModel extends ChangeNotifier {
  bool _loggedIn = false;
  String _username = "";
  int _points = 0;

  bool get loggedIn => _loggedIn;
  String get username => _username;
  int get points => _points;

  void logIn(String name) {
    _username = name;
    _loggedIn = true;
    notifyListeners();
  }

  void addPoints(int newPoints){
    _points += newPoints;
  }

}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountDataModel>(
      builder: (context, accountData, child) {
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
                    if (accountData.loggedIn){
                      Navigator.pushNamed(context, '/game_home');
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in before playing')));
                    }
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
    );
  }
}

class AccountWidget extends StatefulWidget {
  const AccountWidget({super.key});

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  //bool _loggedIn = false;
  //bool get loggedIn => _loggedIn;
  //String _username = "";
  //String get username => _username;
  TextEditingController usernameController = TextEditingController();

  buildAccountPage(accountData){
      if (accountData.loggedIn){
        return <Widget>[
          
          SizedBox(child: Text("Hello, ${accountData.username} \n"),),
          SizedBox(child: Text("You have ${accountData.points} points. Check out the leaderboard to see how your friends are doing")),
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
                accountData.logIn(usernameController.text);
              
            }, child: const Text('Log In')),
          ];
        }
    }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountDataModel>(
      builder: (context, accountData, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
          ),
          body: Center(
              child: ListView(padding: const EdgeInsets.all(8), children: buildAccountPage(accountData))
          ),
        );
    },
  );
    

  }
}

class LeaderBoardWidget extends StatelessWidget {
  const LeaderBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountDataModel>(
    builder: (context, accountData, child) {
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
          const Divider(),
          Container(
            child: Text("${accountData.username}: ${accountData.points} points")
          ),
        ])),
      );
    }
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
