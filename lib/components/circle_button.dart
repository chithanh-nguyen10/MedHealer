import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final Function()? onTap;
  final IconData icon;
  final String text;

  const CircleButton({Key? key, required this.onTap, required this.icon, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xff1a73e7), // Border color
                width: 2.0, // Border width
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xff1a73e7),
              size: 28,
            ),
          ),
          if (text != "") Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff1a73e7),
            ),
          )
        ],
      ),
    );
  }
}