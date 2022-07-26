import 'package:flutter/material.dart';

class CustomMenuButton extends StatelessWidget {
  final IconData icon;

  const CustomMenuButton({ this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(50), boxShadow: [
          BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 0.5,
              offset: Offset(0.7, 0.7))
        ]),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: Icon(
            icon,
            color: Colors.black87,
          ),
        ));
  }
}
