import 'package:flutter/material.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinyhealer/pages/functional_pages/flowchartdisplay.dart';

// ignore: must_be_immutable
class DisplayHistoryNotVerify extends StatefulWidget {
  final String docid;
  final List<String> symptomsList, resultList;
  Function(String)? verify;
  DisplayHistoryNotVerify({required this.symptomsList, required this.resultList, required this.docid, required this.verify});
  
  @override
  _DisplayHistoryNotVerifyState createState() => _DisplayHistoryNotVerifyState();
}

class _DisplayHistoryNotVerifyState extends State<DisplayHistoryNotVerify> {
  List<bool?> checkBoxValue = [];

  @override
  void initState() {
    super.initState();
    checkBoxValue = List.generate(
      widget.resultList.length,
      (index) => false,
    );
    print(widget.resultList);
  }

  void showMessage(String mess){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 20, 80, 139),
          title: Center(
            child: Text(
              mess,
              style: const TextStyle(color: Colors.white, fontSize: 18)
            )
          )
        );
      }
    );
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
          Center(child: Text("Chọn bệnh mà bạn mắc phải", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 26 + 26 * ((currentWidth - 600)/600)  : 26, fontFamily: "Roboto"),)),
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
                return Column(
                  children: [
                    CheckboxListTile(
                      value: checkBoxValue[itemIndex],
                      onChanged: (value) {
                        setState(() {
                          checkBoxValue = List.generate(
                            widget.resultList.length,
                            (index) => false,
                          );
                          checkBoxValue[itemIndex] = value;
                        });
                      },
                      title: Text(
                        globals.healthMatch[widget.resultList[itemIndex]]!,
                        style: TextStyle(
                          fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17,
                          color: Colors.black
                        ),
                      ),
                    ),
                    if (widget.resultList[itemIndex] == "ent03" || widget.resultList[itemIndex] == "respir02") Row(
                      children: [
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlowChartDisplay(
                                  title: widget.resultList[itemIndex] == "ent03"
                                   ? "viêm amidan cấp mạn"
                                   : "viêm thanh khí phế quản cấp",
                                  imagePath: widget.resultList[itemIndex] == "ent03"
                                   ? "lib/images/viemamidan.png"
                                   : "lib/images/viemthanhkhiphequan.png",
                                )
                              )
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff228af4)
                          ),
                          child: Text('Xem phác đồ', style: TextStyle(fontSize: 16, color: Colors.white)),
                        )
                      ],
                    ),

                    const Divider()
                  ]
                );
              },
            )
          ),

          Expanded(child:Container()),

          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: MyButton(
              text: "Xác nhận",
              onTap: () async {
                String trueRes = "";
                for (int i = 0;i<checkBoxValue.length;++i){
                  if (checkBoxValue[i] == true) trueRes = widget.resultList[i];
                }
                if (trueRes == ""){
                  showMessage("Bạn chọn bệnh bạn mắc phải để xác nhận.");
                  return;
                }
                await FirebaseFirestore.instance
                .collection("users")
                .doc(globals.email)
                .collection("diagnostic-history")
                .doc(widget.docid)
                .update({
                  "isVertify": true,
                  "true-result": trueRes
                });
                DocumentReference docRef = FirebaseFirestore.instance.collection("symptoms-statistic").doc(trueRes);
                DocumentSnapshot docSnapshot = await docRef.get();
                Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
                for (String symptom in widget.symptomsList){
                  if (data!.containsKey(symptom)){
                    int currentcnt = data[symptom];
                    await docRef.update({
                      symptom: currentcnt + 1
                    });
                  }
                }
                widget.verify!(trueRes);
              },
            )
          )
        ]
      )
    );
  }
}