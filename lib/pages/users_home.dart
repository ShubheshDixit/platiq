import 'package:PlatiQ/pages/auth.dart';
import 'package:PlatiQ/pages/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:PlatiQ/models/users.dart';
import 'package:PlatiQ/widgets/colors.dart';

class UsersHome extends StatefulWidget {
  final MyUser currentUser;

  const UsersHome({Key key, this.currentUser}) : super(key: key);
  @override
  _UsersHomeState createState() => _UsersHomeState();
}

class _UsersHomeState extends State<UsersHome> {
  bool mode = darkMode;
  double height, width;
  var currentPage;
  void _getscreenSize() {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(
          user: widget.currentUser,
          mode: mode,
          pageNum: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _getscreenSize();
    return Scaffold(
      backgroundColor: mode ? Color(0xff121212) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: mainColor,
            title: Container(
              child: Row(
                children: [
                  Text(
                    'Plati',
                    style: TextStyle(
                        color: Colors.white,
                        //mode ? backgroundColorLight : backgroundColorDark,
                        fontFamily: 'Oleo',
                        //fontWeight: FontWeight.w400,
                        fontSize: 30,
                        decoration: TextDecoration.underline),
                  ),
                  Text(
                    'Q',
                    style: TextStyle(
                      color: Colors.white,
                      //mode ? backgroundColorLight : backgroundColorDark,
                      fontFamily: 'Oleo',
                      //fontWeight: FontWeight.w400,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          //SliverPadding(padding: EdgeInsets.only(top: 20)),
          SliverToBoxAdapter(
            child: Container(
              color: mainColor,
              height: MediaQuery.of(context).size.height - 80,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                    color: mode ? Color(0xff121212) : Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25))),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(padding: EdgeInsets.all(10)),
                      Container(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8.0),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color:
                                    mode ? Colors.grey[900] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(500),
                              ),
                              height: 180,
                              //width: 90,
                              child: widget.currentUser.photoUrl == ''
                                  ? Image(
                                      image: AssetImage(
                                          'assets/icons/theme/walter-256.png'),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: widget.currentUser.photoUrl,
                                    ),
                            ),
                            Positioned(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: mode
                                            ? Colors.grey.withOpacity(0.2)
                                            : Colors.black.withOpacity(0.5),
                                        blurRadius: 3,
                                      )
                                    ],
                                    color: !mode ? Colors.white : Colors.black,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(
                                  MdiIcons.cameraOutline,
                                  size: 20,
                                  color: mode ? Colors.white : Colors.blueGrey,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                      Container(
                        width: 700,
                        margin: EdgeInsets.only(top: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 50,
                              child: ListTile(
                                //contentPadding: EdgeInsets.only(left: 15),
                                title: Text(
                                  widget.currentUser.username,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: mode ? Colors.white : Colors.black,
                                    fontFamily: 'Courgette',
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  widget.currentUser.email,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color:
                                        mode ? Colors.grey : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: Icon(
                                  MdiIcons.accountEdit,
                                  color: mode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                  color: mode
                                      ? Colors.grey[900]
                                      : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                leading: Icon(
                                  mode
                                      ? MdiIcons.weatherNight
                                      : MdiIcons.weatherSunny,
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
                                  onChanged: (value) =>
                                      _changeMode(value: value),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
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
                                      MaterialPageRoute(
                                          builder: (context) => AuthPage()));
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
                                  style: TextStyle(
                                      color:
                                          mode ? Colors.white : Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
