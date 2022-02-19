import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user/services/auth.dart';
import 'package:user/services/database.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:user/widgets/loading.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  const OTPScreen(this.phone, {Key? key}) : super(key: key);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late String _verificationCode;
  String message = '';
  bool sent = false;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return !sent
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              title: const Text('OTP Verification'),
            ),
            body: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'Verify +251-${widget.phone}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 26),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: PinPut(
                    fieldsCount: 6,
                    textStyle:
                        const TextStyle(fontSize: 25.0, color: Colors.white),
                    eachFieldWidth: 40.0,
                    eachFieldHeight: 55.0,
                    focusNode: _pinPutFocusNode,
                    controller: _pinPutController,
                    submittedFieldDecoration: pinPutDecoration,
                    selectedFieldDecoration: pinPutDecoration,
                    followingFieldDecoration: pinPutDecoration,
                    pinAnimationType: PinAnimationType.fade,
                    onSubmit: (pin) async {
                      try {
                        await FirebaseAuth.instance
                            .signInWithCredential(PhoneAuthProvider.credential(
                                verificationId: _verificationCode,
                                smsCode: pin))
                            .then((value) async {
                          if (value.user != null) {
                            userSetup(otp: true).then((value) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Autenticate()),
                                  (route) => false);
                            }).onError((error, stackTrace) {
                              debugPrint(error.toString());
                              exit(0);
                            });
                          }
                        });
                      } catch (e) {
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('invalid OTP')));
                      }
                    },
                  ),
                ),
                Text(message)
              ],
            ),
          );
  }

  _verifyPhone() async {
    PhoneVerificationCompleted verificationCompleted;
    PhoneVerificationFailed verificationFailed;
    PhoneCodeSent codeSent;
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout;

    verificationCompleted = (PhoneAuthCredential phoneAuthCredential) async {
      await FirebaseAuth.instance
          .signInWithCredential(phoneAuthCredential)
          .then((value) async {
        if (value.user != null) {
          userSetup(otp: true).then((value) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Autenticate()),
                (route) => false);
          }).onError((error, stackTrace) {
            debugPrint(error.toString());
            exit(0);
          });
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Phone number automatically verified and user signed in: $phoneAuthCredential')));
    };

    verificationFailed = (FirebaseAuthException authException) {
      setState(() {
        message =
            'Phone number verification failed. Code: ${authException.code}. '
            'Message: ${authException.message}';
      });
    };

    codeSent = (String verificationId, [int? forceResendingToken]) async {
      _verificationCode = verificationId;
      setState(() {
        sent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please check your phone for the verification code.')));
    };

    codeAutoRetrievalTimeout = (String verificationId) {
      _verificationCode = verificationId;
    };

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+251${widget.phone}',
          timeout: const Duration(seconds: 120),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to Verify Phone Number: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }

  @override
  void dispose() {
    super.dispose();
    _verifyPhone();
  }
}
