import 'package:flutter/material.dart';
import 'package:waddiny/size_config.dart';

class CustomDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          padding: EdgeInsets.all(SizeConfig.defaultSize * 1.5),
          //height: SizeConfig.defaultSize * 15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No Driver Found',
                style: TextStyle(
                    fontSize: SizeConfig.defaultSize * 2,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Brand-Bold'),
              ),
              SizedBox(
                height: SizeConfig.defaultSize * 2,
              ),
              Text(
                'no available driver close by, we suggest you try again shortly',
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: SizeConfig.defaultSize * 1.5,
              ),
              //Spacer(),
              OutlineButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('CLOSE'),
              ),
            ],
          )),
    );
  }
}
