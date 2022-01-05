import 'package:flutter/material.dart';



popUp(BuildContext context, String lable) {
  String value;
  bool onPressed = false;
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
                      onPressed = true;
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      });
  value = valueController.text;
  return [value, onPressed];
}
