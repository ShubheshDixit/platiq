import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:PlatiQ/models/users.dart';
import 'package:PlatiQ/pages/auth.dart';
import 'package:PlatiQ/pages/home.dart';
import 'package:PlatiQ/widgets/colors.dart';

class SettingsPage extends StatefulWidget {
  final MyUser currentUser;

  const SettingsPage({Key key, this.currentUser}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool mode = darkMode;
  @override
  void initState() {
    //mode = widget.currentUser.darkMode;
    super.initState();
  }

  void _changeMode({bool value = false}) {
    switch (value) {
      case true:
        setState(() {
          this.mode = true;
          darkMode = true;
        });
        usersRef.doc(widget.currentUser.id).update({'darkMode': true});
        break;
      case false:
        setState(() {
          this.mode = false;
          darkMode = false;
        });
        usersRef.doc(widget.currentUser.id).update({'darkMode': false});
        break;
      default:
        setState(() {
          this.mode = !mode;
          darkMode = !darkMode;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mode ? Colors.black : Colors.white,
      body: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        child: Container(
          width: 500,
          alignment: Alignment.center,
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              ListTile(
                leading: InkWell(
                  onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Home(
                                user: widget.currentUser,
                                mode: mode,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(MdiIcons.arrowLeftThick,
                        size: 25, color: mode ? Colors.white : Colors.black),
                  ),
                ),
                title: Container(
                  child: Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: mode ? Colors.white : Colors.black,
                        fontFamily: 'Fredoka',
                        fontSize: 25),
                  ),
                ),
                trailing: SizedBox(
                  width: 30,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  'Preferences',
                  style: TextStyle(
                      fontSize: 20,
                      color: mode ? Colors.white : Colors.black,
                      fontFamily: 'Oleo'),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                    color:
                        mode ? Colors.grey[900] : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: Icon(
                    mode ? MdiIcons.weatherNight : MdiIcons.weatherSunny,
                    color: mainColor,
                  ),
                  title: Text(
                    'Theme',
                    style: TextStyle(
                      color: mode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    mode ? 'Dark' : 'Light',
                    style: TextStyle(
                      color: mode ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Switch(
                    value: mode,
                    onChanged: (value) => _changeMode(value: value),
                  ),
                ),
              ),
              Container(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                      color: mode
                          ? Colors.grey[900]
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    selectedTileColor: mainColor,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => AuthPage()));
                    },
                    leading: Icon(
                      MdiIcons.logout,
                      color: mainColor,
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: mode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Logout from the app',
                      style:
                          TextStyle(color: mode ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
