import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tinyhealer/components/text_field.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/components/squaretile.dart';
import 'package:tinyhealer/services/auth_service.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'dart:math';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose(){
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void signUp() async{
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator()
        );
      }
    );

    try{
      if (passwordController.text == confirmPasswordController.text){
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usernameController.text,
          password: passwordController.text
        );
        Navigator.pop(context);
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;
        globals.registered = false;
        globals.isLoading = false;
        Map<String, dynamic> data = {
          "registered": false,
        };
        await _firestore.collection('users').doc(usernameController.text).set(data);
        // localStorage.setItem('EMAIL', usernameController.text);
        // localStorage.setItem('PASS', passwordController.text);
      }
    } on FirebaseAuthException catch (e){
       Navigator.pop(context);
      if(e.code == "email-already-in-use"){
        showMessage("Email đã được sử dụng");
      }
      else showMessage(e.code);
    }

    if (passwordController.text != confirmPasswordController.text) showMessage("Mật khẩu không khớp!");
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
                width: min(200, currentWidth*0.28),
              ),


              const SizedBox(height: 30),


              // Welcome back
              Text(
                'Tạo tài khoản',
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
                hintText: "Mật khẩu",
                obscureText: true,
                fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/500)  : 22,
              ),

              const SizedBox(height: 10),

              // Confirm Password
              MyTextField(
                controller: confirmPasswordController,
                hintText: "Nhập lại mật khẩu",
                obscureText: true,
                fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/500)  : 22,
              ),


              const SizedBox(height: 30),

              // Btn Sign In
              MyButton(
                onTap: signUp,
                text: "Đăng ký",
                fontSize: currentWidth >= 600 ? 20 + 20 * ((currentWidth - 600)/500)  : 20,
              ),


              const SizedBox(height: 50),

              // Google, Apple
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


              const SizedBox(height: 40),


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

                  // // facebook button
                  // SquareTile(
                  //   onTap: () => AuthService().signInWithFacebook(),
                  //   imagePath: 'lib/images/facebook.png'
                  // )
                ],
              ),


              const SizedBox(height: 40),


              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã có mật khẩu?',
                    style: TextStyle(color: Colors.grey[700], fontSize: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/350)  : 15),
                  ),
                  SizedBox(width: currentWidth >= 600 ? 4 + 4 * ((currentWidth - 600)/200)  : 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child:  Text(
                      'Đăng nhập ngay',
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