import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Loading();
            }
            return StoreCaeousel(
              indexValue: indexValue,
              documents: snapshot.data!.docs,
            );
          },
        ));
  }
}

class StoreCaeousel extends StatelessWidget {
  const StoreCaeousel(
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
                              child: StoreListTile(
                        indexValue: indexValue,
                        document: documents[index],
                      )))));
            }));
  }
}

class StoreListTile extends StatefulWidget {
  const StoreListTile(
      {Key? key, required this.document, required this.indexValue})
      : super(key: key);
  final DocumentSnapshot document;
  final int indexValue;
  @override
  _StoreListTileState createState() => _StoreListTileState();
}

class _StoreListTileState extends State<StoreListTile> {
  // TextEditingController jobDescription = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            widget.document['user_id'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          Text(
            widget.document['job_description'],
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          Text(
            widget.document['request_time'].toDate().toString(),
            style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
          ),
          ActionSelection(
              indexValue: widget.indexValue, uid: widget.document.id),
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
          child: ElevatedButton(
              onPressed: () {
                changeStatus(uid, 'Cancle');
              },
              child: const Text('Cancle')),
        );
      case 1:
        return Row(
          children: [
            ElevatedButton(onPressed: () async {
                  List v = popUp(context, 'Message');
                  if (v[1]) {
                    giveComment(v[0], uid);
                  }
                }, child: const Text('Comment')),
            ElevatedButton(
                onPressed: () {
                  changeStatus(uid, 'Completed');
                },
                child: const Text('Complete')),
          ],
        );
      case 2:
        return Container();
      case 3:
        return Row(
          children: [
            ElevatedButton(
                onPressed: () async {
                  List v = popUp(context, 'Message');
                  if (v[1]) {
                    giveComment(v[0], uid);
                  }
                },
                child: const Text('Comment')),
            ElevatedButton(onPressed: () {
               showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            content: Center(
                              child: RatingBarCustom(
                          to: uid,
                        ),
                            ));
                      });
            }, child: const Text('Rating')),
          ],
        );
      default:
        return Container();
    }
  }
}
