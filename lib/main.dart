import 'package:flutter/material.dart';
import 'package:flutter_gmaps/directions_model.dart';
import 'package:flutter_gmaps/directions_repository.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

   double latitudeData ;
   double longitudeData ;
   var initialCameraPosition;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    final geoPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


    setState(() {
      latitudeData = geoPosition.latitude;
      longitudeData = geoPosition.longitude;
      print('latitudeData $latitudeData');
      print('longitudeData $longitudeData');
      initialCameraPosition = CameraPosition(
        target: LatLng(latitudeData,longitudeData),
        zoom: 11.5,
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Google Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home:
      HomeScreen(),
      // MapScreen(latitudeData: latitudeData,longitudeData: longitudeData,initialCameraPosition: initialCameraPosition,),
    );
  }
}






class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          TextField(),
          Container(
            height: 300,
            child: GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(target: LatLng(8.7642, 78.1348))),
          )
        ],
      ),
    );
  }
}






























class MapScreen extends StatefulWidget {
 final double latitudeData ;
  final double longitudeData ;
  final CameraPosition initialCameraPosition;

  const MapScreen({Key key, this.latitudeData, this.longitudeData, this.initialCameraPosition}) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {


  GoogleMapController _googleMapController;
  Marker _origin;
  Marker _destination;
  Directions _info;



  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Google Maps'),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.pink,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('Origin'),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('Destination'),
            )
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          widget.initialCameraPosition != null ?
          GoogleMap(myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition:  widget.initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (_origin != null) _origin,
              if (_destination != null) _destination
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 3,
                  points: _info.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
            onLongPress: _addMarker,
          ) : Center(child: SpinKitWave(color: Colors.blue,size: 100,)),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info.totalDistance}, ${_info.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,color: Colors.white
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          _info != null
              ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
              : CameraUpdate.newCameraPosition(widget.initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      setState(() {
        Get.snackbar('Origin', 'Origin Set Successfully',snackPosition: SnackPosition.BOTTOM,colorText: Colors.pinkAccent);
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
          position: pos,
        );
        // Reset destination
        _destination = null;

        // Reset info
        _info = null;
      });
    } else {
      // Origin is already set
      // Set destination
      setState(() {
        Get.snackbar('Destination', 'Destination Set Successfully',snackPosition: SnackPosition.BOTTOM,colorText: Colors.blue);

        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          position: pos,
        );
        Get.snackbar('Ride Started', 'Happy Ride 😊',snackPosition: SnackPosition.TOP,colorText: Colors.deepOrange,duration: Duration(seconds: 5));

      });

      // Get directions
      final directions = await DirectionsRepository()
          .getDirections(origin: _origin.position, destination: pos);
      setState(() {
        _info = directions;
        print('directions check the directions right now ${directions}');
        print('Orgin position check${_origin.position}');
        print('Pos check ${pos}');
      });
    }
  }
}


