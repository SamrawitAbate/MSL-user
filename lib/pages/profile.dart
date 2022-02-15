import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user/pages/account.dart';
import 'package:user/widgets/changePhoto.dart';
import 'package:user/widgets/listFile.dart';
import 'package:user/widgets/loading.dart';
import 'package:user/widgets/ratingBarView.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage(
      {required this.my, required this.uid, required this.user, Key? key})
      : super(key: key);
  final bool my, user;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('account')
                  .doc(uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) return Text('Error = ${snapshot.error}');

                if (snapshot.hasData) {
                  var data = snapshot.data!;
                  Timestamp ts = data['dateOfBirth'] as Timestamp;
                  DateTime dt = ts.toDate();
                  bool empty = dt ==
                    DateTime(1000, 10, 10) ? true : false;
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ChangePhoto(img: data['photoUrl'], my: my),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  data['fullName'],
                                  style: const TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                RatingBarCustom(to: uid,rate: false,my: my,)
                              ],
                            ),
                            const Divider(),
                            newMethod(
                                'Phone Number:', data['phoneNumber'] ?? ''),
                            newMethod('Email:', data['email']),
                            newMethod('Address:', data['address']),
                            newMethod('Gender:', data['sex']),
                            newMethod('Birthday:',
                                empty ? '' : "${dt.toLocal()}".split(' ')[0]),
                            user
                                ? Container()
                                : Column(
                                    children: [
                                      addList('Certificate', 'certificate'),
                                      const Divider(),
                                      addList('Education Background',
                                          'educationBackground'),
                                      const Divider(),
                                      addList('Reference Material',
                                          'referenceMaterial'),
                                      const Divider(),
                                    ],
                                  ),
                            const Divider(),
                            const Text(
                              "Comments:",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 28.0),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('comment')
                                    .where('reciver_uid', isEqualTo: uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }
                                  if (snapshot.hasData) {
                                    final List<DocumentSnapshot> documents =
                                        snapshot.data!.docs;
                                    if (documents.isEmpty) {
                                      return const Center(
                                        child: Text('No Comment..'),
                                      );
                                    }
                                    return ListView.builder(
                                        itemBuilder: (_, index) {
                                      return ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            documents[index]['name'],
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        subtitle: Text(
                                          documents[index]['message'],
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      );
                                    });
                                  }
                                  return const Loading();
                                }),
                            const SizedBox(
                              height: 20.0,
                            ),
                          ],
                        ),
                      ),
                      my
                          ? Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 30,
                                ),
                                onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AccountPage())),
                              ),
                            )
                          : const SizedBox()
                    ],
                  );
                }
                return const Loading();
              })),
    );
  }

  Wrap newMethod(String a, String b) {
    return Wrap(
      children: [
        _titleBuild(a),
        _titleBuild(b),
      ],
    );
  }

  Column addList(String lable, String value) {
    return Column(
      children: [
        Text(
          lable,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
        ),
        ListFile(
          dir: value,
          id: uid,
        ),
      ],
    );
  }

  Padding _titleBuild(String title) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          title,
          maxLines: 5,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 18.0),
        ));
  }
}
