import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waddiny/screens/authentication/signup/signup_screen.dart';
import 'package:waddiny/screens/home/homeScreen.dart';
import 'package:waddiny/screens/search/search_screen.dart';
import 'package:waddiny/services/addressData.dart';
import 'package:waddiny/services/auth.dart';

import 'screens/authentication/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: AddressData())
      ],
      child: Consumer<Auth>(
        builder: (context,auth,_)=> MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Waddiny',
          routes: {
            LoginScreen.routeName: (context) => LoginScreen(),
            SignUpScreen.routeName: (context) => SignUpScreen(),
            HomeScreen.routeName: (context) => HomeScreen(),
            SearchScreen.routeName:(context)=>SearchScreen()
          },
          theme: ThemeData(
            fontFamily: 'Brand-Regular',
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuth?HomeScreen(): LoginScreen(),
        ),
      ),
    );
  }
}
