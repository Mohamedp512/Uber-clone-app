import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:waddiny/custom_dailog.dart';
import 'package:waddiny/models/address.dart';
import 'package:waddiny/models/direction.dart';
import 'package:waddiny/models/near_by_driver.dart';
import 'package:waddiny/screens/home/components/collect_payment.dart';
import 'package:waddiny/screens/home/components/custom_drawer.dart';
import 'package:waddiny/screens/home/components/menu_button.dart';
import 'package:waddiny/screens/search/search_screen.dart';
import 'package:waddiny/services/addressData.dart';
import 'package:waddiny/size_config.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  List<NearByDriver> availableDrivers;
  double mapPadding = 0;
  bool home = false;
  double screenHeight = 0;
  String status = '';
  String carColor = '';
  String carModel = '';
  String driverName = 'Driver';
  String duration = '';
  double tripSheetHeight = 0;
  Position currentPosition;
  double detailContainerHeight = 0;
  double requestingContHeight = 0;
  DirectionDetails tripDetail;
  bool drawerOpen = true;
  bool isRequestingLocationDetails = false;
  Set<Marker> _markers = {};
  StreamSubscription<DocumentSnapshot> rideSubscription;
  String tripStatusDisplay = 'Driver is Arriving';
  String appState = 'Normal';
  double createRandom(int max) {
    var randomGenerator = Random();
    int radInt = randomGenerator.nextInt(max);
    return radInt.toDouble();
  }

  BitmapDescriptor nearByIcon;
  createIcon() {
    if (nearByIcon == null) {
      BitmapDescriptor.fromAssetImage(
              createLocalImageConfiguration(context, size: Size(2, 2)),
              Platform.isIOS
                  ? 'assets/images/car_ios.png'
                  : 'assets/images/car_android.png')
          .then((value) => nearByIcon = value);
    }
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.033333, 31.233334),
    zoom: 14.4746,
  );
  updateDriverOnMap() {
    _markers.clear();

    Set<Marker> tempMarker = Set<Marker>();
    final nearByDriverList =
        Provider.of<AddressData>(context, listen: false).nearByDriverList;
    for (NearByDriver driver in nearByDriverList) {
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
      print(driverPosition.latitude);
      Marker thisMarker = Marker(
          markerId: MarkerId(driver.key),
          position: driverPosition,
          icon: nearByIcon,
          rotation: createRandom(360));
      tempMarker.add(thisMarker);
    }
    setState(() {
      _markers = tempMarker;
    });
  }

  startGeofireListner(double lat, double lng) {
    bool nearByDriverKey = false;
    final nearByDriverList =
        Provider.of<AddressData>(context, listen: false).nearByDriverList;
    Geofire.initialize('driversAvailable');
    Geofire.queryAtLocation(lat, lng, 45).listen((map) {
      print(map);

      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            final nearByDriver = NearByDriver(
              key: map['key'],
              latitude: map['latitude'],
              longitude: map['longitude'],
            );

            nearByDriverList.add(nearByDriver);

            if (nearByDriverKey) {
              //updateDriverOnMap(markers);

            }

            break;

          case Geofire.onKeyExited:
            int index = nearByDriverList
                .indexWhere((element) => element.key == map['key']);
            nearByDriverList.removeAt(index);

            //updateDriverOnMap(markers);

            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            final driver = NearByDriver(
              key: map['key'],
              latitude: map['latitude'],
              longitude: map['longitude'],
            );
            int index = nearByDriverList
                .indexWhere((element) => element.key == driver.key);
            nearByDriverList[index].latitude = driver.latitude;
            nearByDriverList[index].longitude = driver.longitude;

            updateDriverOnMap();

            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            //nearByDriverKey=true;
            //notifyListeners();

            updateDriverOnMap();

            break;
        }
      }
    });
  }

  void getCurrentPosition() async {
    final GoogleMapController mapController = await _controller.future;
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 15);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    //final coordinates=Coordinates(pos.latitude,pos.longitude);

    Provider.of<AddressData>(context, listen: false)
        .getAddress(gPosition: position);
  }

  List<LatLng> polyLinesCoordinates = [];
  Set<Polyline> _polyLines = {};

  Set<Circle> _circles = {};

  @override
  Widget build(BuildContext context) {
    createIcon();
    SizeConfig().init(context);
    void showDetailContainer() {
      setState(() {
        detailContainerHeight = SizeConfig.screenHeight * .32;
        drawerOpen = false;
      });
    }

    void showRquestScreen() async {
      setState(() {
        requestingContHeight = SizeConfig.screenHeight * .32;
        drawerOpen = false;
      });
      Provider.of<AddressData>(context, listen: false)
          .createRideRequest(context);
      String rideId = Provider.of<AddressData>(context, listen: false).rideId;
      DocumentReference rideRef =
          FirebaseFirestore.instance.collection('rideRequest').doc(rideId);

      rideSubscription = rideRef.snapshots().listen((event) async {
        if (event.data() == null) {
          return;
        }

        if (event.data() != null) {
          status = event.data()['status'].toString();
          print(status);
        }
        if (event.data()['carDetails'] != null) {
          setState(() {
            carModel = event.data()['carDetails']['model'];
            carColor = event.data()['carDetails']['color'];
          });
          if (event.data()['driverName'] != null) {
            driverName = event.data()['driverName'];
          }
          if (event.data()['driver_location'] != null) {
            double driverLat = double.parse(
                event.data()['driver_location']['latitude'].toString());
            double driverLng = double.parse(
                event.data()['driver_location']['longitude'].toString());
            LatLng driverLocation = LatLng(driverLat, driverLng);
            if (status == 'accepted') {
              updateToPickup(driverLocation);
            } else if (status == 'ontrip') {
              updateToDestination(driverLocation);
            } else if (status == 'arrived') {
              setState(() {
                tripStatusDisplay = 'Driver has arrived';
              });
            }
          }
        }
        if (status == 'accepted') {
          setState(() {
            requestingContHeight = 0;
            detailContainerHeight = 0;
            tripSheetHeight = SizeConfig.screenHeight * .32;
          });
          Geofire.stopListener();
          setState(() {
            _markers.removeWhere(
                (element) => element.markerId.value.contains('driver'));
          });
        }
        if (status == 'ended') {
          int fares = int.parse(event.data()['fares'].toString());

          var response = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => CollectPayment(
                    fares: fares,
                    paymentMehod: 'cash',
                  ));
          if (response == 'close') {
            String userId = FirebaseAuth.instance.currentUser.uid;
            var result = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
            Map<String, dynamic> data = result.data();

            if (data['payment'] != null) {
              double oldPayment = double.parse(data['payment']);
              var total = (oldPayment + (fares.toDouble())).toString();
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .set({'payment': total}, SetOptions(merge: true));
            } else {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .set({'payment': fares.toString()}, SetOptions(merge: true));
            }

            FirebaseFirestore.instance.collection('users').doc(userId).set({
              'history': {rideId: true}
            }, SetOptions(merge: true));
            rideRef = null;
            rideSubscription.cancel();
            rideSubscription = null;
            resetApp();
          }
        }
      });
    }

    final addressData = Provider.of<AddressData>(context);
    return Scaffold(
      /*  floatingActionButton: FloatingActionButton(
        child: Icon(Icons.logout),
        onPressed: () {
          startGeofireListner(
              currentPosition.latitude, currentPosition.longitude);
        },
      ), */
      drawer: CustomDrawer(),
      key: scaffoldkey,
      body: SafeArea(
        child: Stack(children: [
          GoogleMap(
            mapType: MapType.normal,
            padding: EdgeInsets.only(
              bottom: mapPadding,
            ),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            polylines: _polyLines,
            markers: _markers,
            circles: _circles,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              setState(() {
                mapPadding = SizeConfig.defaultSize * 28;
                screenHeight = SizeConfig.screenHeight * .32;
              });
              await getCurrentPosition();
              if (Provider.of<AddressData>(context, listen: false)
                      .pickupAddress !=
                  null) {
                setState(() {
                  home = true;
                });
              }
              startGeofireListner(
                  currentPosition.latitude, currentPosition.longitude);
            },
          ),
          Positioned(
              top: 44,
              left: 20,
              child: GestureDetector(
                child: CustomMenuButton(
                    icon: drawerOpen ? Icons.menu : Icons.arrow_back),
                onTap: () {
                  drawerOpen
                      ? scaffoldkey.currentState.openDrawer()
                      : resetApp();
                },
              )),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: screenHeight,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.defaultSize * 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: SizeConfig.defaultSize * 1,
                      ),
                      Text('Nice to see you'),
                      Text(
                        'Enter your pickup point',
                        style: TextStyle(
                            fontSize: SizeConfig.defaultSize * 2,
                            fontFamily: 'Brand-Bold'),
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize * 2,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (Provider.of<AddressData>(context, listen: false)
                                  .pickupAddress !=
                              null) {
                            var response = await Navigator.of(context)
                                .pushNamed(SearchScreen.routeName);
                            if (response == 'getDirection') {
                              startGeofireListner(currentPosition.latitude,
                                  currentPosition.longitude);
                              showDetailContainer();

                              Address pickUp = addressData.pickupAddress;

                              MyAddress destination =
                                  addressData.destinationAddress;

                              var pickLatLng = LatLng(
                                  pickUp.coordinates.latitude,
                                  pickUp.coordinates.longitude);

                              var destLatLng = LatLng(
                                  destination.latitude, destination.longitude);
                              /* showDialog(barrierDismissible: false,
                                context: context,
                                builder: (context)=>ProgressIndicator()) */
                              final direction = await addressData.getDirection(
                                  pickLatLng, destLatLng);

                              PolylinePoints polylinePoints = PolylinePoints();
                              List<PointLatLng> result = polylinePoints
                                  .decodePolyline(direction.encodedPoints);
                              setState(() {
                                tripDetail = direction;
                              });
                              polyLinesCoordinates.clear();
                              if (result.isNotEmpty) {
                                result.forEach((PointLatLng point) {
                                  polyLinesCoordinates.add(
                                      LatLng(point.latitude, point.longitude));
                                });
                              }
                              _polyLines.clear();
                              setState(() {
                                Polyline polyline = Polyline(
                                  polylineId: PolylineId('polyline'),
                                  color: Colors.green,
                                  endCap: Cap.roundCap,
                                  points: polyLinesCoordinates,
                                  startCap: Cap.squareCap,
                                  width: 4,
                                  geodesic: true,
                                );
                                _polyLines.add(polyline);
                              });

                              LatLngBounds bounds;
                              if (pickLatLng.latitude > destLatLng.latitude &&
                                  pickLatLng.longitude > destLatLng.longitude) {
                                bounds = LatLngBounds(
                                    southwest: destLatLng,
                                    northeast: pickLatLng);
                              } else if (pickLatLng.longitude >
                                  destLatLng.longitude) {
                                bounds = LatLngBounds(
                                    southwest: LatLng(pickLatLng.latitude,
                                        destLatLng.longitude),
                                    northeast: LatLng(destLatLng.latitude,
                                        pickLatLng.longitude));
                              } else if (pickLatLng.latitude >
                                  destLatLng.latitude) {
                                bounds = LatLngBounds(
                                    southwest: LatLng(destLatLng.latitude,
                                        destLatLng.longitude),
                                    northeast: LatLng(pickLatLng.latitude,
                                        destLatLng.longitude));
                              } else {
                                bounds = LatLngBounds(
                                    southwest: pickLatLng,
                                    northeast: destLatLng);
                              }
                              final GoogleMapController mapController =
                                  await _controller.future;
                              mapController.animateCamera(
                                  CameraUpdate.newLatLngBounds(bounds, 50));
                              Marker pickMarker = Marker(
                                  markerId: MarkerId('pick'),
                                  position: pickLatLng,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueGreen),
                                  infoWindow: InfoWindow(
                                      title: pickUp.addressLine,
                                      snippet: 'My Location'));
                              Marker destMarker = Marker(
                                  markerId: MarkerId('dest'),
                                  position: destLatLng,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueRed),
                                  infoWindow: InfoWindow(
                                      title: destination.placeName,
                                      snippet: 'Destination'));
                              setState(() {
                                _markers.add(pickMarker);
                                _markers.add(destMarker);
                              });
                              Circle pickCircle = Circle(
                                circleId: CircleId('pick'),
                                strokeColor: Colors.green,
                                strokeWidth: 3,
                                radius: 12,
                                fillColor: Colors.green,
                                center: pickLatLng,
                              );
                              Circle destCircle = Circle(
                                circleId: CircleId('dest'),
                                strokeColor: Colors.red,
                                strokeWidth: 3,
                                radius: 12,
                                fillColor: Colors.red,
                                center: destLatLng,
                              );
                              setState(() {
                                _circles.add(pickCircle);
                                _circles.add(destCircle);
                              });
                            }
                          } else {
                            return showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Dialog(
                                        child: Container(
                                          padding: EdgeInsets.all(SizeConfig.defaultSize),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Error',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize:
                                                    SizeConfig.defaultSize * 1.6,
                                                ),
                                          ),
                                          Divider(),
                                          SizedBox(height: SizeConfig.defaultSize*1.5,),
                                          Text(
                                              'Something is going wrong!\nPlease check your connection and try again',textAlign: TextAlign.center,),
                                              SizedBox(height: SizeConfig.defaultSize*1.5,),
                                          Container(
                                            height: SizeConfig.defaultSize*3,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),border: Border.all(color: Colors.black38)),
                                            child: FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('OK'),
                                            ),
                                          )
                                        ],
                                      ),
                                    )));
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: SizeConfig.defaultSize * 4,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0.7, 0.7),
                                  spreadRadius: 0.5,
                                  blurRadius: 5,
                                ),
                              ]),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Search Destination')
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize * 2,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.home_outlined,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Provider.of<AddressData>(context)
                                              .pickupAddress !=
                                          null
                                      ? Provider.of<AddressData>(context)
                                          .pickupAddress
                                          .addressLine
                                      : 'Add Home',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  'your residential address',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Work'),
                              Text(
                                'your residential address',
                                style:
                                    TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize * 1.2,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              child: Container(
                height: detailContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7))
                    ]),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.defaultSize * 1.8),
                  child: Column(
                    children: [
                      Container(
                        color: Colors.green[50],
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.defaultSize * 1.6),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/taxi.png',
                              width: 70,
                              height: 70,
                            ),
                            SizedBox(
                              width: SizeConfig.defaultSize * 1.5,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Taxi',
                                  style: TextStyle(
                                      fontSize: 18, fontFamily: 'Brand-Bold'),
                                ),
                                Text(
                                  tripDetail != null
                                      ? tripDetail.distanceText
                                      : '',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                )
                              ],
                            ),
                            Spacer(),
                            Text(
                              tripDetail != null
                                  ? '\$${addressData.estimateFares(tripDetail)}'
                                  : '',
                              style: TextStyle(
                                  fontSize: 18, fontFamily: 'Brand-Bold'),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize * 2,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyBillAlt,
                              size: 18,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text('Cash'),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(Icons.keyboard_arrow_down_outlined)
                          ],
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize * 2,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: Colors.green[400],
                            borderRadius: BorderRadius.circular(20)),
                        width: double.infinity,
                        child: FlatButton(
                          onPressed: () {
                            setState(() {
                              appState = 'Requesting';
                            });
                            final nearByDriverList =
                                Provider.of<AddressData>(context, listen: false)
                                    .nearByDriverList;
                            showRquestScreen();
                            availableDrivers = nearByDriverList;
                            findDriver();
                            var driver = availableDrivers[0];
                            Provider.of<AddressData>(context, listen: false)
                                .notifyDriver(driver, context);
                            availableDrivers.removeAt(0);
                          },
                          child: Text(
                            'Request cap',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            left: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              child: Container(
                height: requestingContHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0.7, 0.7),
                          spreadRadius: 0.5,
                          blurRadius: 15)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: TextLiquidFill(
                        text: 'Requesting a Ride...',
                        waveColor: Colors.grey,
                        boxBackgroundColor: Colors.white,
                        textStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 22.0,
                          fontFamily: 'Brand-Bold',
                        ),
                        boxHeight: 40,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        //Provider.of<AddressData>(context,listen: false).deletRequest();
                        resetApp();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border:
                                Border.all(width: 1, color: Colors.grey[300])),
                        child: Icon(
                          Icons.close,
                          size: 25,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text('Cancel Ride'),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            left: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              child: Container(
                height: tripSheetHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0.7, 0.7),
                          spreadRadius: 0.5,
                          blurRadius: 15)
                    ]),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: SizeConfig.defaultSize),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: SizeConfig.defaultSize * 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(tripStatusDisplay,
                              style: TextStyle(
                                  fontSize: SizeConfig.defaultSize * 1.8,
                                  fontFamily: 'Brand-Bold')),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize,
                      ),
                      Divider(),
                      SizedBox(
                        height: SizeConfig.defaultSize,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$carColor - $carModel',
                            style: TextStyle(color: Colors.black38),
                          ),
                          Text(
                            driverName,
                            style:
                                TextStyle(fontSize: SizeConfig.defaultSize * 2),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize,
                      ),
                      Divider(),
                      SizedBox(
                        height: SizeConfig.defaultSize,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Container(
                                height: SizeConfig.defaultSize * 5,
                                width: SizeConfig.defaultSize * 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(width: 2),
                                ),
                                child: Icon(Icons.call),
                              ),
                              SizedBox(height: SizeConfig.defaultSize),
                              Text('Call')
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                height: SizeConfig.defaultSize * 5,
                                width: SizeConfig.defaultSize * 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(width: 2),
                                ),
                                child: Icon(Icons.list),
                              ),
                              SizedBox(height: SizeConfig.defaultSize),
                              Text('Details')
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              resetApp();
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: SizeConfig.defaultSize * 5,
                                  width: SizeConfig.defaultSize * 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(width: 2),
                                  ),
                                  child: Icon(Icons.clear),
                                ),
                                SizedBox(height: SizeConfig.defaultSize),
                                Text('Cancel')
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  /* updateDriverOnMap() {
    List<NearByDriver> drivers =
        Provider.of<AddressData>(context, listen: false).nearByDriverList;
    setState(() {
      _markers.clear();
    });
    Set<Marker> tempMarker;
    for (NearByDriver driver in drivers) {
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
      Marker thisMarker = Marker(
          markerId: MarkerId(driver.key),
          position: driverPosition,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          rotation: createRandom(360));
      tempMarker.add(thisMarker);
    }
    setState(() {
      _markers = tempMarker;
    });
  } */

  /* double createRandom(int max) {
    var randomGenerator = Random();
    int radInt = randomGenerator.nextInt(max);
    return radInt.toDouble();
  } */

  resetApp() {
    setState(() {
      _polyLines.clear();
      polyLinesCoordinates.clear();
      _markers.clear();
      _circles.clear();
      detailContainerHeight = 0;
      drawerOpen = true;
      requestingContHeight = 0;
      status = '';
      driverName = '';
      carColor = '';
      carModel = '';
      tripStatusDisplay = '';
      tripSheetHeight = 0;
    });
  }

  noDriverFound() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CustomDialog());
  }

  void findDriver() {
    if (availableDrivers.length == 0) {
      resetApp();
      noDriverFound();
      return;
    }
  }

  void updateToPickup(LatLng driverLocation) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;

      var positionLatLng =
          LatLng(currentPosition.latitude, currentPosition.longitude);

      var thisDetails = await Provider.of<AddressData>(context, listen: false)
          .getDirectionDetails(driverLocation, positionLatLng);

      if (thisDetails == null) {
        return;
      }

      setState(() {
        tripStatusDisplay = 'Driver is Arriving - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;
    }
  }

  void updateToDestination(LatLng driverLocation) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;

      var destination =
          Provider.of<AddressData>(context, listen: false).destinationAddress;

      var destinationLatLng =
          LatLng(destination.latitude, destination.longitude);

      var thisDetails = await Provider.of<AddressData>(context, listen: false)
          .getDirectionDetails(driverLocation, destinationLatLng);

      if (thisDetails == null) {
        return;
      }

      setState(() {
        tripStatusDisplay =
            'Driving to Destination - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;
    }
  }
}
