// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:user/services/database.dart';
import 'package:user/widgets/loading.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ListFile extends StatelessWidget {
  const ListFile({Key? key, required this.dir, required this.id})
      : super(key: key);
  final String dir, id;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: listFiles(dir, id),
        builder: (BuildContext context,
            AsyncSnapshot<firebase_storage.ListResult> snapshot) {
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
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.items.length,
                  itemBuilder: (BuildContext context, int index) {
                    firebase_storage.Reference ref =
                        snapshot.data!.items[index];
                    return OutlinedButton(
                        onPressed: () async {
                          try {
                            final dir =
                                await getApplicationDocumentsDirectory();
                            final file = File('${dir.path}/${ref.name}');
                            await ref.writeToFile(file);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Downloaded ${ref.name}')));
                            OpenFile.open(file.path);
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        },
                        child: Text(
                          snapshot.data!.items[index].name,
                          style: const TextStyle(fontSize: 18),
                        ));
                  }),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const Loading();
          }
          return Container();
        });
  }
}
