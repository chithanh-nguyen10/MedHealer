import 'package:flutter/material.dart';
import 'package:tinyhealer/components/my_button.dart';

class FinishSend extends StatefulWidget {
  final Function()? back;
  FinishSend({required this.back});

  @override
  _FinishSendState createState() => _FinishSendState();
}

class _FinishSendState extends State<FinishSend> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text("Phản hồi của bạn đã được gửi đi thành công!", style: TextStyle(fontSize: 19))
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: MyButton(
            onTap: widget.back,
            text: "Quay lại trang chủ"
          )
        )
      ]
    );
  }
}