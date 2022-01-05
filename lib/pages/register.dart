import 'package:flutter/material.dart';
import 'package:user/services/auth.dart';
import 'package:user/services/database.dart';
import 'package:user/widgets/loading.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController fullName = TextEditingController(text: '');
  TextEditingController email = TextEditingController(text: '');
  TextEditingController sex = TextEditingController(text: '');
  TextEditingController address = TextEditingController(text: '');
  TextEditingController phoneNumber = TextEditingController(text: '');
  TextEditingController dateOfBirth = TextEditingController(text: '');
  TextEditingController password = TextEditingController(text: '');
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : SafeArea(
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(25),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Register to continue',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.w700),
                      ),
                      Form(
                          child: Column(
                        children: [
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: fullName,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Full Name'),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: email,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'email'),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: phoneNumber,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'phone number'),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: sex,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(), labelText: 'Sex'),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: dateOfBirth,
                            keyboardType: TextInputType.datetime,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Date of Birth'),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: password,
                            obscureText: true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'password'),
                          ),
                          const SizedBox(height: 10),
                      
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                             
                            
                                bool userup = await userSetup(fullName.text, phoneNumber.text, email.text, address.text, dateOfBirth.text, sex.text);
                                if (userup) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const Autenticate()));
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                }
                             
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Register',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.green,
                                    fontSize: 25),
                              ),
                            ),
                          )
                        ],
                      ))
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
