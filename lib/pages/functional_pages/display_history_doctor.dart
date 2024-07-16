import 'package:flutter/material.dart';
import 'package:tinyhealer/global.dart' as globals;

// ignore: must_be_immutable
class DisplayHistoryDoctor extends StatefulWidget {
  String id, symptoms, result, correctRes, docid, doctorRes, otherRes;

  DisplayHistoryDoctor(
      {required this.id,
      required this.symptoms,
      required this.result,
      required this.correctRes,
      required this.docid,
      required this.doctorRes,
      required this.otherRes});

  @override
  _DisplayHistoryDoctorState createState() => _DisplayHistoryDoctorState();
}

class _DisplayHistoryDoctorState extends State<DisplayHistoryDoctor> {
  List<String> symptomsList = [];
  List<String> resultList = [];
  List<String> doctorResList = [];
  List<String> otherResList = [];
  late bool isVertify;

  @override
  void initState() {
    super.initState();
    symptomsList = widget.symptoms.split(',');
    resultList = widget.result.split(',');
    doctorResList = widget.doctorRes.split(',');
    otherResList = widget.otherRes.split(',');
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Center(
                  child: Text(
                "Triệu chứng",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: currentWidth >= 600
                        ? 26 + 26 * ((currentWidth - 600) / 600)
                        : 26,
                    fontFamily: "Roboto"),
              )),
              const SizedBox(height: 10),
              Container(
                  height: currentHeight * 0.2,
                  padding: EdgeInsets.only(left: 12.0, top: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: symptomsList.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('- ',
                                  style: TextStyle(
                                      fontSize: currentWidth >= 600
                                          ? 18 +
                                              18 * ((currentWidth - 600) / 600)
                                          : 18)),
                              Expanded(
                                child: Text(
                                  // item,
                                  globals.symptomMatch[item]!,
                                  style: TextStyle(
                                      fontSize: currentWidth >= 600
                                          ? 18 +
                                              18 * ((currentWidth - 600) / 600)
                                          : 18),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )),
              const SizedBox(height: 5),
              Divider(color: Colors.grey[600]!),
              Center(
                  child: Text(
                "Chẩn đoán của AI",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: currentWidth >= 600
                        ? 26 + 26 * ((currentWidth - 600) / 600)
                        : 26,
                    fontFamily: "Roboto"),
              )),
              const SizedBox(height: 10),
              Container(
                  height: currentHeight * 0.2,
                  padding: EdgeInsets.only(left: 12.0, top: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: resultList.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('- ',
                                  style: TextStyle(
                                      fontSize: currentWidth >= 600
                                          ? 18 +
                                              18 * ((currentWidth - 600) / 600)
                                          : 18)),
                              Expanded(
                                child: Text(
                                  // item,
                                  globals.healthMatch[item]!,
                                  style: TextStyle(
                                      fontSize: currentWidth >= 600
                                          ? 18 +
                                              18 * ((currentWidth - 600) / 600)
                                          : 18),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )),
              const SizedBox(height: 5),
              Divider(color: Colors.grey[600]!),
              Center(
                  child: Text(
                "Chẩn đoán của bác sĩ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: currentWidth >= 600
                        ? 26 + 26 * ((currentWidth - 600) / 600)
                        : 26,
                    fontFamily: "Roboto"),
              )),
              const SizedBox(height: 10),
              Container(
                  height: currentHeight * 0.2,
                  padding: EdgeInsets.only(left: 12.0, top: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Map doctorResList items to Widgets
                        ...doctorResList.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '- ',
                                  style: TextStyle(
                                      fontSize: currentWidth >= 600
                                          ? 18 +
                                              18 * ((currentWidth - 600) / 600)
                                          : 18),
                                ),
                                Expanded(
                                  child: Text(
                                    globals.healthMatch[item]!,
                                    style: TextStyle(
                                        fontSize: currentWidth >= 600
                                            ? 18 +
                                                18 *
                                                    ((currentWidth - 600) / 600)
                                            : 18),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        // Conditional text widgetß
                        if (!widget.otherRes.isEmpty)
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bệnh khác:",
                                  style: TextStyle(
                                      fontSize: currentWidth >= 600
                                          ? 18 +
                                              18 * ((currentWidth - 600) / 600)
                                          : 18),
                                  softWrap: true,
                                )
                              ]),
                        if (!widget.otherRes.isEmpty) ...otherResList.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '- ',
                                  style: TextStyle(
                                      fontSize: currentWidth >= 600
                                          ? 18 +
                                              18 * ((currentWidth - 600) / 600)
                                          : 18),
                                ),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                        fontSize: currentWidth >= 600
                                            ? 18 +
                                                18 *
                                                    ((currentWidth - 600) / 600)
                                            : 18),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()
                      ],
                    ),
                  )),
            ])));
  }
}
