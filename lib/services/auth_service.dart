import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tinyhealer/global.dart' as globals;

class AuthService {
  signInWithGoogle() async{
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    
    
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    final res = await FirebaseAuth.instance.signInWithCredential(credential);
    final user = FirebaseAuth.instance.currentUser!;

    if (res.additionalUserInfo?.isNewUser ?? false){
      globals.registered = false;
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      globals.registered = false;
      globals.isLoading = false;
      Map<String, dynamic> data = {
        "registered": false,
      };
      await _firestore.collection('users').doc(user.email!).set(data);
    }
    else{
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      globals.isLoading = true;
      DocumentSnapshot docSnapshot = await _firestore.collection('users').doc(user.email!).get();
      bool data = docSnapshot.get('registered');
      globals.registered = data;
      globals.isLoading = false;
      print(globals.registered);
    }
    
    if (globals.registered){
      localStorage.setItem('EMAIL', user.email!);
      localStorage.setItem('PASS', "GG");
    }
    else{
      globals.email = user.email!;
      globals.pass = "GG";
    }
    return res;
  }

}