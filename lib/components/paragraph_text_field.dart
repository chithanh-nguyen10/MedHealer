
import 'package:flutter/material.dart';

class ParagraphTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final Function(String) onChanged;
  final double height;

  const ParagraphTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 16.0, bottom: 16.0),
      child: Container(
        height: height,
        child: TextField(
          onChanged: (value) {
            this.onChanged(value);
          },
          controller: controller,
          keyboardType: TextInputType.text,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black, 
          ),
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: Colors.grey.shade400),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hintText,
            contentPadding: EdgeInsets.all(12.0),
            hintStyle: const TextStyle(
              fontSize: 20,
              // fontWeight: FontWeight.w500,
              color: Color(0xff7b7b7b),
            ),
          ),
        )
      )
    );
  }
}