import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:realtime_locator/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GM())),
          child: const Text('Maps'),
        ),
      ),
    );
  }
}

class GM extends StatefulWidget {
  const GM({Key? key}) : super(key: key);

  @override
  State<GM> createState() => _GMState();
}

class _GMState extends State<GM> {
  final Completer<GoogleMapController> _controller = Completer();

  List<LatLng> polyLineList = [];
  LocationData? currentLocation;
  final LatLng src = const LatLng(37.33500926, -122.03272188);
  final LatLng tgt = const LatLng(37.33429383, -122.06600055);

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then((value) => currentLocation = value);
    GoogleMapController controller = await _controller.future;

    location.onLocationChanged.listen((event) {
      currentLocation = event;
      controller.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(
                zoom: 13.5,
                  target: LatLng(event.latitude!, event.longitude!),
              ),
          ),
      );
      setState(() {});
    });
  }

  void getPolyLinePoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      const PointLatLng(37.33500926, -122.03272188),
      const PointLatLng(37.33429383, -122.06600055),
    );

    if(result.points.isNotEmpty){
      result.points.forEach(
            (PointLatLng point) => polyLineList.add(LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }


  @override
  void initState() {
    getPolyLinePoints();
    getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: getPolyLinePoints, icon: const Icon(Icons.local_fire_department_sharp))
        ],
      ),
      body: Center(
        child: GoogleMap(
          polylines: {
            Polyline(
              polylineId: const PolylineId('route'),
              points: polyLineList,
              color: Colors.red,
              width: 6
            )
          },
          markers: {
            Marker(markerId: const MarkerId('source'), position: src),
            Marker(markerId: const MarkerId('destination'), position: tgt),
            currentLocation == null ? const Marker(markerId: MarkerId('null')) : Marker(markerId: const MarkerId('currentLocation'), position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!)),
          },
          initialCameraPosition: CameraPosition(
            target: src,
            zoom: 13.0,
          ),
          onMapCreated: (ctrl){
            _controller.complete(ctrl);
          },
        ),
      ),
    );
  }
}
