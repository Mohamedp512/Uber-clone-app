import 'package:flutter/material.dart';
import 'package:waddiny/size_config.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Function press;
  final Color color;

  CustomButton({this.label, this.color, this.press});
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: press,
      child: Container(
          height: SizeConfig.defaultSize * 5,
          child: Center(
              child: Text(
            label,
            style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
          ))),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color,
      textColor: Colors.white,
    );
  }
}
