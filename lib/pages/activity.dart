import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user/pages/profile.dart';
import 'package:user/services/database.dart';
import 'package:user/widgets/loading.dart';
import 'package:user/widgets/ratingBarView.dart';
import 'package:user/widgets/showAlertialog.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int indexValue = 0;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> title = ["Requested", "Accepted", "Rejected", "Completed"];
  List<Stream<QuerySnapshot>>? status;
  @override
  void initState() {
    status = [
      select("Requested"),
      select("Accepted"),
      select("Rejected"),
      select("Completed")
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: Text(title[indexValue]), centerTitle: true, actions: [
          PopupMenuButton(
              elevation: 20,
              onSelected: (value) => setState(() {
                    indexValue = value as int;
                  }),
              itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text("Requested"),
                      value: 0,
                    ),
                    const PopupMenuItem(
                      child: Text("Accepted"),
                      value: 1,
                    ),
                    const PopupMenuItem(
                      child: Text("Rejected"),
                      value: 2,
                    ),
                    const PopupMenuItem(
                      child: Text("Completed"),
                      value: 3,
                    ),
                  ])
        ]),
        body: StreamBuilder<QuerySnapshot>(
          stream: status![indexValue],
          builder: (context, snapshot) {
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
            if (!snapshot.hasData) {
              return const Loading();
            }
            return AppCaeousel(
              indexValue: indexValue,
              documents: snapshot.data!.docs,
            );
          },
        ));
  }
}

class AppCaeousel extends StatelessWidget {
  const AppCaeousel(
      {Key? key, required this.documents, required this.indexValue})
      : super(key: key);
  final List<DocumentSnapshot> documents;
  final int indexValue;
  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      String va = '';
      switch (indexValue) {
        case 0:
          va = 'No Request yet..';
          break;
        case 1:
          va = 'No Accepted Request yet..';
          break;
        case 2:
          va = 'No Rejected Request yet..';
          break;
        case 3:
          va = 'No completed Request yet..';
          break;
        default:
          va = '';
      }
      return Center(
        child: Text(va),
      );
    }

    return Container(
        margin: const EdgeInsets.only(top: 50, left: 5, right: 5),
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return SizedBox(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Card(
                          child: Center(
                              child: AppListTile(
                        indexValue: indexValue,
                        document: documents[index],
                      )))));
            }));
  }
}

class AppListTile extends StatelessWidget {
  const AppListTile(
      {Key? key, required this.document, required this.indexValue})
      : super(key: key);
  final DocumentSnapshot document;
  final int indexValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('account')
                  .doc(document['skill_id'])
                  .snapshots(),
              builder:
                  (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap) {
                if (snap.hasError) {
                  debugPrint(snap.error.toString());
                  return Center(
                      child: Row(
                    children: [
                      const Icon(Icons.error),
                      Text(snap.error.toString(), maxLines: 3)
                    ],
                  ));
                }
                if (snap.hasData) {
                  var data = snap.data!;
                  return Row(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage(
                                        my: false,
                                        user: true,
                                        uid: document['user_id'])));
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(data['photoUrl']),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          data['fullName'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                      ),
                    ],
                  );
                }
                return Container();
              }),
          Text(
            document['job_description'],
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          Text(
            document['request_time'].toDate().toString(),
            style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
          ),
          ActionSelection(indexValue: indexValue, uid: document['skill_id']),
        ],
      ),
    );
  }
}

class ActionSelection extends StatelessWidget {
  const ActionSelection({Key? key, required this.indexValue, required this.uid})
      : super(key: key);
  final int indexValue;
  final String uid;
  @override
  Widget build(BuildContext context) {
    switch (indexValue) {
      case 0:
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
                onPressed: () {
                  changeStatus(uid, 'Cancle');
                },
                child: const Text('Cancle')),
          ),
        );
      case 1:
        return Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                  onPressed: () async {
                    popUp(context, 'Complain', id: uid);
                  },
                  child: const Text('Complain')),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                  onPressed: () async {
                    popUp(context, 'Comment', id: uid);
                  },
                  child: const Text('Comment')),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                  onPressed: () {
                    changeStatus(uid, 'Completed');
                  },
                  child: const Text('Complete')),
            ),
          ],
        );
      case 2:
        return Container();
      case 3:
        return Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                  onPressed: () async {
                    popUp(context, 'Complain', id: uid);
                  },
                  child: const Text('Complain')),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                  onPressed: () async {
                    popUp(context, 'Comment', id: uid);
                  },
                  child: const Text('Comment')),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              content: Center(
                            child: RatingBarCustom(
                              to: uid,
                              rate: true,
                              my: false,
                            ),
                          ));
                        });
                  },
                  child: const Text('Rating')),
            ),
          ],
        );
      default:
        return Container();
    }
  }
}
