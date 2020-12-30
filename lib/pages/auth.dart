import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:PlatiQ/models/users.dart';
import 'package:PlatiQ/pages/home.dart';
import 'package:PlatiQ/widgets/colors.dart';
import 'package:PlatiQ/widgets/progress.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final GoogleSignIn googleSignIn = GoogleSignIn();
  Future signInAnon() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      print(userCredential);
      User currentUser = userCredential.user;
      return currentUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInEmail(email, password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    User user = userCredential.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    print('${user.email}, ${user.emailVerified}');
    return user;
  }

  Future signUpEmail(email, password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    User user = userCredential.user;
    assert(!user.isAnonymous);

    try {
      await user.sendEmailVerification();
      //return user;
    } catch (e) {
      print("An error occured while trying to send email verification");
      print(e.message);
    }

    assert(await user.getIdToken() != null);
    print('${user.email}, ${user.emailVerified}');
    return user;
  }

  // Future signInGoogle() async {
  //   final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  //   final GoogleSignInAuthentication googleSignInAuthentication =
  //       await googleSignInAccount.authentication;
  //   try {
  //     final AuthCredential credential = GoogleAuthProvider.getCredential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );

  //     final AuthResult authResult =
  //         await _auth.signInWithCredential(credential).catchError((err) {
  //       return null;
  //     });
  //     FirebaseUser user = authResult.user;null
  //     assert(!user.isAnonymous);
  //     assert(await user.getIdToken() != null);
  //     print('${user.email}, ${user.photoUrl}');
  //     return user;
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email).catchError(() {
      return false;
    }).then((value) {
      return true;
    });
  }
}

