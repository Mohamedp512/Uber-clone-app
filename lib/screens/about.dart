import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1B2842),
        title: Text('About'),),
      body: Center(
        child: Text('About Page'),
      ),
    );
  }
}
