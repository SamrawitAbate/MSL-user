import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/services/database.dart';
import 'package:user/widgets/loading.dart';
import 'package:user/widgets/showAlertialog.dart';

String? _mapStyle;

class MapPage extends StatefulWidget {
  const MapPage({Key? key, required this.position}) : super(key: key);
  final LatLng position;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Stream<QuerySnapshot>? _iC;
  final Completer<GoogleMapController> _mapController = Completer();
  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/file/mapstyle.txt').then((string) {
      _mapStyle = string;
    });
    _iC = FirebaseFirestore.instance
        .collection('maintenanceLocations')
        .orderBy('lastLocation')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _iC,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Loading();
          }
          return Stack(
            children: [
              StoreMap(
                  documents: snapshot.data!.docs,
                  initialPosition: widget.position,
                  mapController: _mapController),
              StoreCaeousel(
                  position: widget.position,
                  documents: snapshot.data!.docs,
                  mapController: _mapController),
            ],
          );
        });
  }
}

class StoreCaeousel extends StatefulWidget {
  const StoreCaeousel(
      {Key? key,
      required this.position,
      required this.documents,
      required this.mapController})
      : super(key: key);

  final List<DocumentSnapshot> documents;
  final LatLng position;
  final Completer<GoogleMapController> mapController;

  @override
  State<StoreCaeousel> createState() => _StoreCaeouselState();
}

class _StoreCaeouselState extends State<StoreCaeousel> {
  List<DocumentSnapshot> destinationlist = [];
  List<DocumentSnapshot>? documents;
  Completer<GoogleMapController>? mapController;
  @override
  void initState() {
    super.initState();
    documents = widget.documents;
    mapController = widget.mapController;
    distanceCalculation(widget.position);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
              height: 120,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.documents.length,
                  itemBuilder: (context, index) {
                    debugPrint('*-*' * 8);
                    debugPrint(destinationlist.toString());
                    return destinationlist.isEmpty
                        ? const SizedBox()
                        : SizedBox(
                            width: 340,
                            child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Card(
                                    child: Center(
                                        child: StoreListTile(
                                            position: widget.position,
                                            document: destinationlist[index],
                                            // document: widget.documents[index],
                                            mapController:
                                                widget.mapController)))));
                  })),
        ));
  }

  distanceCalculation(LatLng position) {
    debugPrint('**--**..' * 8);
    for (var d in documents!) {
      debugPrint('**--**' * 8);
      debugPrint(d['location'].latitude.toString());
      var m = Geolocator.distanceBetween(position.latitude, position.longitude,
          d['location'].latitude, d['location'].longitude);
      d['distance'] != m / 1000;
      destinationlist.add(d);
    }
    setState(() {
      destinationlist.sort((a, b) {
        return a['distance'].compareTo(b['distance']);
      });
    });
  }
}

class StoreListTile extends StatefulWidget {
  const StoreListTile(
      {Key? key,
      required this.document,
      required this.position,
      required this.mapController})
      : super(key: key);
  final DocumentSnapshot document;
  final Completer<GoogleMapController> mapController;
  final LatLng position;
  @override
  _StoreListTileState createState() => _StoreListTileState();
}

class _StoreListTileState extends State<StoreListTile> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.document['name']),
      subtitle: Text(widget.document['skill']),
      trailing: IconButton(
        icon: const Icon(Icons.handyman),
        onPressed: () async {
          List v = popUp(context, 'Jop Description');
          if (v[1]) {
            bool sent=sendRequest(widget.document.id,v[0],
                GeoPoint(
                    widget.position.latitude, widget.position.longitude)) as bool;
            if(sent){
               ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Request Sent')));
            }
          }
        },
      ),
      onTap: () async {
        final controller = await widget.mapController.future;
        await controller
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(
                  widget.document['location'].latitude,
                  widget.document['location'].longitude,
                ),
                zoom: 19,
                tilt: 45)));
      },
    );
  }
}

class StoreMap extends StatelessWidget {
  const StoreMap(
      {Key? key,
      required this.documents,
      required this.mapController,
      required this.initialPosition})
      : super(key: key);
  final List<DocumentSnapshot> documents;
  final LatLng initialPosition;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 17,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      compassEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      markers: documents
          .map((document) => Marker(
              markerId: MarkerId(document.id),
              position: LatLng(document['location'].latitude,
                  document['location'].longitude),
              infoWindow: InfoWindow(
                  title: document['name'], snippet: document['skill'])))
          .toSet(),
      onMapCreated: (mapController) {
        this.mapController.complete(mapController);
        mapController.setMapStyle(_mapStyle);
      },
    );
  }
}
