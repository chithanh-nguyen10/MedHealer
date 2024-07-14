import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'package:tinyhealer/pages/functional_pages/change_avatar.dart';
import 'package:tinyhealer/pages/functional_pages/change_info.dart';


class SettingsPage extends StatefulWidget {
  final Function(String, bool) changeMenu;
  SettingsPage({required this.changeMenu});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
    globals.settingState = "default";
  }


  void changeState(String newState) {
    setState(() {
      globals.settingState = newState;
      widget.changeMenu(newState == "info" ? "Thông tin cá nhân" : "Đổi ảnh đại diện", false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (globals.settingState == "default"){
      return Column(
          children: [
            menuItem(
              "Thông tin cá nhân",
              Icons.account_circle_outlined,
              Colors.black,
              () {
                changeState("info");
              }
            ),

            Divider(),

            menuItem(
              "Đổi hình đại diện",
              Icons.add_a_photo,
              Colors.black,
              () {
                changeState("avatar");
              }
            ),
            
            // menuItemwithSwitch(
            //   "Chế độ tối",
            //   Icons.dark_mode_outlined,
            //   Colors.black,
            //   null
            // ),
          ],
        );
    } else if (globals.settingState == "info"){
      return ChangeInfo();
    } else if (globals.settingState == "avatar"){
      return ChangeAvatar();
    } else{
      return Center(child: Text("Đã xảy ra lỗi!", style: TextStyle(fontSize: 19)));
    }
  }

  Widget menuItem(String title, IconData icon, Color textColor, Function()? onTap){
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          children: [
            Padding(  
              padding: EdgeInsets.only(left: 25, right: 20),
              child:Icon(
                icon,
                size: 30,
                color: textColor,
              )
            ),
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 19,
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget menuItemwithSwitch(String title, IconData icon, Color textColor, Function()? onTap){
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          children: [
            Padding(  
              padding: EdgeInsets.only(left: 25, right: 20),
              child:Icon(
                icon,
                size: 30,
                color: textColor,
              )
            ),
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 19,
                ),
              )
            ),
            Switch.adaptive(
              value: globals.isDark,
              activeColor: Colors.black,
              focusColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  globals.isDark = value;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}