class Login extends StatefulWidget {
  final String type;
  final AuthService _auth = new AuthService();
  Login({this.type});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameText = TextEditingController();
  final TextEditingController _firstText = TextEditingController();
  final TextEditingController _lastText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();
  final TextEditingController _cnfPassText = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _splashKey = GlobalKey<ScaffoldState>();
  User _currentUser;
  MyUser user;
  bool isAuth = false;
  bool isVerified = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      _checkCurrentUser();
    });
  }

  authUser(user) async {
    DocumentSnapshot doc = await usersRef.doc(user.uid).get();
    setState(() {
      this.user = MyUser.fromDocument(doc);
      this.isAuth = true;
    });

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                  user: this.user,
                )));
  }

  _checkCurrentUser() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser;
    debugPrint(user.toString());
    if (user != null) {
      this._currentUser = user;
      authUser(_currentUser);
    }
  }

  Future<MyUser> checkVerification(_currentUser) async {
    final email = _usernameText.text;
    final password = _passwordText.text;
    widget._auth.signInEmail(email, password);
    DocumentSnapshot doc = await usersRef.doc(_currentUser.uid).get();
    if (!doc.exists) {
      doc.reference.set({
        'username': _lastText.text == ''
            ? _firstText.text
            : _firstText.text + " " + _lastText.text,
        'id': _currentUser.uid,
        'email': _currentUser.email,
        'photoUrl': '',
        'mobile': '',
        'online': true,
        'darkMode': false,
        'timestamp': DateTime.now()
      });
    }
    if (_currentUser.emailVerified) {
      user = MyUser.fromDocument(doc);
      return user;
    } else {
      return null;
    }
  }

  _signUpEmail() async {
    if (_usernameText.text == '' ||
        _firstText.text == '' ||
        _passwordText.text == '' ||
        _cnfPassText.text == '') {
      showSnackbar(context, msg: 'All fields must be filled');
    } else {
      if (_passwordText.text == _cnfPassText.text) {
        String email = _usernameText.text;
        String password = _passwordText.text;
        setState(() {
          isLoading = true;
        });
        widget._auth.signUpEmail(email, password).catchError((err) {
          showSnackbar(context, msg: err.message);
          // switch (err.code) {
          //   case 'invalid-email':
          //     setState(() {
          //       isLoading = false;
          //     });
          //     showSnackbar(context, msg: err.message);
          //     _scaffoldKey.currentState.showSnackBar(
          //       SnackBar(
          //         content: Text('Invalid Username/Email !'),
          //         //duration: Duration(seconds: 1),
          //       ),
          //     );
          //     break;
          //   case 'email-already-in-use':
          //     setState(() {
          //       isLoading = false;
          //     });
          //     _scaffoldKey.currentState.showSnackBar(
          //       SnackBar(
          //         content: Text('Email is already in use!'),
          //         //duration: Duration(seconds: 1),
          //       ),
          //     );
          //     break;
          //   case 'weak-password':
          //     setState(() {
          //       isLoading = false;
          //     });
          //     _scaffoldKey.currentState.showSnackBar(
          //       SnackBar(
          //         content: Text('Password too weak!'),
          //         //duration: Duration(seconds: 1),
          //       ),
          //     );
          //     break;
          //   default:
          //     setState(() {
          //       isLoading = false;
          //     });
          //     _scaffoldKey.currentState.showSnackBar(
          //       SnackBar(
          //         content: Text('Error Signing Up!'),
          //         //duration: Duration(seconds: 1),
          //       ),
          //     );
          // }
        }).then((_currentUser) async {
          if (_currentUser != null) {
            user = await showAnimatedDialog(_currentUser);
            if (user != null) {
              authUser(user);
            } else {
              setState(() {
                isLoading = false;
              });
              showSnackbar(context, msg: 'Email Not Verified!');
            }
          }
        }, onError: (err) {
          print(err);
        });
      } else {
        showSnackbar(context, msg: 'Password does not match!');
      }
    }
  }

  _signInEmail() async {
    if (_usernameText.text == '' || _passwordText == null) {
      showSnackbar(context, msg: 'All details must be filled');
    } else {
      String email = _usernameText.text;
      String password = _passwordText.text;
      setState(() {
        isLoading = true;
      });
      widget._auth.signInEmail(email, password).catchError((err) {
        setState(() {
          isLoading = false;
        });
        print(err);
        showSnackbar(context, msg: err.message);
        // switch (err.code) {
        //   case 'user-not-found':
        //     _scaffoldKey.currentState.showSnackBar(
        //       SnackBar(
        //         content: Text('User Not Found!'),
        //         //duration: Duration(seconds: 1),
        //       ),
        //     );
        //     break;
        //   case 'invalid-email':
        //     _scaffoldKey.currentState.showSnackBar(
        //       SnackBar(
        //         content: Text('Invalid Username/Email !'),
        //         //duration: Duration(seconds: 1),
        //       ),
        //     );
        //     break;
        //   case 'wrong-password':
        //     _scaffoldKey.currentState.showSnackBar(
        //       SnackBar(
        //         content: Text('Wrong Password. Try again!'),
        //         //duration: Duration(seconds: 1),
        //       ),
        //     );
        //     break;
        // }
      }).then((_currentUser) {
        authUser(_currentUser);
      });
    }
  }

  showAnimatedDialog(_currentUser) async {
    return showGeneralDialog(
      barrierLabel: "Verify Email",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 100),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Material(
          type: MaterialType.transparency,
          child: Container(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(top: 50, left: 12, right: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              height: 100,
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Verification email sent',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w400),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        MyUser user = await checkVerification(_currentUser);
                        Navigator.pop(context, user);
                      },
                      color: Colors.black,
                      child: Text(
                        'Verified',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position:
              Tween(begin: Offset(0, 0), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }

  buildHome() {
    return Scaffold(
      key: _scaffoldKey,
      body: isLoading
          ? splashScreen()
          : Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          mainColor,
                          secondColor,
                        ]),
                  ),
                  alignment: Alignment.center,
                  child: Center(
                    child: Container(
                      width: 700,
                      height: widget.type == 'IN'
                          ? MediaQuery.of(context).size.height > 900
                              ? MediaQuery.of(context).size.height * 0.6
                              : MediaQuery.of(context).size.height * 0.8
                          : MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      child: Center(
                        child: Scrollbar(
                          child: ListView(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Plati',
                                    style: TextStyle(
                                        color: Colors.white,
                                        //mode ? backgroundColorLight : backgroundColorDark,
                                        fontFamily: 'Oleo',
                                        //fontWeight: FontWeight.w400,
                                        fontSize: 80,
                                        decoration: TextDecoration.underline),
                                  ),
                                  Text(
                                    'Q',
                                    style: TextStyle(
                                      color: Colors.white,
                                      //mode ? backgroundColorLight : backgroundColorDark,
                                      fontFamily: 'Oleo',
                                      //fontWeight: FontWeight.w400,
                                      fontSize: 80,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(padding: EdgeInsets.all(8)),
                              widget.type == "IN"
                                  ? Container()
                                  : Container(
                                      height: 60,
                                      margin: EdgeInsets.only(
                                          left: 25, right: 25, bottom: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 60,
                                              //width: 100,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextField(
                                                autofocus: true,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                                controller: _firstText,
                                                decoration: InputDecoration(
                                                  //errorText: usernameText.text.length == 0 ? 'Can\'t be empty' : null,
                                                  border: InputBorder.none,
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey[400]),
                                                  prefixIcon: Icon(
                                                    Icons.text_format,
                                                    color: Colors.white,
                                                  ),
                                                  hintText: 'First Name',
                                                ),
                                                onSubmitted: null,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 60,
                                              //width: 220,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextField(
                                                autofocus: true,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                                controller: _lastText,
                                                decoration: InputDecoration(
                                                  //errorText: usernameText.text.length == 0 ? 'Can\'t be empty' : null,
                                                  border: InputBorder.none,
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey[400]),
                                                  prefixIcon: Icon(
                                                    Icons.text_format,
                                                    color: Colors.white,
                                                  ),
                                                  hintText: 'Last Name',
                                                ),
                                                onSubmitted: null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              Container(
                                height: 60,
                                margin: EdgeInsets.only(
                                    left: 25, right: 25, bottom: 15),
                                alignment: Alignment.center,
                                //padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  controller: _usernameText,
                                  decoration: InputDecoration(
                                    //errorText: usernameText.text.length == 0 ? 'Can\'t be empty' : null,
                                    //contentPadding: EdgeInsets.symmetric(vertical: 5),
                                    border: InputBorder.none,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400]),
                                    prefixIcon: Icon(
                                      Icons.account_box,
                                      color: Colors.white,
                                    ),
                                    hintText: 'Email',
                                  ),
                                  onSubmitted: null,
                                ),
                              ),
                              Container(
                                height: 60,
                                margin: EdgeInsets.only(
                                    left: 25, right: 25, bottom: 15),
                                alignment: Alignment.center,
                                //padding: EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  obscureText: true,
                                  autocorrect: false,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  controller: _passwordText,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      MdiIcons.lock,
                                      color: Colors.white,
                                    ),
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400]),
                                    border: InputBorder.none,
                                    hintText: 'Password',
                                  ),
                                  // onSubmitted: submit(),
                                ),
                              ),
                              widget.type == 'IN'
                                  ? Container()
                                  : Container(
                                      height: 60,
                                      margin: EdgeInsets.only(
                                          left: 25, right: 25, bottom: 10),
                                      alignment: Alignment.center,
                                      //padding: EdgeInsets.only(left: 20, right: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: TextField(
                                        autocorrect: false,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                        controller: _cnfPassText,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            MdiIcons.lockCheck,
                                            color: Colors.white,
                                          ),
                                          hintStyle: TextStyle(
                                              color: Colors.grey[400]),
                                          border: InputBorder.none,
                                          hintText: 'Confirm Password',
                                        ),
                                        onSubmitted: (value) =>
                                            print('submit($value)'),
                                      ),
                                    ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                margin: EdgeInsets.only(
                                    left: 25, right: 25, top: 10),
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  onPressed: widget.type == 'UP'
                                      ? () => _signUpEmail()
                                      : () => _signInEmail(),
                                  child: Text(
                                    widget.type == 'UP' ? 'Sign Up' : 'Sign In',
                                    style: TextStyle(
                                        fontFamily: 'Fredoka', fontSize: 20),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                              ),
                              widget.type != 'IN'
                                  ? Container()
                                  : Container(
                                      alignment: Alignment.center,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      splashScreen(
                                                          reset: true)));
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              'Forgot your password ? ',
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                                fontFamily: 'Fredoka',
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              'Reset',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Fredoka',
                                                  fontSize: 18),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                              widget.type != 'IN'
                                  ? Container()
                                  : Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Container(
                                        width: 300,
                                        child: Center(
                                          child: Container(
                                            width: 300,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Divider(
                                                    thickness: 0.5,
                                                    color: Colors.grey[200],
                                                    height: 1.5,
                                                    indent: 30,
                                                    endIndent: 10,
                                                  ),
                                                ),
                                                Text(
                                                  'OR',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Fredoka'),
                                                ),
                                                Expanded(
                                                  child: Divider(
                                                    thickness: 0.5,
                                                    color: Colors.grey[200],
                                                    height: 1.5,
                                                    indent: 10,
                                                    endIndent: 30,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              widget.type != 'IN'
                                  ? Container()
                                  : Container(
                                      width: 100,
                                      padding: const EdgeInsets.only(top: 10),
                                      margin: const EdgeInsets.all(5),
                                      child: Center(
                                        child: Container(
                                          height: 60,
                                          width: 250,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: InkWell(
                                            onTap: () {
                                              print('google');
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: Image.asset(
                                                    'assets/icons/material/icons8-google-plus-64.png',
                                                    height: 50,
                                                  ),
                                                ),
                                                Text(
                                                  'Sign In With Google',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17,
                                                      fontFamily: 'Marko'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                MediaQuery.of(context).viewInsets.bottom > 0
                    ? SizedBox()
                    : Positioned(
                        bottom: 0,
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            //borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child:
                                // Divider(
                                //   thickness: 0.5,
                                //   height: 10,
                                //   color: Colors.black,
                                // ),
                                Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.type == "IN"
                                      ? 'Don\'t have an account? '
                                      : 'Already have an account? ',
                                  style: TextStyle(
                                      color: Colors.grey[350],
                                      fontFamily: 'Fredoka',
                                      fontSize: 12),
                                ),
                                InkWell(
                                  onTap: () => widget.type == "IN"
                                      ? Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Login(
                                              type: 'UP',
                                            ),
                                          ),
                                        )
                                      : Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Login(
                                              type: 'IN',
                                            ),
                                          ),
                                        ),
                                  child: Text(
                                    widget.type == "IN" ? 'Sign UP' : 'Sign IN',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Fredoka',
                                        //fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHome();
  }

  splashScreen({reset = false}) {
    if (reset) {
      return Scaffold(
        key: _splashKey,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  mainColor,
                  secondColor,
                ]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Plati',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Oleo',
                        fontSize: 80,
                        decoration: TextDecoration.underline),
                  ),
                  Text(
                    'Q',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Oleo',
                      fontSize: 80,
                    ),
                  ),
                ],
              ),
              reset
                  ? Container(
                      height: 60,
                      margin: EdgeInsets.only(left: 25, right: 25, bottom: 15),
                      alignment: Alignment.center,
                      //padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        controller: _usernameText,
                        decoration: InputDecoration(
                          //errorText: usernameText.text.length == 0 ? 'Can\'t be empty' : null,
                          //contentPadding: EdgeInsets.symmetric(vertical: 5),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.account_box,
                            color: Colors.white,
                          ),
                          hintText: 'Email',
                        ),
                        onSubmitted: null,
                      ),
                    )
                  : Container(
                      width: 200,
                      child: linearProgress(context),
                    ),
              reset
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      margin: EdgeInsets.only(left: 25, right: 25, top: 10),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        onPressed: () {
                          bool error = false;
                          final FirebaseAuth _auth = FirebaseAuth.instance;
                          _auth
                              .sendPasswordResetEmail(email: _usernameText.text)
                              .catchError((err) {
                            error = true;
                            showSnackbar(context, msg: 'Error sending email!');
                          }).then((value) {
                            if (error == false) {
                              showSnackbar(context, msg: 'Reset email sent');
                              Timer(Duration(seconds: 1), () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login(
                                              type: 'IN',
                                            )));
                              });
                            }
                          });
                        },
                        child: Text(
                          'Send Reset Email',
                          style: TextStyle(fontFamily: 'Fredoka', fontSize: 20),
                        ),
                      ),
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
      );
    } else
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                mainColor,
                secondColor,
              ]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Plati',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Oleo',
                      fontSize: 80,
                      decoration: TextDecoration.underline),
                ),
                Text(
                  'Q',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Oleo',
                    fontSize: 80,
                  ),
                ),
              ],
            ),
            Container(
              width: 200,
              child: linearProgress(context),
            ),
          ],
        ),
      );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<ScaffoldState> _splashKey = GlobalKey<ScaffoldState>();
  MyUser user;
  User _currentUser;
  bool isAuth = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _checkCurrentUser();
        });
      }
    });
  }

  buildHome() {
    usersRef.doc(_currentUser.uid).get().then((doc) {
      Timer(Duration(seconds: 1), () {
        user = MyUser.fromDocument(doc);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home(user: user)));
      });
    });
  }

  checkEmail(_currentUser) async {
    if (!_currentUser.emailVerified) {
      return circularProgress(context);
    } else {
      buildHome();
      return SizedBox.shrink();
    }
  }

  authUser(User firebaseUser) async {
    if (firebaseUser.emailVerified) {
      usersRef.doc(firebaseUser.uid).get().then((doc) {
        if (mounted)
          setState(() {
            this.user = MyUser.fromDocument(doc);
            this.isAuth = true;
          });
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Home(user: this.user)));
      });
    } else {
      final user = showAnimatedDialog(firebaseUser);
      if (user == null) {
        Navigator.pop(context);
        showSnackbar(context, msg: 'Email Not Verified!');
      }
    }
  }

  _checkCurrentUser() async {
    await Firebase.initializeApp();
    auth.authStateChanges().listen((user) {
      User firebaseUser = user;
      if (firebaseUser != null) {
        this._currentUser = firebaseUser;
        authUser(_currentUser);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(
              type: 'IN',
            ),
          ),
        );
      }
    });
  }

  splashScreen(context) {
    return Scaffold(
      key: _splashKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                mainColor,
                secondColor,
              ]),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Plati',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Oleo',
                fontSize: 80,
                decoration: TextDecoration.underline,
              ),
            ),
            Text(
              'Q',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Oleo',
                fontSize: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return splashScreen(context);
  }

  checkVerification(_currentUser) {
    usersRef.doc(_currentUser.uid).get().then((doc) {
      Timer(Duration(seconds: 1), () {
        if (_currentUser.emailVerified) {
          user = MyUser.fromDocument(doc);
          if (user != null) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(
                    user: user,
                  ),
                ));
          } else {
            Navigator.pop(context);
            showSnackbar(context, msg: 'Email Not Verified!');
          }
        } else {
          Navigator.pop(context);
        }
      });
    });
  }

  showAnimatedDialog(_currentUser) {
    return showGeneralDialog(
      barrierLabel: "Verify Email",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 100),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Material(
          type: MaterialType.transparency,
          child: Container(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(top: 50, left: 12, right: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              height: 100,
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Verification email sent',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w400),
                    ),
                    RaisedButton(
                      onPressed: () => checkVerification(_currentUser),
                      color: Colors.black,
                      child: Text(
                        'Verified',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position:
              Tween(begin: Offset(0, 0), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }
}
