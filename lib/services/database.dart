import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

FirebaseAuth auth = FirebaseAuth.instance;

String? uid = auth.currentUser!.uid;
Future<void> uploadProfile(String filepath) async {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('account');
  File file = File(filepath);
  try {
    await storage.ref('img/$uid').putFile(file);
    String url = await storage.ref('img/$uid').getDownloadURL();

    users.doc(uid).update({'photoUrl': url});
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<bool> userSetup(
    {String? fullName,
    String? email,
    String? address,
    Timestamp? dateOfBirth,
    String? sex}) async {
  CollectionReference users = FirebaseFirestore.instance.collection('account');
  final snapShot = await FirebaseFirestore.instance
      .collection('account')
      .doc(uid) // varuId in your case
      .get();
  CollectionReference rate = FirebaseFirestore.instance.collection('rate');
  CollectionReference user =
      FirebaseFirestore.instance.collection('userDetail');
  if (!snapShot.exists) {
    try {
      user.doc(uid).set({
        'active': false,
        'disable': false,
        'registeredDate': Timestamp.now()
      });
      rate.doc(uid).set({'value': 0, 'count': 0, 'rate': 0});
      users.doc(uid).set({
        'fullName': '',
        'phoneNumber': FirebaseAuth.instance.currentUser!.phoneNumber,
        'address': '',
        'photoUrl':
            'https://firebasestorage.googleapis.com/v0/b/maintenance-service-locator.appspot.com/o/img%2Favatar.png?alt=media&token=b5bd012f-d7eb-445a-a9ce-fe192b21cfeb',
        'email': '',
        'dateOfBirth': Timestamp.fromDate(DateTime(1000, 10, 10)),
        'sex': ''
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
    if (dateOfBirth != Timestamp.fromDate(DateTime(1000, 10, 10))) {
      users.doc(uid).update({'dateOfBirth': dateOfBirth});
    }
    if (sex != '') {
      users.doc(uid).update({'sex': sex});
    }
    if (fullName != '') {
      users.doc(uid).update({'fullName': fullName});
    }
    if (address != '') {
      users.doc(uid).update({'address': address});
    }
    if (email != '') {
      users.doc(uid).update({'email': email});
    }
    user.doc(uid).update({'active': true});
    return true;
  }
  return false;
}

Stream<QuerySnapshot> select(String status) {
  Stream<QuerySnapshot> activity = FirebaseFirestore.instance
      .collection('activity')
      .where('user_id', isEqualTo: uid)
      .where('status', isEqualTo: status)
      .snapshots();
  return activity;
}

Future<bool> giveComment(String message, String to) async {
  CollectionReference comment =
      FirebaseFirestore.instance.collection('comment');
  comment.add({
    'from': uid,
    'to': to,
    'message': message,
    'time': Timestamp.now()
  }).then((_) {
    debugPrint('comment added successfully');
    return true;
  });
  return false;
}

Future<bool> giveComplain(String message, String to) async {
  CollectionReference complain =
      FirebaseFirestore.instance.collection('complain');
  complain.add({
    'from': uid,
    'to': to,
    'message': message,
    'time': Timestamp.now(),
    'who': 'Service Provider'
  }).then((_) {
    debugPrint('comment added successfully');
    return true;
  });
  return false;
}

Future<void> setRating(double v, String to) async {
  CollectionReference rate = FirebaseFirestore.instance.collection('rate');
  double? value;
  int? count;
  rate.doc(uid).get().then((va) {
    value = va['value'] + v;
    count = va['count'] + 1;
  });
  rate.doc(to).update(
      {'value': value, 'count': count, 'rate': value! / count!}).then((_) {
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
  print('sendrequest / * / *' * 10);
  try {
    bool sent = false;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> a =
        await FirebaseFirestore.instance.collection('account').doc(uid).get();
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
  } catch (e) {
    print(e);
    throw Exception(e);
  }
}
