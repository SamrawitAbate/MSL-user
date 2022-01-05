import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:user/services/auth.dart';
import '../services/location.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maintenance service locator',
      theme:  ThemeData(
        brightness: Brightness.dark,fontFamily:'Numans'
      ),
      home: const App()));
}

class App extends StatefulWidget {
 const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  bool connection = true;
  Future<void> _checkConnectivityState() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    bool c = true;
    if (result == ConnectivityResult.wifi) {
      debugPrint('Connected to a Wi-Fi network');
      c = true;
    } else if (result == ConnectivityResult.mobile) {
      debugPrint('Connected to a mobile network');
      c = true;
    } else {
      debugPrint('Not connected to any network');
      c = false;
    }
    setState(() {
      connection = c;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkConnectivityState();
  }

  @override
  Widget build(BuildContext context) {
    if (!connection) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Image.asset('assets/img/offline.jpg'),
        ),
      );
    }
    getPermision();
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Icon(Icons.error));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const Autenticate();
        }
        return const Center(child: Icon(Icons.circle_outlined));
      },
    );
  }
}
