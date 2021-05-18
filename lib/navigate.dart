import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class NavigateApp extends StatefulWidget {
  @override
  _NavigateAppState createState() => _NavigateAppState();
}

class _NavigateAppState extends State<NavigateApp> {
  final Set<Marker> _markers = {};
  static const LatLng _center = const LatLng(26.8921959, 75.8132034);
  LatLng _newLoc;

  MapType _currentMapType = MapType.normal;
  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _gpsLocator() async {
    var p = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    setState(() {
      _newLoc = LatLng(p.latitude, p.longitude);
    });
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _newLoc, zoom: 18.0, tilt: 18),
      ),
    );
    // print(_newLoc.toString());
  }

  @override
  void initState() {
    super.initState();
    _newLoc = _center;
    _gpsLocator();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cp = CameraPosition(
      target: _center,
      tilt: 18,
      zoom: 17.0,
    );
    return Stack(
      children: [
        GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: _currentMapType,
          initialCameraPosition: cp,
          onMapCreated: _onMapCreated,
          markers: _markers,
          onTap: (LatLng pos) {
            mapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: pos, zoom: 18)));
            setState(() {
              _markers.add(Marker(
                markerId: MarkerId(pos.toString()),
                position: pos,
              ));
            });
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  margin: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "This place is located at:",
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).textScaleFactor * 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Latitude:  " + pos.latitude.toString(),
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).textScaleFactor *
                                        18)),
                        Text("Longitude: " + pos.longitude.toString(),
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).textScaleFactor *
                                        18)),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("OK"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        // GPS Locator
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.topRight,
            child: FloatingActionButton(
              child: Icon(Icons.gps_fixed_sharp),
              onPressed: () {
                _gpsLocator();
              },
            ),
          ),
        ),
        // Extra Icon Buttons
        Padding(
          padding: EdgeInsets.fromLTRB(
              MediaQuery.of(context).textScaleFactor * 12,
              0,
              0,
              MediaQuery.of(context).textScaleFactor * 30),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  tooltip: "change Map Type",
                  onPressed: _onMapTypeButtonPressed,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.map, size: 36.0),
                ),
                SizedBox(height: 8.0),
                FloatingActionButton(
                  tooltip: 'clear markers',
                  child: Icon(Icons.layers_clear_outlined, size: 36.0),
                  onPressed: () => setState(() {
                    _markers.clear();
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
