import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/components/paragraph_text_field.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'package:tinyhealer/pages/functional_pages/finish_send.dart';

class FeedbackPage extends StatefulWidget {
  final Function()? back;
  FeedbackPage({required this.back});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  TextEditingController paragraphController = TextEditingController();
  int charCount = 0;
  static const int charLimit = 2000;
  bool isSend = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    paragraphController.dispose();
    super.dispose();
  }

  void onChanged(String val) {
    setState((){
      charCount = val.length;
    });
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

  void sendFeedback() async{
    String feedback = paragraphController.text;
    if (feedback.isEmpty){
      showMessage("Bạn chưa nhập nội dung phản hồi!");
      return;
    }
    if (feedback.length > 2000){
      showMessage("Nội dung phản hồi không được vượt quá 2000 ký tự!");
      return;
    }
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final user = globals.email;
    Map<String, dynamic> data = {
      "user" : user,
      "feedback": feedback,
    };
    await _firestore.collection('feedback').add(data);
    setState(() {
      isSend = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;

    if (!isSend){
      return SingleChildScrollView(child: Column(
        children: [
          ParagraphTextField(
            onChanged: onChanged,
            controller: paragraphController,
            hintText: "Viết phản hồi của bạn!",
            height: currentHeight*0.475,
          ),
          Padding(
            padding: EdgeInsets.only(right:25),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$charCount/$charLimit',
                style: TextStyle(
                  color: charCount < charLimit ? Color(0xff7b7b7b) : (charCount == charLimit ? Color(0xff09c640): Color(0xffd54e48)),
                  fontSize:20
                ),
              )
            )
          ),
      
          SizedBox(height: 20),

          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: MyButton(
              text: "Gửi phản hồi",
              onTap: sendFeedback,
            )
          )

        ],
      ));
    }
    else return FinishSend(back: widget.back);
  }
}