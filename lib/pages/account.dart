import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user/services/auth.dart';
import 'package:user/services/database.dart';
import 'package:user/widgets/loading.dart';

enum SingingCharacter { male, female }

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with InputValidationMixin {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String fullName = '',
      email = '',
      sex = '',
      address = '',
      dateOfBirth = '',
      password = '';
  final formGlobalKey = GlobalKey<FormState>();
  SingingCharacter? _character = SingingCharacter.female;
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(1950),
            lastDate: DateTime(2222))
        .then((picked) {
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
        });
      }
      return;
    });
  }

  String ageMessage = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('account')
              .doc(uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error = ${snapshot.error}');
            }

            if (snapshot.hasData) {
              var data = snapshot.data!;
              if (data['dateOfBirth'] !=
                  Timestamp.fromDate(DateTime(1000, 10, 10))) {
                //   setState(() {
                selectedDate = data['dateOfBirth'].toDate();
                //   });
              }
              return Form(
                  key: formGlobalKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                        ),
                        const SizedBox(height: 20),
                        const Text('Account'),
                        TextFormField(
                          initialValue: data['fullName'] ?? '',
                          onChanged: (v) {
                            setState(() {
                              fullName = v;
                            });
                          },
                          decoration:
                              const InputDecoration(labelText: 'Full Name'),
                          validator: (value) {
                            return nameRequired(value!)
                                ? null
                                : 'EnterFull Name';
                          },
                        ),
                        TextFormField(
                          initialValue: data['email'] ?? '',
                          onChanged: (v) {
                            setState(() {
                              email = v;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'email'),
                          validator: (email) {
                            return isEmailValid(email!)
                                ? null
                                : 'Enter a valid email address';
                          },
                        ),
                        Column(
                          children: [
                            const Text(
                              'phone number',
                              style: TextStyle(fontSize: 22),
                            ),
                            Text(
                              data['phoneNumber'],
                              style: const TextStyle(
                                  letterSpacing: 10, fontSize: 20),
                            ),
                          ],
                        ),
                        //////
                        ///
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                children: [
                                  sexRadio(SingingCharacter.female),
                                  sexRadio(SingingCharacter.male),
                                ],
                              ),
                            ]),

                        ///
                        //////
                        ///
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            // Text("${selectedDate.toLocal()}".split(' ')[0]),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  '   Age ${DateTime.now().year - selectedDate.year}'),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            ElevatedButton(
                              onPressed: () => _selectDate(context),
                              child: const Text('Select date'),
                            ),
                            Text(
                              ageMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),

                        ///
                        TextFormField(
                          initialValue: data['address'] ?? '',
                          decoration:
                              const InputDecoration(labelText: 'Address'),
                          onChanged: (v) {
                            setState(() {
                              address = v;
                            });
                          },
                          validator: (value) {
                            return valueRequired(value!)
                                ? null
                                : 'Enter Address';
                          },
                        ),
                        ElevatedButton(
                            onPressed: () {
                              if (formGlobalKey.currentState!.validate()) {
                                if ((DateTime.now().year - selectedDate.year) >
                                    5) {
                                  setState(() {
                                    ageMessage = '';
                                  });

                                  formGlobalKey.currentState!.save();
                                  // use the email provided here
                                  userSetup(
                                          fullName: fullName,
                                          email: email,
                                          address: address,
                                          dateOfBirth:
                                              Timestamp.fromDate(selectedDate),
                                          sex: SingingCharacter.female ==
                                                  _character
                                              ? 'Female'
                                              : 'Male')
                                      .then((value) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Autenticate()));
                                    value
                                        ? const SnackBar(
                                            content: Text('Updated'))
                                        : const SnackBar(
                                            content: Text('Update failed'));
                                  });
                                } else {
                                  setState(() {
                                    ageMessage = 'Age must be greater than 5';
                                  });
                                }
                              }
                            },
                            child: const Text('update'))
                      ],
                    ),
                  ));
            }

            return const Loading();
          }),
    );
  }

  Row sexRadio(value) {
    return Row(children: [
      Radio<SingingCharacter>(
        value: value,
        groupValue: _character,
        onChanged: (SingingCharacter? value) {
          setState(() {
            _character = value;
          });
        },
      ),
      Text(value == SingingCharacter.male ? 'Male' : 'Female'),
    ]);
  }
}

mixin InputValidationMixin {
  bool isPasswordValid(String password) => password.length >= 6;

  bool isEmailValid(String email) {
    RegExp regex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return regex.hasMatch(email);
  }

  bool valueRequired(String value) => value.isNotEmpty;
  bool nameRequired(String value) => value.length > 5;
}
