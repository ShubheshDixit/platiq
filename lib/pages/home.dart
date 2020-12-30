import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:PlatiQ/models/users.dart';
import 'package:PlatiQ/pages/main_page.dart';
import 'package:PlatiQ/pages/users_home.dart';
import 'package:PlatiQ/widgets/colors.dart';

final usersRef = FirebaseFirestore.instance.collection('users');
final chatsRef = FirebaseFirestore.instance.collection('chats');

class Home extends StatefulWidget {
  final MyUser user;
  final bool mode;
  final pageNum;
  final currentChat;
  final selecetedIndex;
  Home(
      {Key key,
      @required this.user,
      this.mode,
      this.pageNum = 0,
      this.currentChat,
      this.selecetedIndex})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  //FirebaseAuth _auth = FirebaseAuth.instance;
  Color textColor, backColor;
  PageController pageController;
  double height, width;
  //TabController _controller;
  int pageIndex = 0;
  bool mode;
  @override
  void initState() {
    if (widget.mode != null) {
      mode = widget.mode;
    } else {
      _getMode();
      pageIndex = widget.pageNum;
    }
    //_controller = TabController(length: 3, vsync: this);
    // _controller.addListener(() {
    //   setState(() {
    //     pageIndex = _controller.index;
    //   });
    // });
    super.initState();
    pageController = PageController();
  }

  void _getscreenSize() {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
  }

  onPageChanged(int index) {
    setState(() {
      this.pageIndex = index;
    });
  }

  onTap(int pageIndex) {
    onPageChanged(pageIndex);
    //_controller.animateTo(pageIndex);
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 1), curve: Curves.easeOut);
  }

  _getMode() {
    setState(() {
      mode = widget.user.darkMode;
      darkMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getscreenSize();
    return Scaffold(
      backgroundColor: !darkMode ? backgroundColorLight : chatsBackground,
      body: PageView(
        controller: pageController,
        children: [
          widget.pageNum == 1
              ? UsersHome(
                  currentUser: widget.user,
                )
              : widget.currentChat == null && widget.selecetedIndex == null
                  ? MainPage(
                      user: widget.user,
                    )
                  : MainPage(
                      user: widget.user,
                      currentChat: widget.currentChat,
                      selecetedIndex: widget.selecetedIndex,
                      isCallback: true,
                    )
        ],
        physics: NeverScrollableScrollPhysics(),
      ),
      // PageView(
      //   children: [
      //     MainPage(user: widget.user),
      //     //SettingsPage(currentUser: widget.user)
      //     UsersHome(
      //       currentUser: widget.user,
      //     ),
      //   ],
      //   controller: pageController,
      //   onPageChanged: onPageChanged,
      //   physics: NeverScrollableScrollPhysics(),
      // ),

      floatingActionButton: MediaQuery.of(context).viewInsets.bottom > 0
          ? SizedBox.shrink()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize:
                  widget.pageNum == 1 ? MainAxisSize.max : MainAxisSize.min,
              children: [
                widget.pageNum == 1
                    ? SizedBox.shrink()
                    : SizedBox(
                        width:
                            MediaQuery.of(context).size.width > 1200 ? 200 : 0,
                      ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  //padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0.0, 0.0),
                        blurRadius: 5,
                        color: mode
                            ? Colors.transparent
                            : Colors.black.withOpacity(0.2),
                      ),
                    ],
                    color: mode ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Container(
                      //   padding: EdgeInsets.symmetric(horizontal: 5),
                      //   decoration:
                      //       BoxDecoration(borderRadius: BorderRadius.circular(25)),
                      //   child: IconButton(
                      //     icon: Icon(
                      //       Icons.whatshot,
                      //       color: Colors.grey,
                      //     ),
                      //     onPressed: () => Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) =>
                      //                 Search(currentUser: widget.user))).then((value) {
                      //       setState(() {
                      //         pageIndex = 0;
                      //         onTap(pageIndex);
                      //       });
                      //     }),
                      //   ),
                      // ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: widget.pageNum == 0
                                ? mode
                                    ? Colors.grey.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25)),
                        child: IconButton(
                          icon: Icon(
                            MdiIcons.chat,
                            size: 25,
                            //width > 1000 ? 25 : pageIndex == 0 ? 32 : 25,
                            color: widget.pageNum != 0
                                ? Colors.grey
                                : mode
                                    ? Colors.red
                                    : Colors.red,
                          ),
                          onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Home(
                                        user: widget.user,
                                        pageNum: 0,
                                        mode: widget.mode,
                                      ))),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: widget.pageNum == 1
                                ? mode
                                    ? Colors.grey.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25)),
                        child: IconButton(
                          icon: Icon(
                            MdiIcons.account,
                            size: 25,
                            //width > 1000 ? 25 : pageIndex == 1 ? 32 : 25,
                            color: widget.pageNum != 1
                                ? Colors.grey
                                : mode
                                    ? Colors.cyan
                                    : mainColor,
                          ),
                          onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Home(
                                        user: widget.user,
                                        pageNum: 1,
                                        mode: widget.mode,
                                      ))),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),

      floatingActionButtonLocation: width > 1200
          ? FloatingActionButtonLocation.startDocked
          : FloatingActionButtonLocation.centerFloat,
    );
  }

  // _buildNav() {
  //   return BottomAppBar(
  //     color: mainColor,
  //     shape: CircularNotchedRectangle(),
  //     child: Container(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           InkWell(
  //             onTap: () => onTap(0),
  //             child: TabItem(
  //               label: 'Home',
  //               icon: Icons.home,
  //               isSelected: pageIndex == 0 ? true : false,
  //             ),
  //           ),
  //           InkWell(
  //             onTap: () => onTap(1),
  //             child: TabItem(
  //               label: 'Settings',
  //               icon: Icons.settings,
  //               isSelected: pageIndex == 1 ? true : false,
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
