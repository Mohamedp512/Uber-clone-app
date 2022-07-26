import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:waddiny/constants.dart';
import 'package:waddiny/models/address.dart';
import 'package:waddiny/models/direction.dart';
import 'package:waddiny/models/near_by_driver.dart';
import 'package:waddiny/models/prediction.dart';
import 'package:waddiny/models/user.dart';
import 'auth.dart';

class AddressData extends ChangeNotifier {
  Address pickupAddress;
  MyAddress destinationAddress;
  List<Prediction> _predictionList = [];
  List<NearByDriver> _nearByDriverList = [];
  String rideId;
  String token;
  int driverRequestTimeout = 30;

  List<Prediction> get predictionList {
    return _predictionList;
  }

  List<NearByDriver> get nearByDriverList {
    return _nearByDriverList;
  }

  Future<DirectionDetails> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&key=$apiKey';
    try {
      final response = await http.get(url);
      print('result');
      final data = json.decode(response.body) as Map<String, dynamic>;
      DirectionDetails directionDetails = DirectionDetails();
      directionDetails.distanceText =
          data['routes'][0]['legs'][0]['distance']['text'];
      print('one');
      directionDetails.distanceValue =
          data['routes'][0]['legs'][0]['distance']['value'];
      print('first step');
      directionDetails.durationText =
          data['routes'][0]['legs'][0]['duration']['text'];
      directionDetails.durationValue =
          data['routes'][0]['legs'][0]['duration']['value'];
      print('second');
      directionDetails.encodedPoints =
          data['routes'][0]['overview_polyline']['points'];

      return directionDetails;
    } catch (e) {
      print(e);
    }
  }

  Future<String> getAddress({Position gPosition}) async {
    final coordinates = Coordinates(gPosition.latitude, gPosition.longitude);
    final address =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final first = address.first;
    pickupAddress = first;
    notifyListeners();
    String placeAdress = '${first.addressLine} ';
    return placeAdress;
  }

  void updatePickupAddress(Address pickUp) {
    pickupAddress = pickUp;
    notifyListeners();
  }

  Future<void> getAddressFromQuery(String query) async {
    final addresses = await Geocoder.local.findAddressesFromQuery(query);
    for (var a in addresses) {
      print(a.addressLine);
    }
  }

  Future<void> searchPlace(String place) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$place&key=$apiKey&sessiontoken=1234567890';
    try {
      if (place.length > 1) {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data['status'] == 'OK') {
            final List preds = data['predictions'];
            print('done');
            final List predList =
                preds.map((e) => Prediction.fromJson(e)).toList();
            print('predssss:$predList');
            _predictionList = predList;
            notifyListeners();
            print(predictionList.length);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getPlaceDeails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'OK') {
        final MyAddress thisPlace = MyAddress();
        thisPlace.placeId = placeId;
        thisPlace.placeName = data['result']['name'];
        thisPlace.latitude = data['result']['geometry']['location']['lat'];
        thisPlace.longitude = data['result']['geometry']['location']['lng'];
        destinationAddress = thisPlace;

        notifyListeners();
      }
    } catch (error) {
      print(error);
    }
  }

  Future<DirectionDetails> getDirection(
      LatLng startPosition, LatLng endPosition) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&key=$apiKey';
    try {
      final response = await http.get(url);
      print('result');
      final data = json.decode(response.body) as Map<String, dynamic>;
      DirectionDetails directionDetails = DirectionDetails();
      directionDetails.distanceText =
          data['routes'][0]['legs'][0]['distance']['text'];
      directionDetails.distanceValue =
          data['routes'][0]['legs'][0]['distance']['value'];
      directionDetails.durationText =
          data['routes'][0]['legs'][0]['duration']['text'];
      directionDetails.durationValue =
          data['routes'][0]['legs'][0]['duration']['value'];

      directionDetails.encodedPoints =
          data['routes'][0]['overview_polyline']['points'];

      return directionDetails;
    } catch (e) {
      print(e);
    }
  }

  int estimateFares(DirectionDetails detail) {
    double baseFare = 3;
    double distanceFare = (detail.distanceValue / 1000) * 0.7;
    double timeFare = (detail.durationValue / 60) * 0.2;

    double totalFare = baseFare + distanceFare + timeFare;
    return totalFare.truncate();
  }

  Future<void> createRideRequest(BuildContext context) async {
    await Provider.of<Auth>(context, listen: false).getUserInfo();
    CustomUser user =
        await Provider.of<Auth>(context, listen: false).currentUser;
    var userId = FirebaseAuth.instance.currentUser.uid;
    Map pickUpMap = {
      'latitude': pickupAddress.coordinates.latitude,
      'longitude': pickupAddress.coordinates.longitude
    };
    Map destinationMap = {
      'latitude': destinationAddress.latitude,
      'longitude': destinationAddress.longitude
    };
    CollectionReference rideRef =
        FirebaseFirestore.instance.collection('rideRequest');
    try {
      rideRef.add({
        'createdAt': DateTime.now().toString(),
        'riderName': user.fullName,
        'riderPhone': user.phone,
        'riderId': userId,
        'pickupAddress': pickupAddress.addressLine,
        'destinationAddress': destinationAddress.placeName,
        'location': pickUpMap,
        'destination': destinationMap,
        'paymentMethod': 'card',
        'driverName': 'waiting',
        'status': 'waiting'
      }).then((value) {
        (rideId = value.id);
        //FirebaseFirestore.instance.collection('users').doc(userId).set({'history':{rideId:'pending'}},SetOptions(merge: true));
      });

      //  rideId = rideRef.doc().id;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void deletRequest() {
    CollectionReference rideRef =
        FirebaseFirestore.instance.collection('rideRequest');
    try {
      rideRef.doc(rideId).delete();
    } catch (e) {
      print(e);
    }
  }

  /* void startGeofireListner(double lat, double lng, Set<Marker>markers) {
    bool nearByDriverKey = false;
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

            _nearByDriverList.add(nearByDriver);
            notifyListeners();
            if(nearByDriverKey){
              //updateDriverOnMap(markers);
              print('Lasssssssssssssssst11:${markers.length}');
            }
            
            
            break;

          case Geofire.onKeyExited:
            int index = _nearByDriverList
                .indexWhere((element) => element.key == map['key']);
            _nearByDriverList.removeAt(index);
            notifyListeners();
            //updateDriverOnMap(markers);
            print('Lasssssssssssssssst22:${markers.length}');

            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            final driver = NearByDriver(
              key: map['key'],
              latitude: map['latitude'],
              longitude: map['longitude'],
            );
            int index=_nearByDriverList
                .indexWhere((element) => element.key == driver.key);
            _nearByDriverList[index].latitude=driver.latitude;
            _nearByDriverList[index].longitude=driver.longitude;            
            notifyListeners();
            updateDriverOnMap(markers: markers);
            print('Lasssssssssssssssst33:${markers.length}');
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            //nearByDriverKey=true;
            //notifyListeners();
            print('Lasssssssssssssssst0000000:${markers.length}');
            updateDriverOnMap(markers: markers);
            print('Lasssssssssssssssst:${markers.length}');        
            notifyListeners();
            print('lenght:${nearByDriverList.length}');
            print(map['result']);

            break;
        }
      }
    });
  }

  updateDriverOnMap({Set<Marker> markers}) {
    
    markers.clear();
    /* setState(() {
      _markers.clear();
    }); */
    Set<Marker> tempMarker=Set<Marker>();
    print('lenghtttttttttt:${nearByDriverList.length}');
    for (NearByDriver driver in _nearByDriverList) {
      print('driverssssssssssssss:$driver');
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
      print(driverPosition.latitude);
      Marker thisMarker = Marker(
          markerId: MarkerId(driver.key),
          position: driverPosition,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          rotation: createRandom(360));
          tempMarker.add(thisMarker);
          print('Markersssss:${tempMarker.length}');
    }
    markers=tempMarker;
    print('Lassssssssssssssssttttttt:${markers.length}');  
  }

  double createRandom(int max) {
    var randomGenerator = Random();
    int radInt = randomGenerator.nextInt(max);
    return radInt.toDouble();
  }
 */
  notifyDriver(NearByDriver driver, BuildContext ctx) async {
    //DocumentReference riderRef=FirebaseFirestore.instance.collection('user').doc()
    DocumentReference driverRef =
        FirebaseFirestore.instance.collection('drivers').doc(driver.key);
    driverRef.update({'newTrip': rideId});
    DocumentSnapshot driverData = await driverRef.get();
    if (driverData != null) {
      String driverToken = driverData.data()['token'];
      token = driverToken;
      notifyListeners();
      //sendAndRetrieveMessage(token, rideId);
      sendNotification(
        token,
        rideId,
      );
    } else {
      return;
    }
    const oneSecTick = Duration(seconds: 1);
    var timer = Timer.periodic(oneSecTick, (timer) {
      driverRequestTimeout--;
      if (driverRequestTimeout == 0) {
        driverRef.update({'newTrip': 'timeout'});
        driverRequestTimeout = 30;
        timer.cancel();
      }
    });
  }

  sendNotification(
    String token,
    String ride,
  ) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': serverKey,
    };

    Map notificationMap = {
      'title': 'NEW TRIP REQUEST',
      'body': 'Destination,${destinationAddress.placeName}'
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_id': ride,
    };

    Map bodyMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token
    };
    var response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: headers,
      body: jsonEncode(bodyMap),
    );
    print(response.body);

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }

  Future<Map<String, dynamic>> sendAndRetrieveMessage(
      String token, String ride) async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    Map notificationMap = {
      'title': 'NEW TRIP REQUEST',
      'body': 'Destination,${destinationAddress.placeName}'
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'rideId': ride
    };

    Map bodyMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token
    };
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': serverKey,
      },
      body: jsonEncode(bodyMap),
    );

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }
}
