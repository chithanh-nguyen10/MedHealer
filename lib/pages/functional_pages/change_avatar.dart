import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/image_picker/utils.dart';
import 'package:tinyhealer/image_picker/add_data.dart';

class ChangeAvatar extends StatefulWidget {
  @override
  _ChangeAvatarState createState() => _ChangeAvatarState();
}

class _ChangeAvatarState extends State<ChangeAvatar> {

  Uint8List? _image;
  String imageURL = "https://firebasestorage.googleapis.com/v0/b/tinyhealer-30c94.appspot.com/o/default-avatar.png?alt=media&token=b702495f-f559-4b3b-8075-af6fbe9cc3f3";
  bool isOpac = true;

  @override
  void initState() {
    super.initState();
    imageURL = globals.avatar;
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    if (globals.imageMB - globals.limitedMB > globals.EPSILON){
      showMessage("Ảnh của bạn không được vượt quá ${globals.limitedMB} MB");
      return;
    }
    
    setState(() {
      _image = img;
      isOpac = false;
      print(isOpac);
    });
  }

  void saveProfile() async{
    if (isOpac) return;

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator()
        );
      }
    );

    String resp = await StoreData().saveData(globals.email, _image!);
    _image = null;
    setState(() {
      imageURL = resp;
      globals.avatar = resp;
      isOpac = true;
      Navigator.pop(context);
    });
  }

  void showMessage(String mess){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              _image == null ?
              CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(imageURL),
              )
              : CircleAvatar(
                radius: 64,
                backgroundImage: MemoryImage(_image!),
              ),
              Positioned(
                bottom: -10,
                left: 80,
                child: IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: selectImage,
                ),
              )
            ],
          ),
          SizedBox(height: 15),

          Opacity(
            opacity: isOpac ? 0.4 : 1,
          child: MyButton(
            onTap: saveProfile,
            text: "Thay đổi ảnh đại diện"
          )
          )
        ],
      )
    );
  }
}