import 'dart:async';
import 'package:CitizenIO/Model/Locator.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Database/DbManager.dart';

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  Completer<GoogleMapController> mapController = Completer();
  LatLng currentPosition = LatLng(12.9764, 77.5929);
  Set<Marker> markers = {};
  MapType mapType = MapType.satellite;
  double currentZoom = 15;
  LatLng dbMarker;

  @override
  void initState() {
    super.initState();
    setCurrentPosition();
  }

  void setCurrentPosition() async {
    Locator locator = Locator();
    Position pos = await locator.getCurrentPosition();
    setState(() {
      currentPosition = LatLng(pos.latitude, pos.longitude);
      dbMarker = currentPosition;
    });
  }

  void onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
    setCurrentPosition();
  }

  void onCameraMove(CameraPosition position) {
    currentPosition = position.target;
  }

  void onMapTapped(LatLng position) {
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId(
          LatLng(position.latitude, position.longitude).toString(),
        ),
        position: position,
      ),
    );
    setState(() {
      dbMarker = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onTap: onMapTapped,
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: currentPosition,
                zoom: currentZoom,
              ),
              mapType: mapType,
              markers: markers,
              onCameraMove: onCameraMove,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  height: 50,
                  child: Opacity(
                    opacity: 0.92,
                    child: FlatButton(
                      onPressed: () async {
                        GeoPoint geopoint =
                            GeoPoint(dbMarker.latitude, dbMarker.longitude);
                        print("Geopoint is $geopoint");
                        DatabaseManager manager = DatabaseManager();
                        await manager.updateLocation(geopoint);
                        Navigator.of(context).pop();
                      },
                      color: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Confirm Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nexa',
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
