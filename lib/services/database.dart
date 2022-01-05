import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

FirebaseAuth auth = FirebaseAuth.instance;

String? uid = auth.currentUser!.uid;
Future<void> uploadProfile(String filepath) async {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  File file = File(filepath);
  try {
    await storage.ref('img/$uid').putFile(file);
   String url= await storage.ref('img/$uid').getDownloadURL();

   users.doc(uid).update({'photoUrl': url});
  } catch (e) {
    print(e);
  }
}

Future<bool> userSetup(String fullName, String phoneNumber, String email,
    String? address, String dateOfBirth, String sex) async {
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  final snapShot = await FirebaseFirestore.instance
      .collection('Users')
      .doc(uid) // varuId in your case
      .get();
  CollectionReference rate = FirebaseFirestore.instance.collection('rate');
  if (!snapShot.exists) {
    try {
      rate.doc(uid).set({'value': 1, 'count': 1});
      users.doc(uid).set({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'address': address,
        'photoUrl': 'https://firebasestorage.googleapis.com/v0/b/maintenance-service-locator.appspot.com/o/img%2Fblank-profile.png?alt=media&token=758d9f6b-f5e1-4a7c-8df7-996d0e1e1136',
        'email': email,
        'dateOfBirth': dateOfBirth == ''
            ? Timestamp.fromDate(DateTime(1000, 10, 10))
            : dateOfBirth,
        'sex': sex
      }).then((value) {
        return true;
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        return false;
      });
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  } else {
    if (dateOfBirth != '') {
      users.doc(uid).update({'dateOfBirth': dateOfBirth});
    }
    if (sex != '') {
      users.doc(uid).update({'sex': sex});
    }
    if (fullName != '') {
      users.doc(uid).update({'fullName': fullName});
    }
    if (phoneNumber != '') {
      users.doc(uid).update({'phoneNumber': phoneNumber});
    }
    if (address != '') {
      users.doc(uid).update({'address': address});
    }
    if (email != '') {
      users.doc(uid).update({'email': email});
    }
   
    return true;
  }
  return false;
}

Future<void> addLocation(GeoFirePoint myLocation) async {
  CollectionReference maintenanceLocations =
      FirebaseFirestore.instance.collection('userLocations');
  maintenanceLocations.doc(uid).set(
      {'position': myLocation.data, 'lastLocation': Timestamp.now()}).then((_) {
    debugPrint('added ${myLocation.hash} successfully');
  });
}

Stream<QuerySnapshot> select(String status) {
  Stream<QuerySnapshot> activity = FirebaseFirestore.instance
      .collection('activity')
      .where('user_id', isEqualTo: uid)
      .where('status', isEqualTo: status)
      .snapshots();
  return activity;
}

Future<void> giveComment(String message, String to) async {
  CollectionReference comment =
      FirebaseFirestore.instance.collection('comment');
  comment.add({
    'from': uid,
    'to': to,
    'message': message,
    'time': Timestamp.now()
  }).then((_) {
    debugPrint('comment added successfully');
  });
}

Future<void> setRating(double v, String to) async {
  CollectionReference rate = FirebaseFirestore.instance.collection('rate');
  double? value;
  int? count;
  rate.doc(uid).get().then((va) {
    value = va['value'] + v;
    count = va['count'] + 1;
  });
  rate.doc(to).update({'value': value, 'count': count}).then((_) {
    debugPrint('rate added successfully');
  });
}

Future<void> changeStatus(String id, String status) async {
  CollectionReference rate = FirebaseFirestore.instance.collection('activity');

  rate.doc(id).update({
    'status': status,
  }).then((_) {
    debugPrint('status changed successfully');
  });
}

Future<bool> sendRequest(String id, String message, GeoPoint location) async {
  bool sent = false;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot<Map<String, dynamic>> a =
      await FirebaseFirestore.instance.collection('Users').doc(uid).get();
  FirebaseFirestore.instance.collection('activity').add({
    'user_id': uid,
    'name': a['fullName'],
    'request_time': Timestamp.now(),
    'job_description': message,
    'skill_id': id,
    'location': location,
    'status': 'Requested'
  }).then((value) {
    debugPrint('Request sent');
    sent = true;
  });
  return sent;
}
