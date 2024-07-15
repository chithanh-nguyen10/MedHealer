// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tinyhealer/components/text_field.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/components/squaretile.dart';
import 'package:tinyhealer/pages/forgot_password.dart';
import 'package:tinyhealer/services/auth_service.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  void dispose(){
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signIn() async{
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator()
        );
      }
    );

    try{
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text
      );
      Navigator.pop(context);
      globals.isLoading = true;
      DocumentSnapshot docSnapshot = await _firestore.collection('users').doc(usernameController.text).get();
      print("sdfdsfsdfdsffdsgsfdgf");
      bool data = docSnapshot.get('registered');
      print(data);
      globals.registered = data;
      globals.isLoading = false;
      
      if (globals.registered){
        localStorage.setItem('EMAIL', usernameController.text);
        localStorage.setItem('PASS', passwordController.text);
      }else{
        globals.email = usernameController.text;
        globals.pass = passwordController.text;
      }
    } on FirebaseAuthException catch (e){
      Navigator.pop(context);
      showMessage(e.code);
    }
    
  }

  void showMessage(String mess){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              mess,
              style: const TextStyle(color: Colors.white, fontSize: 19)
            )
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffdbdbdb),
      body: SafeArea(
        child: SingleChildScrollView(child:Center(
          child: Column(
            
            children: [
              const SizedBox(height: 40),

              // logo
              Image.asset(
                "lib/images/logo.png",
                width: min(200, currentWidth*0.3),
              ),


              const SizedBox(height: 30),


              // Welcome back
              Text(
                'Chào mừng đến với MedHealer',
                style: TextStyle(
                  color: const Color(0xff525254),
                  fontSize: currentWidth >= 600 ? 26 + 26 * ((currentWidth - 600)/600)  : 26,
                  fontWeight: FontWeight.bold
                )
              ),
              


              const SizedBox(height: 40),

              // Username
              MyTextField(
                controller: usernameController,
                hintText: "Email",
                obscureText: false,
                fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/500)  : 22,
              ),

              const SizedBox(height: 10),

              // Password
              MyTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
                fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/500)  : 22,
              ),


              const SizedBox(height: 15),

              // forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage()
                          )
                        );
                      },
                      child: Text(
                        'Bạn quên mật khẩu?',
                        style: TextStyle(color: Color(0xff6a6a6a), fontSize: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/350)  : 15),
                      )
                    )
                  ],
                ),
              ),


              const SizedBox(height: 30),

              // Btn Sign In
              MyButton(
                onTap: signIn,
                text: "Đăng nhập",
                fontSize: currentWidth >= 600 ? 20 + 20 * ((currentWidth - 600)/500)  : 20,
              ),


              const SizedBox(height: 50),

              // Google, Facebook
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey[600],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Hoặc tiếp tục với',
                        style: TextStyle(color: Colors.grey[700], fontSize: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/350)  : 15),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 50),


              // Google, facebook sign in btn
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // google button
                  SquareTile(
                    onTap: () => AuthService().signInWithGoogle(),
                    imagePath: 'lib/images/google.png',
                    height: currentWidth >= 600 ? 40 + 40 * ((currentWidth - 600)/350)  : 40
                  ),

                  // SizedBox(width: 25),

                  // facebook button
                  // SquareTile(
                  //   onTap: () => AuthService().signInWithFacebook(),
                  //   imagePath: 'lib/images/facebook.png'
                  // )
                ],
              ),


              const SizedBox(height: 50),


              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản?',
                    style: TextStyle(color: Colors.grey[700], fontSize: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/350)  : 15),
                  ),
                  SizedBox(width: currentWidth >= 600 ? 4 + 4 * ((currentWidth - 600)/200)  : 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/350)  : 15
                      ),
                    )
                  ),
                ],
              )
            ],
          )
        )
      )
    ));
  }
}