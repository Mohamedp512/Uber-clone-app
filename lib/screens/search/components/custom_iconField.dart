import 'package:flutter/material.dart';
import 'package:waddiny/size_config.dart';

class CustomIconField extends StatelessWidget {
  final String icon;
  final String hint;
  final TextEditingController controller;
  final bool focus;
  final Function press;
  final Function change;

  const CustomIconField(
      {this.change,
      this.press,
      this.focus,
      this.icon,
      this.hint,
      this.controller});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          icon,
          height: 16,
          width: 16,
        ),
        SizedBox(
          width: SizeConfig.defaultSize * 2,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[300],
            ),
            child: TextFormField(
              onChanged: change,
              onTap: press,
              autofocus: focus,
              controller: controller,
              decoration: InputDecoration(
                  hintText: hint,
                  fillColor: Colors.grey[300],
                  filled: true,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: 10, bottom: 8, top: 8)),
            ),
          ),
        )
      ],
    );
  }
}
