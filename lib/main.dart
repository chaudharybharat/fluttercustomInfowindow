import 'dart:io';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:clippy_flutter/clippy_flutter.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => InfoWindowModel(),
      child: MyApp(),
    ),
  );
}

class User {
  final int rating;
  final String username;
  final String name;
  final String image;
  final LatLng location;

  User(
    this.username,
    this.name,
    this.image,
    this.location,
    this.rating,
  );
}

class InfoWindowModel extends ChangeNotifier {
  bool _showInfoWindow = false;
  bool _tempHidden = false;
  User _user;
  double _leftMargin;
  double _topMargin;

  void rebuildInfoWindow() {
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
  }

  void updateVisibility(bool visibility) {
    _showInfoWindow = visibility;
  }

  void updateInfoWindow(
    BuildContext context,
    GoogleMapController controller,
    LatLng location,
    double infoWindowWidth,
    double markerOffset,
  ) async {
    ScreenCoordinate screenCoordinate =
        await controller.getScreenCoordinate(location);
    double devicePixelRatio =
        Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;
    double left = (screenCoordinate.x.toDouble() / devicePixelRatio) -
        (infoWindowWidth / 2);
    double top =
        (screenCoordinate.y.toDouble() / devicePixelRatio) - markerOffset;
    if (left < 0 || top < 0) {
      _tempHidden = true;
    } else {
      _tempHidden = false;
      _leftMargin = left;
      _topMargin = top;
    }
  }

  bool get showInfoWindow =>
      (_showInfoWindow == true && _tempHidden == false) ? true : false;

  double get leftMargin => _leftMargin;

  double get topMargin => _topMargin;

  User get user => _user;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomInfoWindow(),
    );
  }
}

class CustomInfoWindow extends StatefulWidget {
  @override
  _CustomInfoWindowState createState() => _CustomInfoWindowState();
}

class _CustomInfoWindowState extends State<CustomInfoWindow> {
  GoogleMapController mapController;

  final LatLng _center = LatLng(28.7041, 77.1025);
  final double _zoom = 15.0;

  final Map<String, User> _userList = {
    "joker": User(
      "Savvient",
      "Savvient",
      "https://cdn.pixabay.com/photo/2019/10/09/10/07/joker-4536980_960_720.jpg",
      LatLng(28.7041, 77.1025),
      4,
    ),
    "batman": User(
      "batman",
      "Batman",
      "https://cdn.pixabay.com/photo/2017/03/18/15/45/face-2154312_960_720.jpg",
      LatLng(28.7131, 77.1035),
      5,
    )
  };

  final double _infoWindowWidth = 250;
  final double _markerOffset = 170;

  Set<Marker> _markers = Set<Marker>();

  @override
  Widget build(BuildContext context) {
    final providerObject = Provider.of<InfoWindowModel>(context, listen: false);
    _userList.forEach(
      (k, v) => _markers.add(
        Marker(
          markerId: MarkerId(v.username),
          position: v.location,
          onTap: () {
            providerObject.updateInfoWindow(
              context,
              mapController,
              v.location,
              _infoWindowWidth,
              _markerOffset,
            );
            providerObject.updateUser(v);
            providerObject.updateVisibility(true);
            providerObject.rebuildInfoWindow();
          },
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps Custom InfoWindow'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: Consumer<InfoWindowModel>(
          builder: (context, model, child) {
            return Stack(
              children: <Widget>[
                child,
                Positioned(
                  left: 0,
                  top: 0,
                  child: Visibility(
                    visible: providerObject.showInfoWindow,
                    child: (providerObject.user == null ||
                            !providerObject.showInfoWindow)
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(
                              left: providerObject.leftMargin,
                              top: providerObject.topMargin,
                            ),
                            // Custom InfoWindow Widget starts here
                            child: Column(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: new LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Color(0xffffe6cc),
                                      ],
                                      end: Alignment.bottomCenter,
                                      begin: Alignment.topCenter,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0),
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  height: 100,
                                  width: 250,
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Image.network(
                                        providerObject.user.image,
                                        height: 75,
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Text(
                                            providerObject.user.name,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black45,
                                            ),
                                          ),
                                          IconTheme(
                                            data: IconThemeData(
                                              color: Colors.red,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: List.generate(
                                                5,
                                                (index) {
                                                  return Icon(
                                                    index <
                                                            providerObject
                                                                .user.rating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Triangle.isosceles(
                                  edge: Edge.BOTTOM,
                                  child: Container(
                                    color: Color(0xffffe6cc),
                                    width: 20.0,
                                    height: 15.0,
                                  ),
                                ),
                              ],
                            ),
                            // Custom InfoWindow Widget ends here
                          ),
                  ),
                ),
              ],
            );
          },
          child: Positioned(
            child: GoogleMap(
              onTap: (position) {
                if (providerObject.showInfoWindow) {
                  providerObject.updateVisibility(false);
                  providerObject.rebuildInfoWindow();
                }
              },
              onCameraMove: (position) {
                if (providerObject.user != null) {
                  providerObject.updateInfoWindow(
                    context,
                    mapController,
                    providerObject.user.location,
                    _infoWindowWidth,
                    _markerOffset,
                  );
                  providerObject.rebuildInfoWindow();
                }
              },
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: _zoom,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
