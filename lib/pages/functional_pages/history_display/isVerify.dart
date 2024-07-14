import 'package:flutter/material.dart';
import 'package:tinyhealer/global.dart' as globals;

// ignore: must_be_immutable
class DisplayHistoryVerify extends StatefulWidget {
  String correctRes;
  final List<String> symptomsList, resultList;
  DisplayHistoryVerify({required this.symptomsList, required this.resultList, required this.correctRes});
  
  @override
  _DisplayHistoryVerifyState createState() => _DisplayHistoryVerifyState();
}

class _DisplayHistoryVerifyState extends State<DisplayHistoryVerify> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(child: Text("Triệu chứng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 26 + 26 * ((currentWidth - 600)/600)  : 26, fontFamily: "Roboto"),)),
          const SizedBox(height:10),
          Container(
            height: currentHeight*0.25,
            padding: EdgeInsets.only(left: 12.0, top:5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: widget.symptomsList.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('- ', style: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18)),
                        Expanded(
                          child: Text(
                            // item,
                            globals.symptomMatch[item]!,
                            style: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ),
          const SizedBox(height: 5),
          Divider(color: Colors.grey[600]!),
          Center(child: Text("Kết quả", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 26 + 26 * ((currentWidth - 600)/600)  : 26, fontFamily: "Roboto"),)),
          const SizedBox(height:10),
          Container(
            height: currentHeight*0.25,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            child: ListView.builder(
              itemCount: widget.resultList.length,
              itemBuilder: (context, itemIndex) {
                return CheckboxListTile(
                  value: widget.resultList[itemIndex] == widget.correctRes,
                  onChanged: null,
                  title: Text(
                    globals.healthMatch[widget.resultList[itemIndex]]!,
                    style: TextStyle(
                      fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17,
                      color: Colors.black
                    ),
                  ),
                );
              },
            )
          ),
        ]
      )
    );
  }
}