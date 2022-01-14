import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DisablePage extends StatelessWidget {
  const DisablePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.signOut();
    return Scaffold(
      body: Column(
        children: [
          const Text('Account Disabled',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
          const Text('Contact the admin with email',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
          const Text('mearegabate@gmail.com',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ElevatedButton(
              onPressed: () {
                exit(0);
              },
              child: const Text('Exit'))
        ],
      ),
    );
  }
}
