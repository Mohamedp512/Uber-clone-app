import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waddiny/models/history.dart';
import 'package:waddiny/screens/history/components/history_listile.dart';
import 'package:waddiny/size_config.dart';

class RideHistory extends StatefulWidget {
  @override
  _RideHistoryState createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  String payment = '0';
  bool isLoading;
  String trips = '';
  List<String> historyKeys = [];
  List<History> historyList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // isLoading=true;
    getEarnings();
    //isLoading=false;
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
      setState(() {
        
          isLoading=false;
       

        payment = pay;
      });
    }
    if (tripsCount != null) {
      tripsCount.forEach((key, value) {
        historyKeys.add(key);
      });
      setState(() {
        trips = tripsCount.length.toString();
      });
    }
    updateistory();
    
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
    setState(() {
          isLoading=false;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1B2842),
        title: Text('History'),
      ),
      body: isLoading
          ? Dialog(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.defaultSize),
                height: SizeConfig.defaultSize*5,
                child: Row(mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      width: SizeConfig.defaultSize,
                    ),
                    Text('Loading...')
                  ],
                ),
              ),
            )
          : ListView.separated(
              itemBuilder: (context, index) => HistoryListile(history: historyList[index],),
              separatorBuilder: (context, index) => Divider(),
              itemCount: historyList.length),
    );
  }
}
