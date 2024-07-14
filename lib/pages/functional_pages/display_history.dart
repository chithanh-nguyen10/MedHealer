import 'package:flutter/material.dart';
import 'package:tinyhealer/pages/functional_pages/history_display/isNotVerify.dart';
import 'package:tinyhealer/pages/functional_pages/history_display/isVerify.dart';

// ignore: must_be_immutable
class DisplayHistory extends StatefulWidget {
  final bool isVertify;
  String id, symptoms, result, correctRes, docid;

  DisplayHistory({required this.id, required this.isVertify, required this.symptoms, required this.result, required this.correctRes, required this.docid});

  @override
  _DisplayHistoryState createState() => _DisplayHistoryState();
}

class _DisplayHistoryState extends State<DisplayHistory> {
  List<String> symptomsList = [];
  List<String> resultList = [];
  late bool isVertify;

  @override
  void initState() {
    super.initState();
    symptomsList = widget.symptoms.split(',');
    resultList = widget.result.split(',');
    isVertify = widget.isVertify;
  }

  void verify(String correctRes) {
    setState(() {
      isVertify = true;
      widget.correctRes = correctRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isVertify) return DisplayHistoryVerify(
      symptomsList: symptomsList,
      resultList: resultList,
      correctRes: widget.correctRes,
    );
    else return DisplayHistoryNotVerify(
      verify: verify,
      symptomsList: symptomsList,
      resultList: resultList,
      docid: widget.docid
    );
  }
}