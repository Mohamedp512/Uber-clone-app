
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waddiny/screens/authentication/signup/signup_screen.dart';
import 'package:waddiny/screens/home/homeScreen.dart';
import 'package:waddiny/services/auth.dart';
import 'package:waddiny/size_config.dart';
import 'components/custom_button.dart';
import 'components/custom_textFormField.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'loginScreen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String email;
  String password;
  FocusNode _passwordFocus;
  void showSnackBar(String msg) {
    final snackbar = SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: SizeConfig.defaultSize * 3),
            child: Form(
              key: _globalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: SizeConfig.defaultSize * 9,
                  ),
                  Image(
                    height: SizeConfig.defaultSize * 10,
                    width: SizeConfig.defaultSize * 10,
                    alignment: Alignment.center,
                    image: AssetImage('assets/images/logo.png'),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: SizeConfig.defaultSize * 4,
                  ),
                  Text(
                    'Sign In as a Rider',
                    style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize * 6,
                  ),
                  CustomTextFormField(
                    hint: 'Enter your Email',
                    action: TextInputAction.next,
                    keyboard: TextInputType.emailAddress,
                    onSave: (value) {
                      setState(() {
                        email = value.trim();
                      });
                    },
                    onSubmition: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize * 2,
                  ),
                  CustomTextFormField(
                    focus: _passwordFocus,
                    obsecure: true,
                    hint: 'Enter your Password',
                    action: TextInputAction.done,
                    onSave: (value) {
                      setState(() {
                        password = value.trim();
                      });
                    },
                    onSubmition: (_) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize * 15,
                  ),
                  CustomButton(
                    label: 'Login',
                    color: Color(0xFF61B581),
                    press: () async {
                      if (_globalKey.currentState.validate()) {
                        _globalKey.currentState.save();
                        try {
                          await Provider.of<Auth>(context, listen: false)
                              .signInWithEmail(
                                  email: email, password: password);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'No user found for that email.',
                                textAlign: TextAlign.center,
                              ),
                            ));
                          } else if (e.code == 'wrong-password') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Wrong password provided for that user.',
                                textAlign: TextAlign.center,
                              ),
                            ));
                          }throw(e){print(e);};
                        }
                        Navigator.pushNamedAndRemoveUntil(
                            context, HomeScreen.routeName, (route) => false);
                      }
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account?'),
                      FlatButton(
                        child: Text(
                          'Register',
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context,
                              SignUpScreen.routeName, (route) => false);
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
