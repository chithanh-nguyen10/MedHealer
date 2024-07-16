// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tinyhealer/components/text_field.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'dart:math';

class RegisterForm extends StatefulWidget {
  final Function()? regis;
  const RegisterForm({super.key, required this.regis});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm>  with TickerProviderStateMixin{
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();

  final search1Controller = TextEditingController();
  final search2Controller = TextEditingController();

  String dob = "DD/MM/YYYY";
  final dobController = TextEditingController(text: "DD/MM/YYYY");
  final DateTime now = DateTime.now();
  List<String> items = ["Nam", "Nữ"];
  String? selectedItem = "Nam";
  late TabController _tabController;
  late TabController _familytabController;
  bool isSearch = false;
  bool isSearch2 = false;
  List<List<bool>> checkboxValuesList = [];
  List<String> tabList = [];
  List<List<String>> checkListData = [];
  List<List<String>> checklistItemsList = [];
  List<List<String>> idData = [];
  Map<String, int> mp = {};
  String mode = "INFO";
  List<String> results = [];
  List<bool> checkBoxValue = [];
  List<List<int>> coords = [];

  List<String> familyresults = [];
  List<bool> familycheckBoxValue = [];
  List<List<int>> familycoords = [];

  Color _labelcolor = Colors.grey;
  Color _labelcolor2 = Colors.grey;

  List<List<bool>> familycheckboxValuesList = [];
  List<String> familytabList = [];
  List<List<String>> familycheckListData = [];
  List<List<String>> familychecklistItemsList = [];
  List<List<String>> familyidData = [];
  

  @override
  void initState()  {
    super.initState();

    fetchNames().then((_) {
      checklistItemsList = checkListData;
      _tabController = TabController(length: checklistItemsList.length, vsync: this);
      checkboxValuesList = List.generate(
        checklistItemsList.length,
        (outerIndex) => List.generate(
          checklistItemsList[outerIndex].length,
          (innerIndex) => false,
        ),
      );
      fetchFamilyNames().then((_){
        familychecklistItemsList = familycheckListData;
        _familytabController = TabController(length: familychecklistItemsList.length, vsync: this);
        familycheckboxValuesList = List.generate(
          familychecklistItemsList.length,
          (outerIndex) => List.generate(
            familychecklistItemsList[outerIndex].length,
            (innerIndex) => false,
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    dobController.dispose();
    _tabController.dispose();
    _familytabController.dispose();
    search1Controller.dispose();
    search2Controller.dispose();
    super.dispose();
  }

  Future<void> fetchNames() async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('anamnesis');
    QuerySnapshot querySnapshot = await collectionReference.get();

    int index = 0;
    // ignore: unused_local_variable
    final List<List<String>> names = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String id = data['id-A'] as String;
      String name = data['name-A'] as String;
      String type = id.substring(0, ffnci(id));
      if (mp[type] == null){
        mp[type] = index;
        index++;
        checkListData.add([]);
        idData.add([]);
        tabList.add(globals.anamnesisTypes[type] != null ? globals.anamnesisTypes[type]! : type);
      }
      checkListData[mp[type]!].add(toTitle(name));
      idData[mp[type]!].add(id);
      return [id, name];
    }).toList();
  }

  Future<void> fetchFamilyNames() async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('anamnesis-family');
    QuerySnapshot querySnapshot = await collectionReference.get();

    int index = 0;
    mp.clear();
    // ignore: unused_local_variable
    final List<List<String>> names = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String id = data['id-A'] as String;
      String name = data['name-A'] as String;
      String type = id.substring(0, ffnci(id));
      if (mp[type] == null){
        mp[type] = index;
        index++;
        familycheckListData.add([]);
        familyidData.add([]);
        familytabList.add(globals.familyanamnesisTypes[type]!);
      }
      familycheckListData[mp[type]!].add(toTitle(name));
      familyidData[mp[type]!].add(id);
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

  void pickdate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, 12, 31),
    ).then((date) {
      if (date != null){
        String time = date.toString();
        String year = time.substring(0, 4);
        String month = time.substring(5, 7);
        String day = time.substring(8, 10);
        dob = day + "/" + month + '/' + year;
      }
      setState(() {
        dobController.text = dob;
      });
    });
  }

  void completeRegister() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator()
        );
      }
    );

    String anamnesis = "";
    for (int i = 0; i < checklistItemsList.length; ++i){
      for (int j = 0; j < checklistItemsList[i].length; ++j){
        if (checkboxValuesList[i][j] ){
          anamnesis+=idData[i][j];
          anamnesis+=",";
        }
      }
    }

    String familyanamnesis = "";
    for (int i = 0; i < familychecklistItemsList.length; ++i){
      for (int j = 0; j < familychecklistItemsList[i].length; ++j){
        if (familycheckboxValuesList[i][j] ){
          familyanamnesis+=familyidData[i][j];
          familyanamnesis+=",";
        }
      }
    }

    if (!anamnesis.isEmpty) anamnesis = anamnesis.substring(0, anamnesis.length-1);
    if (!familyanamnesis.isEmpty) familyanamnesis = familyanamnesis.substring(0, familyanamnesis.length-1);

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser!;
    Map<String, dynamic> data = {
      "first-name": firstnameController.text,
      "last-name": lastnameController.text,
      "dob": dob,
      "gender": selectedItem == "Nam" ? "Male" : "Female",
      "registered" : true,
      "anamnesis" : anamnesis,
      "family-anamnesis" : "",
      "type" : "normal",
      "image" : "https://firebasestorage.googleapis.com/v0/b/tinyhealer-30c94.appspot.com/o/default-avatar.png?alt=media&token=b702495f-f559-4b3b-8075-af6fbe9cc3f3"
    };
    await _firestore.collection('users').doc(user.email!).set(data);
    Navigator.pop(context);
    localStorage.setItem('EMAIL', globals.email);
    localStorage.setItem('PASS', globals.pass);
    widget.regis!();

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

  void toggleCheckbox(int tabIndex, int itemIndex, bool value) {
    setState(() {
      checkboxValuesList[tabIndex][itemIndex] = value;
    });
  }

  void toggleCheckboxfamily(int tabIndex, int itemIndex, bool value) {
    setState(() {
      familycheckboxValuesList[tabIndex][itemIndex] = value;
    });
  }

  void next() {
    if (firstnameController.text.length == 0){
      showMessage("Hãy điền tên của bạn");
      return;
    }
    if (lastnameController.text.length == 0){
      showMessage("Hãy điền họ của bạn");
      return;
    }
    if (dob == "DD/MM/YYYY"){
      showMessage("Hãy điền ngày sinh của bạn");
      return;
    }
    setState(() {
      mode = "ANAM";
    });
  }

  void next2(){
    setState(() {
      mode = "ANAMFAMILY";
    });
  }

  void back() {
    setState(() {
      mode = "INFO";
    });
  }

  void back2() {
    setState(() {
      mode = "ANAM";
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    if (mode == "ANAM") return Scaffold(
      backgroundColor: const Color(0xffdbdbdb),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // logo
              Image.asset(
                "lib/images/logo.png",
                width: min(200, currentWidth*0.3),
              ),


              const SizedBox(height: 20),

              Text(
                'Chọn các bệnh mà bạn có tiền sử bị',
                style: TextStyle(
                  color: const Color(0xff525254),
                  fontSize: currentWidth >= 600 ? 26 + 26 * ((currentWidth - 600)/600)  : 22,
                  fontWeight: FontWeight.bold
                )
              ),

              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                    style: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18),
                    // focusNode: _focusNode,
                    controller: search1Controller,
                    decoration: InputDecoration(
                      labelText: "Tìm kiếm",
                      suffixIcon: Icon(Icons.search, color: Colors.grey[400]!, size: 30),
                      labelStyle: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18, color: _labelcolor),
                    ),
                    cursorColor: Colors.grey,
                    onChanged: (text) {
                      setState(() {
                        if (text == ""){
                          isSearch = false;
                          results = [];
                          checkBoxValue = [];
                          coords = [];
                        }
                        else{
                          isSearch = true;
                          results = [];
                          checkBoxValue = [];
                          coords = [];
                          String task = text.toLowerCase();
                          for (int i = 0;i< checklistItemsList.length;++i){
                            for (int j = 0;j<checklistItemsList[i].length;++j){
                              if (checklistItemsList[i][j].toLowerCase().contains(task)){
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
              const SizedBox(height: 20),
              
              if(!isSearch) Container(
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabController,
                  labelStyle: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1800)  : 17),
                  isScrollable: true,
                  tabs: List.generate(
                    checklistItemsList.length,
                    (index) => Tab(text: tabList[index]),
                  ),
                ),
               ),
              ),

              if(!isSearch)Expanded(child:Container(
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
                        return CheckboxListTile(
                          value: checkboxValuesList[tabIndex][itemIndex],
                          onChanged: (value) {
                            toggleCheckbox(tabIndex, itemIndex, value ?? false);
                          },
                          title: Text(
                            checklistItemsList[tabIndex][itemIndex],
                            style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                          ),
                        );
                      },
                    ),
                  )
                  
                ),
               ),
              )),

              if (isSearch)
              Expanded(
                child: (results.length != 0) ? ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      value: checkBoxValue[index],
                      onChanged: (value) {
                        setState(() {
                          checkBoxValue[index] = value ?? false;
                          var coord = coords[index];
                          checkboxValuesList[coord[0]][coord[1]] = value ?? false;
                        });
                      },
                      title: Text(
                        results[index],
                        style: TextStyle(
                          fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600) / 1000) : 17,
                        ),
                      ),
                    );
                  },
                ) : Center(
                  child: Container(
                    child: Text(
                      "Không tìm thấy kết quả",
                      style: TextStyle(fontSize: currentWidth >= 600 ? 20 + 20 * ((currentWidth - 600) / 1000) : 20),
                    ),
                  )
                ),
              ),
              

              const SizedBox(height: 20),

              // Btn Sign In
              Padding(padding: EdgeInsets.only(bottom: 10, top: 15), child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Expanded(child:
                MyButton(
                onTap: back,
                text: "Quay lại"
              )),
              Expanded(child: MyButton(
                onTap: completeRegister,
                text: "Hoàn tất"
              ))])),
            ]
        )
      )
    ));
    else if (mode == "ANAMFAMILY")return Scaffold(
      backgroundColor: const Color(0xffdbdbdb),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // logo
              Image.asset(
                "lib/images/logo.png",
                width: min(200, currentWidth*0.3),
              ),


              const SizedBox(height: 20),
              Text(
                'Chọn các bệnh mà gia đình bạn có tiền sử bị',
                style: TextStyle(
                  color: const Color(0xff525254),
                  fontSize: currentWidth >= 600 ? 24 + 24 * ((currentWidth - 600)/600)  : 18,
                  fontWeight: FontWeight.bold
                )
              ),

              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                    style: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18),
                    // focusNode: _focusNode2,
                    controller: search2Controller,
                    decoration: InputDecoration(
                      labelText: "Tìm kiếm",
                      suffixIcon: Icon(Icons.search, color: Colors.grey[400]!, size: 30),
                      labelStyle: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18, color: _labelcolor2),
                    ),
                    cursorColor: Colors.grey,
                    onChanged: (text) {
                      setState(() {
                        if (text == ""){
                          isSearch2 = false;
                          familyresults = [];
                          familycheckBoxValue = [];
                          familycoords = [];
                        }
                        else{
                          isSearch2 = true;
                          familyresults = [];
                          familycheckBoxValue = [];
                          familycoords = [];
                          String task = text.toLowerCase();
                          for (int i = 0;i< familychecklistItemsList.length;++i){
                            for (int j = 0;j<familychecklistItemsList[i].length;++j){
                              if (familychecklistItemsList[i][j].toLowerCase().contains(task)){
                                familyresults.add(familychecklistItemsList[i][j]);
                                familycheckBoxValue.add(familycheckboxValuesList[i][j]);
                                familycoords.add([i, j]);
                              }
                            }
                          }
                        }
                      });
                    },
                ),
              ),
              const SizedBox(height: 20),

              if(!isSearch2)Container(
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _familytabController,
                  labelStyle: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1800)  : 17),
                  isScrollable: true,
                  tabs: List.generate(
                    familychecklistItemsList.length,
                    (index) => Tab(text: familytabList[index]),
                  ),
                ),
               ),
              ),

              if(!isSearch2)Expanded(child:Container(
              width: double.maxFinite,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBarView(
                  controller: _familytabController,
                  children: List.generate(
                    familychecklistItemsList.length,
                    (tabIndex) => ListView.builder(
                      itemCount: familychecklistItemsList[tabIndex].length,
                      itemBuilder: (context, itemIndex) {
                        return CheckboxListTile(
                          value: familycheckboxValuesList[tabIndex][itemIndex],
                          onChanged: (value) {
                            toggleCheckboxfamily(tabIndex, itemIndex, value ?? false);
                          },
                          title: Text(
                            familychecklistItemsList[tabIndex][itemIndex],
                            style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                          ),
                        );
                      },
                    ),
                  )
                  
                ),
               ),
              )),

              if (isSearch2)
              Expanded(
                child: (familyresults.length != 0) ? ListView.builder(
                  itemCount: familyresults.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      value: familycheckBoxValue[index],
                      onChanged: (value) {
                        setState(() {
                          familycheckBoxValue[index] = value ?? false;
                          var coord = familycoords[index];
                          familycheckboxValuesList[coord[0]][coord[1]] = value ?? false;
                        });
                      },
                      title: Text(
                        familyresults[index],
                        style: TextStyle(
                          fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600) / 1000) : 17,
                        ),
                      ),
                    );
                  },
                ) : Center(
                  child: Container(
                    child: Text(
                      "Không tìm thấy kết quả",
                      style: TextStyle(fontSize: currentWidth >= 600 ? 20 + 20 * ((currentWidth - 600) / 1000) : 20),
                    ),
                  )
                ),
              ),

              Padding(padding: EdgeInsets.only(bottom: 10, top: 15), child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Expanded(child:
                MyButton(
                onTap: back2,
                text: "Back"
              )),
              Expanded(child: MyButton(
                onTap: completeRegister,
                text: "Register"
              ))])),
            ]
        )
      )
    ));
    else return Scaffold(
      backgroundColor: const Color(0xffdbdbdb),
      body: SafeArea(
        child: SingleChildScrollView(child:Center(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // logo
              Image.asset(
                "lib/images/logo.png",
                width: min(200, currentWidth*0.28),
              ),


              const SizedBox(height: 20),


              // Welcome back
              Text(
                'Điền vào để hoàn tất đăng ký',
                style: TextStyle(
                  color: const Color(0xff525254),
                  fontSize: currentWidth >= 600 ? 26 + 26 * ((currentWidth - 600)/600)  : 26,
                  fontWeight: FontWeight.bold
                )
              ),


              const SizedBox(height: 20),

              Padding(padding: EdgeInsets.only(left: 25),child: Row(children:[Text("Họ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 25 + 25 * ((currentWidth - 600)/600)  : 25, fontFamily: "Roboto"),)])),
              const SizedBox(height: 5),
              // Last Name
              MyTextField(
                controller: lastnameController,
                hintText: "Họ (VD: Nguyễn)",
                obscureText: false,
                fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/500)  : 22,
              ),
              

              SizedBox(height: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/600)  : 15),

              Padding(padding: EdgeInsets.only(left: 25),child: Row(children:[Text("Tên", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 25 + 25 * ((currentWidth - 600)/600)  : 25, fontFamily: "Roboto"),)])),
              const SizedBox(height: 5),

              // First Name
              MyTextField(
                controller: firstnameController,
                hintText: "Tên (VD: Văn A)",
                obscureText: false,
                fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/500)  : 22,
              ),
              


              SizedBox(height: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/600)  : 15),

              Padding(padding: EdgeInsets.only(left: 25),child: Row(children:[Text("Giới tính sinh học", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 25 + 25 * ((currentWidth - 600)/600)  : 25, fontFamily: "Roboto"),)])),
              const SizedBox(height: 5),
  
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  color: Colors.grey.shade200,
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      enabledBorder:  OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        borderSide: BorderSide(width: 1.5, color: Colors.white),
                        
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        borderSide: BorderSide(width: 1.5, color: Colors.white)
                      ),
                    ),
                    style: TextStyle(
                      fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/500)  : 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff7b7b7b),
                    ),
                    value: selectedItem,
                    items: items.map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: TextStyle(fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/500)  : 22, fontWeight: FontWeight.w600,),
                      )
                    )).toList(),
                    onChanged: (item) => setState(() => selectedItem = item)
                  )
                )
              ),


              SizedBox(height: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/600)  : 15),

              Padding(padding: EdgeInsets.only(left: 25),child: Row(children:[Text("Ngày sinh", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 25 + 25 * ((currentWidth - 600)/600)  : 25, fontFamily: "Roboto"),)])),
              const SizedBox(height: 5),

              GestureDetector(
                onTap: () {
                  pickdate(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: dobController,
                        enabled: false,
                        style: TextStyle(
                          fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/500)  : 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff7b7b7b),
                        ),
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          disabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                        ),
                      ),
                      Positioned(
                        right: 20,
                        child: Icon(Icons.calendar_month)
                      ),
                    ],
                  )
                )
              ),

              SizedBox(height:30),

              // Btn Sign In
              MyButton(
                onTap: next,
                text: "Tiếp tục",
                fontSize: currentWidth >= 600 ? 20 + 20 * ((currentWidth - 600)/500)  : 20,
              ),
            ]
        )
      )
    )));
  }
}