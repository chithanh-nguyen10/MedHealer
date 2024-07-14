import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/components/text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
      .sendPasswordResetEmail(email: emailController.text.trim());
      showMessage("Đường dẫn đã được gửi đi! Kiểm tra email của bạn.");
    } on FirebaseAuthException catch (e) {
      print(e);
      showMessage("Có lỗi xảy ra, vui lòng thử lại sau!");
    }
  }

  void showMessage(String mess) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            mess,
            style: const TextStyle(color: Colors.white, fontSize: 19),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      backgroundColor: const Color(0xffdbdbdb),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Nhập email của bạn và chúng tôi sẽ gửi bạn đường dẫn đổi mật khẩu",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: currentWidth >= 600 ? 20 + 20 * ((currentWidth - 600)/500)  : 20,
                color: Colors.black,
              )
            )
          ),

          const SizedBox(height: 15),

          MyTextField(
            controller: emailController,
            hintText: "Email",
            obscureText: false,
            fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/500)  : 22,
          ),

          const SizedBox(height: 15),

          MyButton(
            onTap: passwordReset,
            text: "Đăng nhập",
            fontSize: currentWidth >= 600 ? 20 + 20 * ((currentWidth - 600)/500)  : 20,
          )
        ],
      )
    );
  }
}