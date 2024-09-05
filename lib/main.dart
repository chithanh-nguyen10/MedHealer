import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'pages/auth_page.dart';
import 'package:tinyhealer/global.dart' as globals;
import 'package:localstorage/localstorage.dart';
import "package:flutter/services.dart";
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  localStorage.setItem('EMAIL', "NONE");
  localStorage.setItem('PASS', "NONE");
  String email = localStorage.getItem('EMAIL').toString();
  String pass = localStorage.getItem('PASS').toString();
  globals.registered = false;
  if (email != "NONE" && pass != "NONE" && pass != "GG" && email != "null" && pass != "null"){
      try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass
      );
      globals.registered = true;
      globals.isLoading = false;
    }
    // ignore: unused_catch_clause
    on FirebaseAuthException catch (e){
      localStorage.setItem('EMAIL', "NONE");
      localStorage.setItem('PASS', "NONE");
      FirebaseAuth.instance.signOut();
      globals.registered = false;
      globals.isLoading = false;
    }
  }
  else if (email != "NONE" && pass == "GG" && email != "null" && pass != "null"){
    final GoogleSignInAccount? gUser = await GoogleSignIn().signInSilently();
    if (gUser != null){
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      globals.registered = true;
      globals.isLoading = false;
    }
    else{
      localStorage.setItem('EMAIL', "NONE");
      localStorage.setItem('PASS', "NONE");
      FirebaseAuth.instance.signOut();
      globals.registered = false;
      globals.isLoading = false;
    }
  }
  else{
    localStorage.setItem('EMAIL', "NONE");
    localStorage.setItem('PASS', "NONE");
    FirebaseAuth.instance.signOut();
    globals.registered = false;
    globals.isLoading = false;
  }
  print(localStorage.getItem('EMAIL'));
  print(localStorage.getItem('PASS'));
  tz.initializeTimeZones();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_){
    runApp(const MyApp());
  });
}

WidgetStateProperty<Color?>? colorConvert(Color color){
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return color; // Color when checkbox is selected
    }
    return null;
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xff228af4)
        ),
        dialogBackgroundColor: const Color.fromARGB(255, 20, 80, 139),
        checkboxTheme: CheckboxThemeData(
          fillColor: colorConvert(const Color(0xff228af4)),
          checkColor: colorConvert(Colors.white),
          overlayColor: colorConvert(const Color(0xff228af4)),
          side: const BorderSide(color: Color(0xff228af4), width: 2)
        ),
        tabBarTheme: TabBarTheme(
          unselectedLabelColor: Colors.grey[800],
          indicatorColor: const Color(0xff228af4),
          labelColor: const Color(0xff228af4),
          dividerColor: Colors.blue,
          dividerHeight: 0.7
        ),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: Color(0xff228af4))
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: Color(0xff228af4))
          ),
          focusColor: Color(0xff228af4),
          hoverColor: Color(0xff228af4),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.white,
            filled: true
          ),
          menuStyle: MenuStyle(
            backgroundColor: colorConvert(Colors.white)
          )
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xff228af4),
          iconTheme: IconThemeData(
            color: Colors.white
          )
        )
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home: const AuthPage(),
    );
  }
}
