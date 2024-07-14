import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:localstorage/localstorage.dart";
import 'package:tinyhealer/global.dart' as globals;
import "package:tinyhealer/pages/main_screen.dart";
import "package:tinyhealer/pages/register_form.dart";

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  bool isRegis = globals.registered;

  void initState(){
    super.initState();
    _waitForLoading();
  }

  Future<void> _waitForLoading() async {
    while (globals.isLoading) {
      await Future.delayed(Duration(milliseconds: 100)); // Adjust the delay as needed
    }
    // Loading is completed, call onComplete callback
    setState(() {
      globals.isLoading = false;
      isRegis = globals.registered;
    });
  }

  void signOut(){
    FirebaseAuth.instance.signOut();
    globals.registered = false;
    localStorage.setItem('EMAIL', "NONE");
    localStorage.setItem('PASS', "NONE");
  }

  void register(){
    setState(() {
      isRegis = true;
      globals.registered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!globals.isLoading){
      if (isRegis) {
        return MainScreen();
      }
      else{
        return RegisterForm(regis: register);
      }
    }
    else return Center(child: CircularProgressIndicator());
  }
}