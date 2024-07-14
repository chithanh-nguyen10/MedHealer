import 'package:flutter/material.dart';
import 'package:tinyhealer/global.dart' as globals;

class OnlyFamilyAnamnesis extends StatefulWidget {
  @override
  _OnlyFamilyAnamnesisState createState() => _OnlyFamilyAnamnesisState();
}

class _OnlyFamilyAnamnesisState extends State<OnlyFamilyAnamnesis> {
  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: globals.familyanamnesis.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('- ', style: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18)),
                  Expanded(
                    child: Text(
                      // item,
                      globals.familyanamHealthMatch[item]!,
                      style: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}