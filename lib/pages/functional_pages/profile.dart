import 'package:flutter/material.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'package:tinyhealer/pages/functional_pages/anamnesis_display/only_anamnesis.dart';
import 'package:tinyhealer/pages/functional_pages/anamnesis_display/only_family_anamnesis.dart';

class ProfilePage extends StatefulWidget {
  final List<String> info;
  final Function()? onTap;

  ProfilePage({required this.info, required this.onTap});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>  with SingleTickerProviderStateMixin{

  String displayName = "";
  String title = "";
  late bool check1, check2, check3, check4;
  late TabController _tabController;

  @override
  void initState(){
    super.initState();
    check1 = globals.anamnesis.isNotEmpty && globals.familyanamnesis.isEmpty;
    check2 = globals.anamnesis.isEmpty && globals.familyanamnesis.isNotEmpty;
    check3 = globals.anamnesis.isNotEmpty && globals.familyanamnesis.isNotEmpty;
    check4 = globals.anamnesis.isEmpty && globals.familyanamnesis.isEmpty;
    if (check1) title = "Tiền sử bệnh cá nhân";
    if (check2) title = "Tiền sử bệnh gia đình";
    if (check3) title = "Tiền sử bệnh";
    if (check4) title = "";
    List<String> words1 = widget.info[0].split(" ");
    List<String> words2 = widget.info[1].split(" ");
    displayName = words1[words1.length-1] + " " + words2[0];
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: 20),
            CircleAvatar(
              radius: currentWidth >= 600 ? 45 + 45 * ((currentWidth - 600)/1200)  : 45,
              backgroundColor: Colors.grey[500],
              child: CircleAvatar(
                radius: currentWidth >= 600 ? 43.3 + 43.3 * ((currentWidth - 600)/1200)  : 43.3,
                backgroundImage: NetworkImage(globals.avatar)
              )
            ),
            SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(globals.last_name + " " + globals.first_name, style: TextStyle(fontSize:currentWidth >= 600 ? 19 + 19 * ((currentWidth - 600)/600)  : 19, fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  if (globals.type == "doctor") Icon(color: Colors.black, Icons.medical_services_outlined)
                ],),
                Text(globals.email, style: TextStyle(fontSize:currentWidth >= 600 ? 16 + 16 * ((currentWidth - 600)/600)  : 16)),
              ],
            )
          ]
        ),
        SizedBox(height: 8),
        Divider(thickness: 2),
        SizedBox(height: 8),

        Center(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: currentWidth >= 600 ? 26 + 26 * ((currentWidth - 600)/600)  : 26, fontFamily: "Roboto"),)),

        if (check1) Expanded(child: OnlyAnamnesis())
        else if (check2) Expanded(child: OnlyFamilyAnamnesis()),

        if (check3) const SizedBox(height: 20),

        if (check3) Container(
          child: Center(
            child: TabBar(
              controller: _tabController,
              labelStyle: TextStyle(
                fontSize: currentWidth >= 600
                    ? 22 + 22 * ((currentWidth - 600) / 1800)
                    : 22,
              ),
              dividerColor: Colors.grey,
              isScrollable: false,
              tabs: [
                Tab(text: 'Cá nhân'),
                Tab(text: 'Gia đình'),
              ],
            ),
          ),
        ),

        if (check3) Expanded(child:Container(
          width: double.maxFinite,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBarView(
              controller: _tabController,
              children: [
                OnlyAnamnesis(),
                OnlyFamilyAnamnesis(),
              ]
            ),
          ),
        )),

        if (check4) Expanded(child:Container()),


        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: MyButton(
            text: "Chẩn đoán bệnh ngay",
            onTap: widget.onTap,
          )
        )
      ],
    );
  }
}