import 'package:flutter/material.dart';
import 'package:waddiny/size_config.dart';

class CollectPayment extends StatelessWidget {
  final String paymentMehod;
  final int fares;

  CollectPayment({this.paymentMehod, this.fares});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: SizeConfig.defaultSize * 2,
            ),
            Text('${paymentMehod.toUpperCase()} PAYMENT'),
            SizedBox(
              height: SizeConfig.defaultSize * 2,
            ),
            Divider(),
            SizedBox(
              height: SizeConfig.defaultSize * 2,
            ),
            Text(
              '\$$fares',
              style: TextStyle(
                  fontFamily: 'Brand-Bold',
                  fontSize: SizeConfig.defaultSize * 5),
            ),
            SizedBox(
              height: SizeConfig.defaultSize * 2,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.defaultSize),
              child: Text(
                'Amount above is the total fares to be charged to the rider',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: SizeConfig.defaultSize * 3,
            ),
            Container(
              height: SizeConfig.defaultSize * 5,
              width: SizeConfig.defaultSize * 20,
              decoration: BoxDecoration(
                  color: Color(0xFF2EB272), borderRadius: BorderRadius.circular(25)),
              child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context, 'close');
                  },
                  child: Text(paymentMehod == 'cash' ? 'PAY CASH' : 'CONFIRM',style: TextStyle(fontFamily: 'Brand-Bold',fontSize: SizeConfig.defaultSize*1.8,color: Colors.white),)),
            ),
            SizedBox(
              height: SizeConfig.defaultSize * 4,
            ),
          ],
        ),
      ),
    );
  }
}
