import 'dart:async';
import 'package:CitizenIO/Model/Project.dart';
import 'package:CitizenIO/Screens/ProjectDisplay.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DisplayMapView extends StatefulWidget {
  DisplayMapView({@required this.goto, @required this.project});

  final LatLng goto;
  final Project project;

  @override
  _DisplayMapViewState createState() => _DisplayMapViewState();
}

class _DisplayMapViewState extends State<DisplayMapView> {
  Completer<GoogleMapController> mapController = Completer();
  LatLng currentPosition;
  Set<Marker> markers = {};
  MapType mapType = MapType.normal;
  double currentZoom = 10.0;

  @override
  void initState() {
    super.initState();
    setCurrentPosition();
  }

  void setCurrentPosition() async {
    setState(() {
      currentPosition = widget.goto;
      currentZoom = 15.0;
    });
    addMarker(widget.project);
  }

  void onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  }

  void onCameraMove(CameraPosition position) {
    currentPosition = position.target;
  }

  void addMarker(Project project) {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(
            LatLng(project.location.latitude, project.location.longitude)
                .toString(),
          ),
          position:
              LatLng(project.location.latitude, project.location.longitude),
          infoWindow: InfoWindow(
            title: project.headline,
            snippet: project.startDate.toDate().toString().substring(0, 10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectDisplay(project: project),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentPosition,
              zoom: currentZoom,
            ),
            mapType: mapType,
            markers: markers,
            onCameraMove: onCameraMove,
          )
        ],
      ),
    );
  }
}
