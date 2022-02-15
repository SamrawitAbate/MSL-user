import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user/pages/account.dart';
import 'package:user/pages/disablePage.dart';
import 'package:user/pages/login.dart';
import 'package:user/pages/mainPage.dart';
import 'package:user/widgets/loading.dart';

class Autenticate extends StatelessWidget {
  const Autenticate({Key? key}) : super(key: key);

   Future<bool> active() async {
    final value = await FirebaseFirestore.instance
        .collection('userDetail')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return value.data()!["active"];
  }
   Future<bool> disable() async {
    final value = await FirebaseFirestore.instance
        .collection('userDetail')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return value.data()!["disable"];
  }
 
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return FutureBuilder<bool>(
        future: disable(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        
            if (snapshot.hasData) {
              return snapshot.data! ? const DisablePage() : 
           FutureBuilder<bool>(
              future: active(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              
                if (snapshot.hasData) {
                  return snapshot.data! ? const MainPage() : const AccountPage();
                }
                return const Loading();
              });
            }
            return const Loading();
        }
      );
    }
    return const Login();
  }
}