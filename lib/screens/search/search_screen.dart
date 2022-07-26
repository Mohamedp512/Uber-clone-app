import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waddiny/screens/search/components/custom_iconField.dart';
import 'package:waddiny/screens/search/components/prediction_tile.dart';
import 'package:waddiny/services/addressData.dart';
import 'package:waddiny/size_config.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = 'searchScreen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}
 
class _SearchScreenState extends State<SearchScreen> {
  final pickupController= TextEditingController();
  final destinationController= TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pickupController.dispose();
    destinationController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final addressData=Provider.of<AddressData>(context);
    String address=addressData.pickupAddress.addressLine??'';
    pickupController.text=address!=null?address:'';
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
              child: Column(
          children: [
            Container(
              height: SizeConfig.screenHeight * .28,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                  blurRadius: 5,
                )
              ]),
              child: Padding(
                  padding: EdgeInsets.only(
                      top: SizeConfig.defaultSize * 4,
                      left: SizeConfig.defaultSize * 2,
                      bottom: SizeConfig.defaultSize * 2,
                      right: SizeConfig.defaultSize * 2),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: (){Navigator.pop(context);},
                            child: Icon(Icons.arrow_back)),
                          Center(
                            child: Text(
                              'Set Destination',
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'Brand-Bold'),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize * 2,
                      ),
                      CustomIconField(
                        icon: 'assets/images/pickicon.png',
                        hint: 'Pickup location',
                        controller: pickupController!=null?pickupController:null,
                        focus: false,
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize * 2,
                      ),
                      CustomIconField(
                        change: (value)async{
                          await Provider.of<AddressData>(context,listen: false).searchPlace(value);
                        },
                        icon: 'assets/images/desticon.png',
                        hint: 'Where to',
                        controller: destinationController,
                        focus: true,
                      )
                    ],
                  )),
            ),
            addressData.predictionList.length>0?
            ListView.separated(
              itemCount: addressData.predictionList.length,
              itemBuilder: (context,index)=>PredictionTile(
                placeId: addressData.predictionList[index].placeId,
                mainText: addressData.predictionList[index].mainText !=null?addressData.predictionList[index].mainText:'',
                secondaryText: addressData.predictionList[index].secondaryText,
              ),
              separatorBuilder: (context,index)=>Divider(),
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
            ):Container()          
          ],
        ),
      ),
    );
  }
}
