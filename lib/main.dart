import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:PlatiQ/pages/auth.dart';
import 'package:PlatiQ/widgets/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //setTargetPlatformForDesktop();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlatiQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          snackBarTheme: SnackBarThemeData(
            backgroundColor: mainColor,
            actionTextColor: secondColor,
            contentTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Fredoka',
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 5,
            behavior: SnackBarBehavior.floating,
          ),
          primarySwatch: secondColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.blue.withGreen(0),
          )),
      home: AuthPage(),
    );
  }
}
