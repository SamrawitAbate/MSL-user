import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user/services/auth.dart';
import 'package:user/services/database.dart';
import 'package:user/widgets/changePhoto.dart';
import 'package:user/widgets/loading.dart';

enum Gender { male, female }

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with InputValidationMixin {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String fullName = '', email = '', sex = '', address = '', password = '';
  final formGlobalKey = GlobalKey<FormState>();
  Gender? _character = Gender.female;
  DateTime selectedDate = DateTime.now();

  bool first = true;
  String ageMessage = '';
  @override
  Widget build(BuildContext context) {
    const TextStyle st = TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Autenticate()));
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('account')
                .doc(uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                debugPrint(snapshot.error.toString());
                return Center(
                    child: Row(
                  children: [
                    const Icon(Icons.error),
                    Text(snapshot.error.toString(), maxLines: 3)
                  ],
                ));
              }
              if (snapshot.hasData) {
                var data = snapshot.data!;
                if (first &&
                    data['dateOfBirth'] !=
                        Timestamp.fromDate(DateTime(1000, 10, 10))) {
                  selectedDate = data['dateOfBirth'].toDate();
                }
                if (first) {
                  _character =
                      data['sex'] == 'Male' ? Gender.male : Gender.female;
                  first = false;
                }
                return Form(
                    key: formGlobalKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Account',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w700)),
                          ),
                          ChangePhoto(img: data['photoUrl'], my: true),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: data['fullName'] ?? '',
                              onChanged: (v) {
                                setState(() {
                                  fullName = v;
                                });
                              },
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Full Name',
                                  labelStyle: st),
                              validator: (value) {
                                return nameRequired(value!)
                                    ? null
                                    : 'EnterFull Name';
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: data['email'] ?? '',
                              onChanged: (v) {
                                setState(() {
                                  email = v;
                                });
                              },
                              style: st,
                              decoration: const InputDecoration(
                                  labelText: 'email',
                                  labelStyle: st,
                                  border: OutlineInputBorder()),
                              validator: (email) {
                                return isEmailValid(email!)
                                    ? null
                                    : 'Enter a valid email address';
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const Text(
                                  'phone number',
                                  style: TextStyle(fontSize: 22),
                                ),
                                Text(
                                  data['phoneNumber'],
                                  style: const TextStyle(
                                      letterSpacing: 8, fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      sexRadio(Gender.female),
                                      sexRadio(Gender.male),
                                    ],
                                  ),
                                ]),
                          ),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '   Age ${DateTime.now().year - selectedDate.year}',
                                  style: st,
                                ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime(1950),
                                          lastDate: DateTime.now())
                                      .then((value) {
                                    if (value != null &&
                                        value != selectedDate) {
                                      setState(() {
                                        selectedDate = value;
                                      });
                                    }
                                  });
                                },
                                child: const Text(
                                  'Select DOB',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                ageMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: data['address'] ?? '',
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Address',
                                  labelStyle: st),
                              onChanged: (v) {
                                setState(() {
                                  address = v;
                                });
                              },
                              style: st,
                              validator: (value) {
                                return valueRequired(value!)
                                    ? null
                                    : 'Enter Address';
                              },
                            ),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                onPrimary: Colors.white,
                                primary: Colors.blue[800],
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                              ),
                              onPressed: () {
                                if (formGlobalKey.currentState!.validate()) {
                                  if ((DateTime.now().year -
                                          selectedDate.year) >
                                      5) {
                                    setState(() {
                                      ageMessage = '';
                                    });
                                    formGlobalKey.currentState!.save();
                                    userSetup(
                                            otp: false,
                                            fullName: fullName,
                                            email: email,
                                            address: address,
                                            dateOfBirth: Timestamp.fromDate(
                                                selectedDate),
                                            sex: Gender.female == _character
                                                ? 'Female'
                                                : 'Male')
                                        .then((value) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Autenticate()));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(value
                                                  ? 'Updated'
                                                  : 'Update failed')));
                                    });
                                  } else {
                                    setState(() {
                                      ageMessage = 'Age must be greater than 5';
                                    });
                                  }
                                }
                              },
                              child: const Text(
                                'Update',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ))
                        ],
                      ),
                    ));
              }

              return const Loading();
            }),
      ),
    );
  }

  Row sexRadio(value) {
    return Row(children: [
      Radio<Gender>(
        value: value,
        groupValue: _character,
        onChanged: (Gender? value) {
          setState(() {
            _character = value;
          });
        },
      ),
      Text(value == Gender.male ? 'Male' : 'Female'),
    ]);
  }
}

mixin InputValidationMixin {
  bool isPasswordValid(String password) => password.length >= 6;

  bool isEmailValid(String email) {
    RegExp regex = RegExp(
        //r'/^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/');
        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return regex.hasMatch(email);
  }

  bool valueRequired(String value) => value.isNotEmpty;
  bool nameRequired(String value) => value.length > 5;
}
