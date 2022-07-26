import 'package:flutter/material.dart';
import 'package:waddiny/screens/about.dart';
import 'package:waddiny/screens/history/ride_history.dart';
import 'package:waddiny/screens/payment.dart';
import 'package:waddiny/screens/support.dart';
import 'package:waddiny/size_config.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.zero,
              color: Colors.white,
              height: SizeConfig.defaultSize * 16,
              child: DrawerHeader(margin: EdgeInsets.zero,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/user_icon.png',
                      height: 60,
                      width: 60,
                    ),
                    SizedBox(
                      width: SizeConfig.defaultSize * 1.5,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mohamed Safwat',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text('View profile')
                      ],
                    )
                  ],
                ),
              ),
            ),
            Divider(),
            SizedBox(height: 15,),
           /*  ListTile(
              leading: Icon(
                Icons.card_giftcard_outlined,
              ),
              title: Text('Free rides',style: TextStyle(fontSize: SizeConfig.defaultSize*2),),
            ), */
           
            ListTile(
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Payment()));},
              leading: Icon(
                Icons.credit_card_outlined,
              ),
              title: Text('Payment',style: TextStyle(fontSize: SizeConfig.defaultSize*2),),
            ),
                ListTile(
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RideHistory()));},
              leading: Icon(
                Icons.history_outlined,
              ),
              title: Text('Ride history',style: TextStyle(fontSize: SizeConfig.defaultSize*2),),
            ),
           
            ListTile(
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Support()));},
              leading: Icon(
                Icons.contact_support_outlined,
              ),
              title: Text('Support',style: TextStyle(fontSize: SizeConfig.defaultSize*2),),
            ),
           
            ListTile(
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>About()));},
              leading: Icon(
                Icons.info_outline,
              ),
              title: Text('About',style: TextStyle(fontSize: SizeConfig.defaultSize*2),),
            ),

          ],
        ),
      );
  }
}