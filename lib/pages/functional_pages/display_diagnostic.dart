import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'package:tinyhealer/pages/functional_pages/loading_page.dart';

class DisplayDiagnostic extends StatefulWidget {
  final List<dynamic> results;
  final Function()? onTap;
  final Function(List<String>)? searchMap;
  DisplayDiagnostic(
      {super.key,
      required this.results,
      required this.onTap,
      required this.searchMap});

  @override
  _DisplayDiagnosticState createState() => _DisplayDiagnosticState();
}

class _DisplayDiagnosticState extends State<DisplayDiagnostic>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<List<bool>> checkboxValuesList = [];
  List<String> tabList = [];
  List<List<String>> checkListData = [];
  List<List<String>> checklistItemsList = [];
  List<List<String>> idData = [];
  List<String> currentOther = [];
  Map<String, int> mp = {};
  bool ready = false;
  FocusNode _focusNode = FocusNode();
  Color _labelcolor = Colors.grey;
  bool isVisib = false;
  TextEditingController addResultController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _labelcolor = Colors.grey;

    _focusNode.addListener(() {
      setState(() {
        _labelcolor = _focusNode.hasFocus ? Color(0xff228af4) : Colors.grey;
      });
    });

    fetchNames().then((_) {
      checklistItemsList = checkListData;
      tabList.add("Bệnh khác");
      _tabController = TabController(length: tabList.length, vsync: this);
      checkboxValuesList = List.generate(
        checklistItemsList.length,
        (outerIndex) => List.generate(
          checklistItemsList[outerIndex].length,
          (innerIndex) => false,
        ),
      );
      _tabController.addListener(_handleTabSelection);
      setState(() {
        ready = true;
      });
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 2) {
        setState(() {
          isVisib = true;
        });
        print("tab2");
      } else {
        setState(() {
          isVisib = false;
        });
      }
    }
  }

  Future<void> fetchNames() async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('health-problems');
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
        tabList.add(globals.healthTypes[type]!);
      }
      checkListData[mp[type]!].add(toTitle(name));
      idData[mp[type]!].add(id);
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

  void completeDiagnose() async{
    CollectionReference collectionReference = FirebaseFirestore.instance
        .collection("users")
        .doc(globals.email)
        .collection("diagnostic-history");
    QuerySnapshot querySnapshot = await collectionReference.where('id', isEqualTo: globals.currentid).get();
    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    DocumentReference documentRef = documentSnapshot.reference;
    List<String> resultLists = [];
    for (int i = 0;i<checkListData.length;++i){
      for (int j = 0;j<checkListData[i].length;++j){
        if (checkboxValuesList[i][j] == true){
          resultLists.add(idData[i][j]);
        }
      }
    }
    if (resultLists.isEmpty && currentOther.isEmpty){
      showMessage("Bạn chưa chọn bệnh!");
      return;
    }
    String res = "", otherRes = "";
    for (String v in resultLists){
      res += v; res += ",";
    }
    for (String v in currentOther){
      otherRes += v; otherRes += ",";
    }
    if (res.length != 0) res = res.substring(0, res.length - 1);
    if (otherRes.length != 0) otherRes = otherRes.substring(0, otherRes.length - 1);

    print(res); print(otherRes);

    documentRef.update({
      "doctor-results" : res,
      "doctor-other-results" : otherRes
    });
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

  bool isDigit(String character) {
    return RegExp(r'^[0-9]$').hasMatch(character);
  }

  String toTitle(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  void toggleCheckbox(int tabIndex, int itemIndex, bool value) {
    setState(() {
      checkboxValuesList[tabIndex][itemIndex] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    if (ready) {
      return Column(children: [
        SizedBox(height: 15),
        Text(
          "Bạn có thể đã bị các bệnh sau",
          style: TextStyle(
              fontSize: currentWidth >= 600
                  ? 22 + 22 * ((currentWidth - 600) / 600)
                  : 22,
              fontWeight: FontWeight.bold),
          softWrap: true,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25.0, top: 5.0),
          child: SingleChildScrollView(
            child: Column(
              children: widget.results.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('- ',
                          style: TextStyle(
                              fontSize: currentWidth >= 600
                                  ? 18 + 18 * ((currentWidth - 600) / 600)
                                  : 18)),
                      Expanded(
                        child: Text(
                          // item,
                          globals.healthMatch[item]!,
                          style: TextStyle(
                              fontSize: currentWidth >= 600
                                  ? 18 + 18 * ((currentWidth - 600) / 600)
                                  : 18),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (globals.type == "normal") SizedBox(height: 15),
        if (globals.type == "normal")
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0),
              child: Text(
                '*Lưu ý: Kết quả của TinyHealer chỉ mang tính chất tham khảo, bạn nên hỏi ý kiến của các chuyên gia y khoa để có kết quả chính xác hơn!',
                style: TextStyle(
                    color: Color(0xff6a6a6a),
                    fontSize: currentWidth >= 600
                        ? 15 + 15 * ((currentWidth - 600) / 350)
                        : 15),
                softWrap: true,
                overflow: TextOverflow.visible,
              )),
        if (globals.type == "normal")
          Padding(
              padding: EdgeInsets.only(bottom: 10, top: 15),
              child: MyButton(
                text: "Tìm bệnh viện phù hợp",
                onTap: () {
                  List<String> stringRes = [];
                  for (int i = 0; i < widget.results.length; i++) {
                    stringRes.add(widget.results[i]);
                  }
                  ;
                  print(stringRes);
                  widget.searchMap!(stringRes);
                },
              )),
        if (globals.type == "doctor")
          Column(
            children: [
              Divider(),
              Text(
                "Chẩn đoán của bác sĩ",
                style: TextStyle(
                    fontSize: currentWidth >= 600
                        ? 22 + 22 * ((currentWidth - 600) / 600)
                        : 22,
                    fontWeight: FontWeight.bold),
                softWrap: true,
              ),
            ],
          ),
        if (globals.type == "normal")
          Expanded(
            child: Container(),
          ),
        if (globals.type == "doctor")
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
                  tabList.length,
                  (index) => Tab(text: tabList[index]),
                ),
              ),
            ),
          ),
        if (globals.type == "doctor")
          Expanded(
              child: Container(
            width: double.maxFinite,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBarView(
                  controller: _tabController,
                  children: List.generate(
                    tabList.length,
                    (tabIndex) {
                      if (tabIndex == tabList.length - 1) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 25.0, top: 5.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: currentOther.map((item) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('- ',
                                          style: TextStyle(
                                              fontSize: currentWidth >= 600
                                                  ? 18 +
                                                      18 *
                                                          ((currentWidth -
                                                                  600) /
                                                              600)
                                                  : 18)),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                              fontSize: currentWidth >= 600
                                                  ? 18 +
                                                      18 *
                                                          ((currentWidth -
                                                                  600) /
                                                              600)
                                                  : 18),
                                          softWrap: true,
                                        ),
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              currentOther.remove(item);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Center(
                                                child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Xoá bệnh',
                                                style: TextStyle(
                                                    fontSize: currentWidth >=
                                                            600
                                                        ? 15 +
                                                            15 *
                                                                ((currentWidth -
                                                                        600) /
                                                                    600)
                                                        : 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            )),
                                          )),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: checklistItemsList[tabIndex].length,
                        itemBuilder: (context, itemIndex) {
                          return CheckboxListTile(
                            value: checkboxValuesList[tabIndex][itemIndex],
                            onChanged: (value) {
                              toggleCheckbox(
                                  tabIndex, itemIndex, value ?? false);
                            },
                            title: Text(
                              checklistItemsList[tabIndex][itemIndex],
                              style: TextStyle(
                                  fontSize: currentWidth >= 600
                                      ? 17 + 17 * ((currentWidth - 600) / 1000)
                                      : 17),
                              softWrap: true,
                            ),
                          );
                        },
                      );
                    },
                  )),
            ),
          )),
        if (globals.type == "normal")
          Padding(
              padding: EdgeInsets.only(bottom: 10, top: 15),
              child: MyButton(
                text: "Quay về trang chủ",
                onTap: widget.onTap,
              )),
        if (globals.type == "doctor" && isVisib == true)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      fontSize: currentWidth >= 600
                          ? 18 + 18 * ((currentWidth - 600) / 600)
                          : 18,
                    ),
                    focusNode: _focusNode,
                    controller: addResultController,
                    decoration: InputDecoration(
                      labelText: "Nhập tên bệnh",
                      labelStyle: TextStyle(
                        fontSize: currentWidth >= 600
                            ? 18 + 18 * ((currentWidth - 600) / 600)
                            : 18,
                        color: _labelcolor,
                      ),
                    ),
                    cursorColor: Colors.grey,
                  ),
                ),
                SizedBox(
                    width: 10), // Add some space between TextField and Button
                ElevatedButton(
                  onPressed: () {
                    String newRes = addResultController.text;
                    if (newRes.trim().length == 0) {
                      showMessage("Bạn chưa nhập bệnh!");
                    } else if (currentOther.contains(newRes.trim())) {
                      showMessage("Bệnh đã có trong danh sách!");
                    } else {
                      print(newRes.trim());
                      setState(() {
                        currentOther.add(newRes.trim());
                      });
                    }
                  },
                  child: Text("Thêm bệnh"),
                ),
              ],
            ),
          ),
        if (globals.type == "doctor") const SizedBox(height: 10),
        if (globals.type == "doctor")
          Padding(
              padding: EdgeInsets.only(bottom: 10, top: 15),
              child: MyButton(
                text: "Hoàn tất",
                onTap: () {
                  completeDiagnose();
                  widget.onTap!();
                }
              ))
      ]);
    } else
      return LoadingPage();
  }
}
