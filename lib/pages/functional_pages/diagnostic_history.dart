import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'package:flutter/material.dart';
import 'package:tinyhealer/pages/functional_pages/display_history.dart';

class DiagnosticHistory extends StatefulWidget {
  final Function(String, bool) changeMenu;
  DiagnosticHistory({required this.changeMenu});

  @override
  _DiagnosticHistoryState createState() => _DiagnosticHistoryState();
}

class _DiagnosticHistoryState extends State<DiagnosticHistory> with TickerProviderStateMixin {
  bool? historyEmpty;
  bool ready = false;
  List<HistoryItem> historyData = [];
  late bool isVertify;
  late String symptoms, result, id, correctRes, docid;

  @override
  void initState() {
    super.initState();
    globals.historyState = "default";
    checkHistory().then((_) {
      if (historyEmpty == false) {
        print("a");
        fetchData().then((_) {
          setState(() {
            ready = true;
          });
        });
      } else {
        setState(() {
          ready = true;
        });
      }
    });

    globals.historyStateStream.listen((state) {
      if (state == "default") {
        fetchData().then((_) {
          setState(() {
            ready = true;
          });
        });
      }
    });
  }

  Future<void> fetchData() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(globals.email)
        .collection("diagnostic-history")
        .get();
    List<DocumentSnapshot> documents = querySnapshot.docs;
    historyData.clear();
    for (var document in documents) {
      var data = document.data() as Map<String, dynamic>;
      HistoryItem newItem = HistoryItem(
        id: data['id'],
        isVertify: data['isVertify'],
        symptoms: data['symptoms'],
        result: data['result'],
        docid: document.id,
        correctRes: data['true-result'] ?? "null",
      );
      historyData.add(newItem);
    }
    historyData.sort(compare);
    // print(historyData);
  }

  int compare(HistoryItem a, HistoryItem b) {
    return a.id.compareTo(b.id);
  }

  Future<void> checkHistory() async {
    bool empty = await isHistoryEmpty();
    setState(() {
      historyEmpty = empty;
    });
  }

  Future<bool> isHistoryEmpty() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(globals.email)
        .collection("diagnostic-history")
        .limit(1)
        .get();
    return snapshot.docs.isEmpty;
  }

  String idTransform(int id) {
    return '#${id.toString().padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    if (ready) {
      if (historyEmpty!) {
        return Center(
          child: Text(
            "Bạn chưa thực hiện một lần chẩn đoán nào.",
            style: TextStyle(
              fontSize: currentWidth >= 600 ? 19 + 19 * ((currentWidth - 600) / 1000) : 19,
            ),
          ),
        );
      } else {
        if (globals.historyState == "default") {
          return ListView.builder(
            itemCount: historyData.length,
            itemBuilder: (context, index) {
              final item = historyData[index];
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      widget.changeMenu(idTransform(item.id), false);
                      setState(() {
                        isVertify = item.isVertify;
                        symptoms = item.symptoms;
                        result = item.result;
                        correctRes = item.correctRes;
                        id = idTransform(item.id);
                        docid = item.docid;
                        globals.historyState = "display";
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          Text(
                            idTransform(item.id),
                            style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: currentWidth >= 600
                                  ? 22 + 22 * ((currentWidth - 600) / 800)
                                  : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: BoxDecoration(
                              color: item.isVertify ? Color(0xff44ad41) : Color(0xffffb123),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            item.isVertify ? "Đã xác nhận" : "Chưa xác nhận",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: currentWidth >= 600
                                  ? 16 + 16 * ((currentWidth - 600) / 800)
                                  : 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < historyData.length - 1)
                    Divider(
                      color: Colors.grey,
                    ),
                ],
              );
            },
          );
        } else {
          return DisplayHistory(
            id: id,
            correctRes: correctRes,
            isVertify: isVertify,
            symptoms: symptoms,
            result: result,
            docid: docid,
          );
        }
      }
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

class HistoryItem {
  int id;
  bool isVertify;
  String symptoms;
  String result;
  String correctRes;
  String docid;

  HistoryItem({
    required this.id,
    required this.isVertify,
    required this.symptoms,
    required this.result,
    required this.docid,
    this.correctRes = "null",
  });

  @override
  String toString() {
    return '{$id, $isVertify, symptoms: $symptoms, result: $result}';
  }
}
