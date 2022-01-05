import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user/pages/login.dart';
import 'package:user/pages/mainPage.dart';
import 'package:user/services/location.dart';

class Autenticate extends StatefulWidget {
  const Autenticate({Key? key}) : super(key: key);
  @override
  _AutenticateState createState() => _AutenticateState();
}

class _AutenticateState extends State<Autenticate> {
  bool auth = false;
  @override
  Widget build(BuildContext context) {
  getPermision();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        auth = user == null ? false : true;
      });
    });
    return auth ? const MainPage() : const Login();
  }
}
