import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tinyhealer/global.dart' as globals;
import 'package:timezone/timezone.dart' as tz;
import 'package:tinyhealer/pages/functional_pages/display_diagnostic.dart';

class DiagnosticPage extends StatefulWidget {
  final Function()? onTap;
  final Function(List<String>)? searchMap;
  DiagnosticPage({super.key, required this.onTap, required this.searchMap});

  @override
  _DiagnosticPageState createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> tabList = [];
  List<List<bool>> checkboxValuesList = [];
  List<List<String>> checklistItemsList = [];
  List<List<String>> checkListData = [];
  List<List<String>> idData = [];
  bool isSearch = false;
  Map<String, int> mp = {};
  Map<String, bool> mark = {};
  bool ready = false;
  FocusNode _focusNode = FocusNode();
  Color _labelcolor = Colors.grey;
  List<String> results = [];
  List<bool> checkBoxValue = [];
  List<List<int>> coords = [];
  bool isDiagnose = false;
  List<dynamic> result = [];

  bool isStomatchache = false;

  void toggleCheckbox(int tabIndex, int itemIndex, bool value) {
    setState(() {
      if (tabIndex == 0 && 0<=itemIndex && itemIndex<=2 && value == true){
        for (int i = 0;i<=2;++i) {checkboxValuesList[tabIndex][i] = false;}
        checkboxValuesList[tabIndex][itemIndex] = true;
      }
      else if (tabIndex == 0 && 3<=itemIndex && itemIndex<=6 && value == true){
        for (int i = 3;i<=6;++i) {checkboxValuesList[tabIndex][i] = false;}
        checkboxValuesList[tabIndex][itemIndex] = true;
      }
      else if (tabIndex == 0 && 14<=itemIndex && itemIndex<=16 && value == true){
        for (int i = 14;i<=16;++i) {checkboxValuesList[tabIndex][i] = false;}
        checkboxValuesList[tabIndex][itemIndex] = true;
      }
      else {
        checkboxValuesList[tabIndex][itemIndex] = value;
      }
    });
  }

