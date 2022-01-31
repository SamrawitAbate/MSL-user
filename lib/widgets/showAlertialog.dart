// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user/services/database.dart';

popUp(
  BuildContext context,
  String lable, {
  String? id,
  GeoPoint? loc,
}) {
  TextEditingController valueController = TextEditingController();
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: valueController,
                    decoration: InputDecoration(labelText: lable),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: const Text("Send"),
                    onPressed: () {
                      if (lable == 'Jop Description') {
                        sendRequest(id!, valueController.text, loc!)
                            .then((value) {
                          if (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request Sent')));
                          }
                        });
                      } else if (lable == 'Complain') {
                        giveComplain(valueController.text, id!).then((value) {
                          if (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Complain Sent')));
                          }
                        });
                      } else if (lable == 'Comment') {
                        giveComment(valueController.text, id!).then((value) {
                          if (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Comment Sent')));
                          }
                        });
                      }
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      });
  return;
}
