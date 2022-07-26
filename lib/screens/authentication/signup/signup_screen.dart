
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:waddiny/screens/authentication/login/components/custom_button.dart';
import 'package:waddiny/screens/authentication/login/components/custom_textFormField.dart';
import 'package:waddiny/screens/authentication/login/login_screen.dart';
import 'package:waddiny/screens/home/homeScreen.dart';
import 'package:waddiny/services/auth.dart';
import 'package:waddiny/size_config.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = 'signUpScreen';
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  String name;
  String email;
  String phone;
  String password;
  FocusNode _passwordFocus;
  FocusNode _emailFocus;
  FocusNode _phoneFocus;

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
                    'Create a Rider account',
                    style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize * 3.5,
                  ),
                  CustomTextFormField(
                    hint: 'Enter your Name',
                    action: TextInputAction.next,
                    onSave: (value) {
                      setState(() {
                        name = value.trim();
                      });
                    },
                    onSubmition: (_) {
                      FocusScope.of(context).requestFocus(_emailFocus);
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize * 1.5,
                  ),
                  CustomTextFormField(
                    focus: _emailFocus,
                    hint: 'Enter your Email',
                    action: TextInputAction.next,
                    keyboard: TextInputType.emailAddress,
                    onSave: (value) {
                      setState(() {
                        email = value.trim();
                      });
                    },
                    onSubmition: (_) {
                      FocusScope.of(context).requestFocus(_phoneFocus);
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize * 1.5,
                  ),
                  CustomTextFormField(
                    hint: 'Enter your Phone',
                    keyboard: TextInputType.phone,
                    action: TextInputAction.next,
                    focus: _phoneFocus,
                    onSave: (value) {
                      setState(() {
                        phone = value.trim();
                      });
                    },
                    onSubmition: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize * 1.5,
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
                    height: SizeConfig.defaultSize * 6,
                  ),
                  CustomButton(
                    label: 'Register',
                    color: Color(0xFF4262C4),
                    press: () async {
                      if (_globalKey.currentState.validate()) {
                        _globalKey.currentState.save();
                        try {
                          await Provider.of<Auth>(context, listen: false)
                              .signUpWithEmail(email.trim(), password.trim());
                              String userId=FirebaseAuth.instance.currentUser.uid;
                              await Provider.of<Auth>(context,listen: false).addUser(userId, name, email, phone);
                              await Provider.of<Auth>(context,listen: false).getUserInfo();
                              print(Provider.of<Auth>(context,listen: false).currentUser.phone);
                          Navigator.pushNamedAndRemoveUntil(
                              context, HomeScreen.routeName, (route) => false);
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              e.message,
                              textAlign: TextAlign.center,
                            ),
                          ));
                        } catch (e) {
                          print(e.message);
                          //  throw(e);
                        }
                        /*     if (e.code == 'weak-password') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('The password provided is too weak.',textAlign: TextAlign.center,),));
                          } else if (e.code == 'email-already-in-use') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('The account already exists for that email.',textAlign: TextAlign.center,),));
                            
                          }throw(e){
                            print(e);
                          }; */
                      }
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Have an account?'),
                      FlatButton(
                        child: Text(
                          'Login',
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, LoginScreen.routeName, (route) => false);
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