  void diagnose() async {
    var bangkok = tz.getLocation('Asia/Bangkok');
    var now = tz.TZDateTime.now(bangkok);
    String currentTime = now.toString();
    String year = currentTime.substring(0, 4);
    String day = currentTime.substring(5, 7);
    String mon = currentTime.substring(8, 10);
    String hour = currentTime.substring(11, 13);
    String min = currentTime.substring(14, 16);
    String displayTime = "${day}-${mon}-${year} ${hour}:${min}";

    List<String> symptoms = [];
    for (int i = 0; i < checklistItemsList.length; ++i) {
      for (int j = 0; j < checklistItemsList[i].length; ++j) {
        if (checkboxValuesList[i][j]) {
          symptoms.add(idData[i][j]);
        }
      }
    }
    int len = symptoms.length;
    // print(symptoms);

    if (len < 3) {
      showMessage("Bạn cần chọn ít nhất nhất 3 triệu chứng!");
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    final url = Uri.parse('https://healerai.elifeup.com/diagnostic');

    final payload = {
      "symptoms": symptoms,
      "anamnesis": [],
      "familyanamnesis": []
    };
    print(symptoms);

    final headers = {
      "Content-Type": "application/json",
      "token": "super_secret_token"
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      result = json.decode(response.body)["results"];
      print(result);
      int id;
      String symp = "", res = "";
      bool isVertify = false;
      for (String symptom in symptoms) {
        symp += symptom;
        symp += ",";
      }
      for (String health in result) {
        res += health;
        res += ",";
      }
      symp = symp.substring(0, symp.length - 1);
      res = res.substring(0, res.length - 1);
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("identify")
          .doc("current-id")
          .get();
      id = documentSnapshot.get("id") + 1;
      print(id);
      await FirebaseFirestore.instance
          .collection("identify")
          .doc("current-id")
          .update({"id": id});

      await FirebaseFirestore.instance
          .collection("users")
          .doc(globals.email)
          .collection("diagnostic-history")
          .add({
        "id": id,
        "symptoms": symp,
        "result": res,
        "isVertify": isVertify,
        "time": displayTime
      });
      globals.currentid = id;
      Navigator.pop(context);
      setState(() {
        isDiagnose = true;
      });
    } else {
      print("Request failed with status code: ${response.statusCode}");
      print("Response: ${response.body}");
      Navigator.pop(context);
      showMessage("Có lỗi xảy ra, vui lòng thử lại sau!");
    }
  }

  void showMessage(String mess) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Color.fromARGB(255, 20, 80, 139),
              title: Center(
                  child: Text(mess,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18))));
        });
  }

  @override
  void initState() {
    super.initState();
    ready = false;
    _focusNode = FocusNode();
    _labelcolor = Colors.grey;

    _focusNode.addListener(() {
      setState(() {
        _labelcolor = _focusNode.hasFocus ? Color(0xff228af4) : Colors.grey;
      });
    });

    fetchNames().then((_) {
      checklistItemsList = checkListData;
      _tabController =
          TabController(length: checklistItemsList.length, vsync: this);
      checkboxValuesList = List.generate(
        checklistItemsList.length,
        (outerIndex) => List.generate(
          checklistItemsList[outerIndex].length,
          (innerIndex) => false,
        ),
      );
      // print(checklistItemsList[0].length);
      setState(() {
        ready = true;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> fetchNames() async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('symptom');
    QuerySnapshot querySnapshot = await collectionReference.get();

    int index = 0;
    // ignore: unused_local_variable
    final List<List<String>> names = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String id = data['id'] as String;
      String name = data['name'] as String;
      String type = id.substring(0, ffnci(id));
      if (mp[type] == null) {
        mp[type] = index;
        index++;
        checkListData.add([]);
        idData.add([]);
        tabList.add(globals.types[type]!);
      }
      if (mark[toTitle(name)] == null) {
        checkListData[mp[type]!].add(toTitle(name));
        idData[mp[type]!].add(id);
        mark[toTitle(name)] = true;
      }
      return [id, name];
    }).toList();
  }

  int ffnci(String str) {
    for (int i = 0; i < str.length; i++) {
      if (isDigit(str[i])) {
        return i;
      }
    }
    return -1;
  }

  bool isDigit(String character) {
    return RegExp(r'^[0-9]$').hasMatch(character);
  }

  String toTitle(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    if (ready) {
      if (isDiagnose)
        return DisplayDiagnostic(
          results: result,
          onTap: widget.onTap,
          searchMap: widget.searchMap,
        );
      else{
        return Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                style: TextStyle(
                    fontSize: currentWidth >= 600
                        ? 18 + 18 * ((currentWidth - 600) / 600)
                        : 18),
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: "Tìm kiếm",
                  suffixIcon:
                      Icon(Icons.search, color: Colors.grey[400]!, size: 30),
                  labelStyle: TextStyle(
                      fontSize: currentWidth >= 600
                          ? 18 + 18 * ((currentWidth - 600) / 600)
                          : 18,
                      color: _labelcolor),
                ),
                cursorColor: Colors.grey,
                onChanged: (text) {
                  setState(() {
                    if (text == "") {
                      isSearch = false;
                      results = [];
                      checkBoxValue = [];
                      coords = [];
                    } else {
                      isSearch = true;
                      results = [];
                      checkBoxValue = [];
                      coords = [];
                      String task = text.toLowerCase();
                      for (int i = 0; i < checklistItemsList.length; ++i) {
                        for (int j = 0; j < checklistItemsList[i].length; ++j) {
                          if (checklistItemsList[i][j]
                              .toLowerCase()
                              .contains(task)) {
                            results.add(checklistItemsList[i][j]);
                            checkBoxValue.add(checkboxValuesList[i][j]);
                            coords.add([i, j]);
                          }
                        }
                      }
                    }
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            if (!isSearch)
              Container(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: TextStyle(
                        fontSize: currentWidth >= 600
                            ? 17 + 17 * ((currentWidth - 600) / 1800)
                            : 17),
                    isScrollable: true,
                    tabs: List.generate(
                      checklistItemsList.length,
                      (index) => Tab(text: tabList[index]),
                    ),
                  ),
                ),
              ),
            if (!isSearch)
              Expanded(
                  child: Container(
                width: double.maxFinite,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBarView(
                      controller: _tabController,
                      children: List.generate(
                        checklistItemsList.length,
                        (tabIndex) => ListView.builder(
                          itemCount: checklistItemsList[tabIndex].length,
                          itemBuilder: (context, itemIndex) {
                            if (tabIndex == 0 && itemIndex == 0) {
                              return Column(
                                children: [
                                  CheckboxListTile(
                                    value: isStomatchache,
                                    onChanged: (value) {
                                      setState(() {
                                        isStomatchache = value ?? false;
                                      });
                                    },
                                    title: Text(
                                      "Tôi có triệu chứng đau bụng?",
                                      style: TextStyle(
                                          fontSize: currentWidth >= 600
                                              ? 17 +
                                                  17 *
                                                      ((currentWidth - 600) /
                                                          1000)
                                              : 17),
                                    ),
                                  ),
                                  Visibility(visible: isStomatchache, child: CheckboxListTile(
                                    value: checkboxValuesList[tabIndex]
                                        [itemIndex],
                                    onChanged: (value) {
                                      toggleCheckbox(
                                          tabIndex, itemIndex, value ?? false);
                                    },
                                    title: Text(
                                      checklistItemsList[tabIndex][itemIndex],
                                      style: TextStyle(
                                          fontSize: currentWidth >= 600
                                              ? 17 +
                                                  17 *
                                                      ((currentWidth - 600) /
                                                          1000)
                                              : 17),
                                    ),
                                  ))
                                ],
                              );
                            }
                            return Visibility(visible: (tabIndex == 0 && isStomatchache) || tabIndex != 0, child:CheckboxListTile(
                              value: checkboxValuesList[tabIndex][itemIndex],
                              onChanged: (value) {
                                toggleCheckbox(
                                    tabIndex, itemIndex, value ?? false);
                              },
                              title: Text(
                                checklistItemsList[tabIndex][itemIndex],
                                style: TextStyle(
                                    fontSize: currentWidth >= 600
                                        ? 17 +
                                            17 * ((currentWidth - 600) / 1000)
                                        : 17),
                              ),
                            ));
                          },
                        ),
                      )),
                ),
              )),
            if (isSearch)
              Expanded(
                child: (results.length != 0)
                    ? ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          // int tabIndex = coords[index][0];
                          // int itemIndex = coords[index][1];
                          return CheckboxListTile(
                            value: checkboxValuesList[coords[index][0]]
                                [coords[index][1]],
                            onChanged: (value) {
                              setState(() {
                                checkBoxValue[index] = value ?? false;
                                var coord = coords[index];
                                checkboxValuesList[coord[0]][coord[1]] =
                                    value ?? false;
                              });
                            },
                            title: Text(
                              results[index],
                              style: TextStyle(
                                fontSize: currentWidth >= 600
                                    ? 17 + 17 * ((currentWidth - 600) / 1000)
                                    : 17,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Container(
                        child: Text(
                          "Không tìm thấy kết quả",
                          style: TextStyle(
                              fontSize: currentWidth >= 600
                                  ? 20 + 20 * ((currentWidth - 600) / 1000)
                                  : 20),
                        ),
                      )),
              ),
            Padding(
                padding: EdgeInsets.only(bottom: 10, top: 15),
                child: MyButton(
                  text: "Chẩn đoán",
                  onTap: diagnose,
                ))
          ],
        );}
    } else
      return Center(child: CircularProgressIndicator());
  }
}
