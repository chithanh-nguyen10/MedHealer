import 'package:flutter/material.dart';
import 'package:tinyhealer/pages/login_page.dart';
import 'package:tinyhealer/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool isLogin = true;

  void toggle() {
    setState(() {
      isLogin = !isLogin;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLogin){
      return LoginPage(
        onTap: toggle
      );
    }
    else{
      return RegisterPage(
        onTap: toggle
      );
    }
  }
}