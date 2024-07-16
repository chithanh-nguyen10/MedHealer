import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/components/text_field.dart';
import 'package:tinyhealer/global.dart' as globals;

class ChangeInfo extends StatefulWidget {
  @override
  _ChangeInfoState createState() => _ChangeInfoState();
}

class _ChangeInfoState extends State<ChangeInfo> {
  final firstnameController = TextEditingController(text: globals.first_name);
  final lastnameController = TextEditingController(text: globals.last_name);
  String dob = globals.dob;
  final dobController = TextEditingController(text: globals.dob);
  final emailController = TextEditingController(text: globals.email);
  final DateTime now = DateTime.now();
  List<String> extractDate = [];
  List<String> items = ["Nam", "Nữ"];
  String? selectedItem = "Nam";

  @override
  void initState() {
    super.initState();
    extractDate = dob.split("/");
    selectedItem = globals.gender;
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    dobController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void pickdate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime(int.parse(extractDate[2]), int.parse(extractDate[1]), int.parse(extractDate[0])),
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

  void update() async{
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

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator()
        );
      }
    );

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Map<String, dynamic> data = {
      "first-name": firstnameController.text,
      "last-name": lastnameController.text,
      "dob": dob,
      "gender": selectedItem,
    };
    await _firestore.collection('users').doc(globals.email).update(data);
    globals.first_name = firstnameController.text;
    globals.last_name = lastnameController.text;
    globals.dob = dob;
    globals.gender = selectedItem == "Nam" ? "Male" : "Female";

    Navigator.pop(context);
    showMessage("Cập nhật thông tin thành công.");
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
    
    return Stack(children: [Positioned(top: 0, bottom: 0, left: 0, right: 0,child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 20),
                  CircleAvatar(
                    radius: currentWidth >= 600 ? 45 + 45 * ((currentWidth - 600)/1200)  : 45,
                    backgroundImage: NetworkImage(globals.avatar)
                  ),
                  SizedBox(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(globals.last_name + " " + globals.first_name, style: TextStyle(fontSize:currentWidth >= 600 ? 19 + 19 * ((currentWidth - 600)/600)  : 19, fontWeight: FontWeight.bold)),
                      Text(globals.email, style: TextStyle(fontSize:currentWidth >= 600 ? 16 + 16 * ((currentWidth - 600)/600)  : 16)),
                    ],
                  )
                ]
              ),

              Divider(),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text(
                      "Email",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/900)  : 22,
                        fontFamily: "Roboto"
                      ),
                    ),
                    Icon(Icons.lock_outline_rounded)
                  ]
                )
              ),
              const SizedBox(height: 5),
              // Email
              MyTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
                enabledText: false,
              ),

              SizedBox(height: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/600)  : 15),

              Padding(padding: EdgeInsets.only(left: 25),child: Row(children:[Text("Họ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/900)  : 22, fontFamily: "Roboto"),)])),
              const SizedBox(height: 5),
              // Last Name
              MyTextField(
                controller: lastnameController,
                hintText: "Họ (VD: Nguyễn)",
                obscureText: false,
              ),

              SizedBox(height: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/600)  : 15),

              Padding(padding: EdgeInsets.only(left: 25),child: Row(children:[Text("Tên", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/900)  : 22, fontFamily: "Roboto"),)])),
              const SizedBox(height: 5),

              // First Name
              MyTextField(
                controller: firstnameController,
                hintText: "Tên (VD: Văn A)",
                obscureText: false,
              ),


              SizedBox(height: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/600)  : 15),

              Padding(padding: EdgeInsets.only(left: 25),child: Row(children:[Text("Giới tính sinh học", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/900)  : 22, fontFamily: "Roboto"),)])),
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
                      )
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff7b7b7b),
                    ),
                    value: selectedItem,
                    items: items.map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: TextStyle(fontSize:22, fontWeight: FontWeight.w600,)
                      )
                    )).toList(),
                    onChanged: (item) => setState(() => selectedItem = item)
                  )
                )
              ),
              

              SizedBox(height: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/600)  : 15),

              Padding(padding: EdgeInsets.only(left: 25),child: Row(children:[Text("Ngày sinh", style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/900)  : 22, fontFamily: "Roboto"),)])),
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
                          fontSize: 22,
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
                onTap: update,
                text: "Cập nhật thông tin",
              ),
            ],
          )
      )
    ))]);
  }
}