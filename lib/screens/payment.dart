import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waddiny/models/history.dart';
import 'package:waddiny/screens/history/ride_history.dart';
import 'package:waddiny/size_config.dart';

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String payment = '0';
  String trips = '';
  List<String> historyKeys = [];
  List<History> historyList = [];
  bool isLoading;  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEarnings();
  }
  Future<String> getEarnings() async {
    
    setState(() {
          isLoading=true;
        });
    String userId = FirebaseAuth.instance.currentUser.uid;
    var result =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    var pay = result.data()['payment'].toString();
    Map<String, dynamic> tripsCount = result.data()['history'];
    if (pay != null) {
      if(pay!='null'){
        setState(() {
        
          isLoading=false;
          
         payment = pay;
      });
      }
      
      print(payment);
    }
    if (tripsCount != null) {
      tripsCount.forEach((key, value) {
        historyKeys.add(key);
      });
      setState(() {
        trips = tripsCount.length.toString();
      });
    }
//updateistory();
    
  }
  updateistory() async {
    for (String key in historyKeys) {
      var historyRef = await FirebaseFirestore.instance
          .collection('rideRequest')
          .doc(key)
          .get();
      var value = historyRef.data();
      historyList.add(History(
          fares: value['fares'],
          createdAt: value['createdAt'],
          pickUp: value['pickupAddress'],
          paymentMethod: value['paymentMethod'],
          destination: value['destinationAddress'],
          status: value['status']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1B2842),
        elevation: 0,
        title: Text("Payment"),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: SizeConfig.screenHeight / 3,
            color: Color(0xff1B2842),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Text(payment=='null'?'0':
              '\$ $payment',
              style: TextStyle(
                  color: Colors.white, fontSize: SizeConfig.defaultSize * 4),
            ),
              ],
            ),
          ),
          FlatButton(
          onPressed: ()async {
            await updateistory();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RideHistory()));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.defaultSize,
                vertical: SizeConfig.defaultSize),
            child: Row(children: [
              Image.asset(
                'assets/images/taxi.png',
                width: SizeConfig.defaultSize * 7,
              ),
              SizedBox(
                width: SizeConfig.defaultSize * 1.6,
              ),
              Text(
                'Trips',
                style: TextStyle(fontSize: SizeConfig.defaultSize * 1.6),
              ),
              Spacer(),
              Text(
                trips,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: SizeConfig.defaultSize * 1.8),
              )
            ]),
          )),
          Divider()
        ],
      ),
    );
  }
}
