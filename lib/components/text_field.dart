
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final bool enabledText;
  final double fontSize;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.enabledText = true,
    this.fontSize = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: TextInputType.text,
        enabled: enabledText,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black, 
        ),
        cursorColor: Colors.grey,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: Colors.white),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Color(0xff7b7b7b),
          ),
        ),
      )
    );
  }
}