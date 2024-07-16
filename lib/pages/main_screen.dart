import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:firebase_auth/firebase_auth.dart";
import "package:localstorage/localstorage.dart";
import 'package:tinyhealer/global.dart' as globals;
import 'package:tinyhealer/pages/functional_pages/call_doctor.dart';
import 'package:tinyhealer/pages/functional_pages/diagnostic_history.dart';
import 'package:tinyhealer/pages/functional_pages/diagnostic_history_doctor.dart';

import 'package:tinyhealer/pages/functional_pages/profile.dart';
import 'package:tinyhealer/pages/functional_pages/diagnostic.dart';
import 'package:tinyhealer/pages/functional_pages/send_feedback.dart';
import 'package:tinyhealer/pages/functional_pages/settings.dart';
import 'package:tinyhealer/pages/functional_pages/loading_page.dart';
import 'package:tinyhealer/pages/functional_pages/find_hospital.dart';

import 'dart:core';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>  with TickerProviderStateMixin{
  var currentPage = DrawerSections.home;
  String title = "Trang chủ";
  bool isMenu = true;
  bool isLoading1 = true;
  bool isLoading2 = true;
  bool isLoading3 = true;
  bool isLoading4 = true;

  List<String> result = ["null"];

  void initState() {
    super.initState();
    print("dsfsdfdsf");
    setState(() {
      getUsersData();
      getData();
      getAnamData().then((_){
        setState((){
          isLoading3 = false;
        });
      });
      getfamilyAnamData();
      getSymptomData();
    });
  }

  Future<void> getUsersData() async {
    final user = FirebaseAuth.instance.currentUser!;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentSnapshot docSnapshot = await _firestore.collection('users').doc(user.email!).get();

    setState(() {
      globals.first_name = docSnapshot.get("first-name");
      globals.last_name = docSnapshot.get("last-name");
      globals.email = user.email!;
      globals.dob = docSnapshot.get("dob");
      globals.gender = docSnapshot.get("gender");
      globals.type = docSnapshot.get("type");
      String anam = docSnapshot.get("anamnesis");
      globals.anamnesis = anam.split(",");
      if (globals.anamnesis.length == 1 && globals.anamnesis[0] == "") globals.anamnesis.removeAt(0);
      print(globals.anamnesis);
      print(globals.familyanamnesis);
      if (globals.familyanamnesis.length == 1 && globals.familyanamnesis[0] == "") globals.familyanamnesis.removeAt(0);
      globals.avatar = docSnapshot.get("image");
      isLoading1 = false;
    });
    print("finish fetch name");
  }

  Future<void> getData() async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('health-problems');
    QuerySnapshot querySnapshot = await collectionReference.get();
    // ignore: unused_local_variable
    final List<List<String>> names = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String id = data['id'] as String;
      String name = data['name'] as String;
      globals.healthMatch[id] = toTitle(name);
      return [id, name];
    }).toList();
    isLoading2 = false;
  }

  Future<void> getAnamData() async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('anamnesis');
    QuerySnapshot querySnapshot = await collectionReference.get();
    // ignore: unused_local_variable
    final List<List<String>> names = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String id = data['id-A'] as String;
      String name = data['name-A'] as String;
      globals.anamHealthMatch[id] = toTitle(name);
      return [id, name];
    }).toList();
    // print(globals.anamnesis);
  }

  Future<void> getfamilyAnamData() async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('anamnesis-family');
    QuerySnapshot querySnapshot = await collectionReference.get();
    // ignore: unused_local_variable
    final List<List<String>> names = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String id = data['id-A'] as String;
      String name = data['name-A'] as String;
      globals.familyanamHealthMatch[id] = toTitle(name);
      return [id, name];
    }).toList();
  }

  Future<void> getSymptomData() async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('symptom');
    QuerySnapshot querySnapshot = await collectionReference.get();
    // ignore: unused_local_variable
    final List<List<String>> names = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String id = data['id'] as String;
      String name = data['name'] as String;
      globals.symptomMatch[id] = toTitle(name);
      return [id, name];
    }).toList();
    // print(globals.symptomMatch);
  }

  void onTap(){
    setState(() {
      currentPage = DrawerSections.diagnostic;
      this.title = "Chẩn đoán";
    });
  }

  void home(){
    setState(() {
      currentPage = DrawerSections.home;
      this.title = "Trang chủ";
    });
  }

  void navigate(DrawerSections section, String title){
    setState(() {
      if (section == DrawerSections.map) result = ["null"];
      currentPage = section;
      if (section != DrawerSections.settings || (section == DrawerSections.settings && globals.settingState == "default")) this.title = title;
      if (section != DrawerSections.settings) isMenu = true;
    });
  }

  void searchMap(List<String> res){
    setState(() {
      result = res;
      // print(result);
      currentPage = DrawerSections.map;
      this.title = "Tìm bệnh viên";
    });
  }

  void back(){
    setState(() {
      currentPage = DrawerSections.home;
      this.title = "Trang chủ";
    });
  }

  void changeMenu(String newTitle, bool newVal){
    setState(() {
      isMenu =newVal;
      this.title = newTitle;
    });
  }

  String toTitle(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  void signOut(){
    FirebaseAuth.instance.signOut();
    globals.registered = false;
    localStorage.setItem('EMAIL', "NONE");
    localStorage.setItem('PASS', "NONE");
    globals.first_name = "";
    globals.last_name = "";
    globals.email = "";
    globals.dob = "";
    globals.gender = "";
    globals.anamnesis = ["null"];
    globals.avatar = "";
    globals.isLoading = true;
    globals.healthMatch = {};
    globals.anamHealthMatch = {};
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    var container;  
    if (currentPage == DrawerSections.home) {
      if (globals.healthMatch != {} && globals.first_name != "" && globals.last_name != "" && globals.email != "" && globals.dob != "" && globals.gender != "" && globals.anamnesis != ["null"] && globals.avatar != "" && globals.anamHealthMatch != {}  && globals.familyanamHealthMatch != {} && !isLoading3 && globals.type != "") {
        container = ProfilePage(
          info: [globals.first_name, globals.last_name, globals.email, globals.dob, globals.gender],
          onTap: onTap,
        );
      } else {
        container = LoadingPage();
      }
    } else if (currentPage == DrawerSections.diagnostic) {
      container = DiagnosticPage(onTap: home, searchMap: searchMap,);
    } else if (currentPage == DrawerSections.settings) {
      container = SettingsPage(
        changeMenu: changeMenu,
      );
      // container = Text("test");
    } else if (currentPage == DrawerSections.send_feedback) {
      if (globals.healthMatch != {} && globals.first_name != "" && globals.last_name != "" && globals.email != "" && globals.dob != "" && globals.gender != "" && globals.anamnesis != []){
        container = FeedbackPage(
          back: back
        );
      } else {
        container = LoadingPage();
      }
    } else if (currentPage == DrawerSections.map) {
      container = FindHospital(
        result: result
      );
    } else if (currentPage == DrawerSections.history) {
      if (globals.symptomMatch != {}){
        if (globals.type == "normal") container = DiagnosticHistory(
          changeMenu: changeMenu,
        ); else container = DiagnosticHistoryDoctor(
          changeMenu: changeMenu,
        );
      }
      else container = LoadingPage();
    } else if (currentPage == DrawerSections.doctor) {
      container = CallDoctor();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xff228af4),
        title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 25)),
        iconTheme: IconThemeData(color: Colors.white),
        leading:  (currentWidth <= 600 || !isMenu) ? Builder(
          builder: (context) => IconButton(
            icon: isMenu ? Icon(Icons.menu) : Icon(Icons.arrow_back), // Custom icon for the drawer
            onPressed: () {
              if (isMenu) Scaffold.of(context).openDrawer();
              else{
                if (currentPage == DrawerSections.settings){
                  setState((){
                    isMenu = true;
                    globals.settingState = "default";
                    this.title = "Cài đặt";
                  });
                } else if (currentPage == DrawerSections.history){
                  globals.changeHistoryState("default");
                  setState((){
                    isMenu = true;
                    this.title = "Lịch sử chẩn đoán";
                  });
                }
              }
            },
          ),
        ): null,
      ),
      body: Row(
        children: [
          if (currentWidth > 600) Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey[600]!, // Border color
                  width: 0.7, // Border width
                ),
              ),
            ),
            child: Container(
              padding: EdgeInsets.only(
                top: 15,
              ),
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height:25),
                  menuItem2(1, "Trang chủ", Icons.home,
                    currentPage == DrawerSections.home ? true : false, () => navigate(DrawerSections.home, "Trang chủ")),
                  menuItem2(2, "Chẩn đoán", Icons.search,
                    currentPage == DrawerSections.diagnostic ? true : false, () => navigate(DrawerSections.diagnostic, "Chẩn đoán")),
                  Divider(),
                  menuItem2(7, "Lịch sử chẩn đoán", Icons.history,
                      currentPage == DrawerSections.history ? true : false, () => navigate(DrawerSections.history, "Lịch sử chẩn đoán")),
                  menuItem2(6, "Tìm bệnh viện", Icons.local_hospital_rounded,
                      currentPage == DrawerSections.map ? true : false, () => navigate(DrawerSections.map, "Tìm bệnh viện")),
                  if (globals.type == "normal") menuItem2(8, "Liên hệ bác sĩ", Icons.add_call,
                      currentPage == DrawerSections.doctor ? true : false, () => navigate(DrawerSections.doctor, "Tìm bệnh viện")),
                  Divider(),
                  menuItem2(3, "Cài đặt", Icons.settings_outlined,
                    currentPage == DrawerSections.settings ? true : false, () => navigate(DrawerSections.settings, "Cài đặt")),
                  menuItem2(4, "Gửi phản hồi", Icons.feedback_outlined,
                    currentPage == DrawerSections.send_feedback ? true : false, () => navigate(DrawerSections.send_feedback, "Gửi phản hồi")),
                  Divider(),
                  menuItem2(5, "Đăng xuất", Icons.logout_outlined,
                    currentPage == DrawerSections.sign_out ? true : false, signOut, textColor: Colors.red)
                ]
              )
            ),
             
          ),
          Expanded(child: container),
        ],
      ),
      
      drawer: currentWidth <= 600 ? Container(color: Colors.white, child: Drawer(
        child: SingleChildScrollView(
            child: Column(
              children: [
                // MyHeaderDrawer(),
                MyDrawerList(),
              ],
            ),
        )),
      ) : null,
    );
  }

  Widget MyDrawerList() {
    return Container(
      padding: EdgeInsets.only(
        top: 15,
      ),
      color: Colors.white,
      child: Column(
        // shows the list of menu drawer
        children: [
          SizedBox(height:25),
          menuItem(1, "Trang chủ", Icons.home,
              currentPage == DrawerSections.home ? true : false),
          menuItem(2, "Chẩn đoán", Icons.search,
              currentPage == DrawerSections.diagnostic ? true : false),
          Divider(),
          menuItem(7, "Lịch sử chẩn đoán", Icons.history,
              currentPage == DrawerSections.history ? true : false),
          menuItem(6, "Tìm bệnh viên", Icons.local_hospital_rounded,
              currentPage == DrawerSections.map ? true : false),
          if (globals.type == "normal") menuItem(8, "Liên hệ bác sĩ", Icons.add_call,
              currentPage == DrawerSections.doctor ? true : false),
          Divider(),
          menuItem(3, "Cài đặt", Icons.settings_outlined,
              currentPage == DrawerSections.settings ? true : false),
          menuItem(4, "Gửi phản hồi", Icons.feedback_outlined,
              currentPage == DrawerSections.send_feedback ? true : false),
          Divider(),
          menuItem(5, "Đăng xuất", Icons.logout_outlined,
              currentPage == DrawerSections.sign_out ? true : false, textColor: Colors.red),
          
          
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, bool selected, {Color textColor = Colors.black}) {
    return Material(
      color: selected ? Colors.grey[300] : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          setState(() {
            if (id == 1) {
              currentPage = DrawerSections.home;
              this.title = "Trang chủ";
              isMenu = true;
            } else if (id == 2) {
              currentPage = DrawerSections.diagnostic;
              this.title = "Chẩn đoán";
              isMenu = true;
            } else if (id == 3) {
              currentPage = DrawerSections.settings;
              this.title = "Cài đặt";
              isMenu = true;
            } else if (id == 4) {
              currentPage = DrawerSections.send_feedback;
              this.title = "Gửi phản hổi";
              isMenu = true;
            } else if (id == 5) {
              signOut();
            } else if (id == 6){
              result = ["null"];
              currentPage = DrawerSections.map;
              this.title = "Tìm bệnh viện";
              isMenu = true;
            } else if (id == 7){
              currentPage = DrawerSections.history;
              this.title = "Lịch sử chẩn đoán";
              isMenu = true;
            } else if (id == 8){
              currentPage = DrawerSections.doctor;
              this.title = "Liên hệ bác sĩ";
              isMenu = true;
            }
          });
        },
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 30,
                  color: textColor,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 19,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuItem2(int id, String title, IconData icon, bool selected, VoidCallback onTap, {Color textColor = Colors.black}) {
    return Material(
      color: selected ? Colors.grey[300] : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 35,
                  color: textColor,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 23,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}

enum DrawerSections {
  home,
  diagnostic,
  settings,
  send_feedback,
  sign_out,
  history,
  map,
  doctor
}
