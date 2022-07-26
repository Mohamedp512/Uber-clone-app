import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final bool obsecure;
  final String hint;
  final String label;
  final TextInputType keyboard;
  final TextInputAction action;
  final FocusNode focus;
  final Function onSave;
  final Function onSubmition;
  
  _errorMsg(String str){
    switch (hint){
      case 'Enter your Name':return 'Name is Empty';
      case 'Enter your Email': return 'Email is Empty';
      case 'Enter your Phone': return 'Phone is Empty';
      case 'Enter your Password': return 'Password is empty';
    }
  }

   CustomTextFormField(
      {this.obsecure=false,
      this.hint,
      this.label,
      this.keyboard,
      this.action,
      this.focus,
      this.onSave,
      this.onSubmition,
      });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obsecure,
      keyboardType: keyboard,
      validator: (value){
        if(value.isEmpty){
         return  _errorMsg(hint);
        }
        return null;
      },
      onSaved: onSave,
      onFieldSubmitted: onSubmition,
      textInputAction: action,
      focusNode: focus,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
      ),
    );
  }
}
