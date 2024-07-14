import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FlowChartDisplay extends StatefulWidget {
  String title, imagePath;
  FlowChartDisplay({required this.title, required this.imagePath});

  @override
  _FlowChartDisplayState createState() => _FlowChartDisplayState();
}

class _FlowChartDisplayState extends State<FlowChartDisplay> {
  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Phác đồ điều trị bệnh ${widget.title}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/600)  : 22,
                fontFamily: "Roboto",
              ),
              textAlign: TextAlign.center,
            )
          ),

          const SizedBox(height: 10),

          SingleChildScrollView(
            child: Image.asset(
              widget.imagePath,
              width: currentWidth-10,
            ),
          )
        ],
      )
    );
  }
}