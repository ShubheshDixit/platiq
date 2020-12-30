import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:PlatiQ/models/chats.dart';
import 'package:PlatiQ/models/friend.dart';
import 'package:PlatiQ/models/users.dart';
import 'package:PlatiQ/pages/chat_home.dart';
import 'package:PlatiQ/pages/home.dart';
import 'package:PlatiQ/pages/search.dart';
import 'package:PlatiQ/widgets/colors.dart';
import 'package:PlatiQ/widgets/progress.dart';
import 'package:intl/intl.dart';

var currentPage;

class MainPage extends StatefulWidget {
  final MyUser user;
  final currentChat;
  final selecetedIndex;
  final isCallback;
  const MainPage(
      {Key key,
      @required this.user,
      this.currentChat,
      this.selecetedIndex,
      this.isCallback = false})
      : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  Color textColor, backColor;
  bool mode;
  double height, width;
  int pageIndex = 0;
  int isSelected, isFocused;
  Timestamp time;
  String msg;
  List<Chats> newMsgs;
  TabController _controller;
  PageController pageController = PageController();
  int tabIndex = 0;
  bool isLoading = false;
  List<String> chatIds = [];
  List<Friend> friends = [];
  int chatIndex;
  bool isSearchOn = false;
  int newRequests = 0;
  var currentChat;
  int selecetedIndex;
  int lastIndex;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    //_chatController = TabController(length: 1, vsync: this);
    mode = darkMode;
    _getFriends();
    _getRequests();
    super.initState();
    textColor = !mode ? darkTextColor : lightTextColor;
    backColor = !mode ? backgroundColorLight : backgroundColorDark;
    currentChat = widget.currentChat;
    selecetedIndex = widget.selecetedIndex;
  }

  void _getscreenSize() {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    _controller.addListener(() {
      setState(() {
        tabIndex = _controller.index;
      });
    });
  }

  _getRequests() async {
    setState(() {
      this.isLoading = true;
    });
    QuerySnapshot query =
        await usersRef.doc(widget.user.id).collection('requestsGot').get();
    setState(() {
      newRequests = query.docs.length;
      this.isLoading = false;
    });
  }

  _getFriends() async {
    setState(() {
      this.isLoading = true;
      friends.clear();
    });
    QuerySnapshot value =
        await usersRef.doc(widget.user.id).collection('friends').get();
    value.docs.forEach((element) {
      Friend friend = Friend.fromDocument(element);
      setState(() {
        chatIds.add(friend.chatId);
        friends.add(friend);
      });
    });
    //_chatController = TabController(length: friends.length, vsync: this);
    setState(() {
      this.isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getscreenSize();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: !mode ? Colors.white : Color(0xff121212),
        body: Container(
          //width: 700,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor:
                    mainColor, //!mode ? backgroundColorLight : Colors.black,
                automaticallyImplyLeading: false,
                title: Container(
                  child: Row(
                    children: [
                      Text(
                        'Plati',
                        style: TextStyle(
                            color: Colors.white,
                            // mode
                            //     ? backgroundColorLight
                            //     : backgroundColorDark,
                            fontFamily: 'Oleo',
                            //fontWeight: FontWeight.w400,
                            fontSize: 30,
                            decoration: TextDecoration.underline),
                      ),
                      Text(
                        'Q',
                        style: TextStyle(
                          color: Colors.white,
                          // mode
                          //     ? backgroundColorLight
                          //     : backgroundColorDark,
                          fontFamily: 'Oleo',
                          //fontWeight: FontWeight.w400,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  width > 1200
                      ? Container(
                          //color: mainColor,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5)),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  width: 300,
                                  child: TextField(
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'Fredoka',
                                    ),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                            color: Colors.grey[300],
                                            fontFamily: 'Fredoka'),
                                        hintText:
                                            'Search a user or conversation....'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            isSearchOn ? Icons.close : Icons.search,
                            size: isSearchOn ? 25 : 28,
                            color: Colors.white,
                            // mode
                            //     ? backgroundColorLight
                            //     : backgroundColorDark,
                          ),
                          onPressed: () {
                            setState(() {
                              isSearchOn = !isSearchOn;
                            });
                          },
                        ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0, top: 5),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            MdiIcons.accountHeart,
                            size: 25,
                            color: Colors.white,
                            // mode
                            //     ? backgroundColorLight
                            //     : backgroundColorDark,
                          ),
                          onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Search(currentUser: widget.user)))
                              .then((value) {
                            _getRequests();
                          }),
                        ),
                        newRequests == 0
                            ? SizedBox.shrink()
                            : Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Text(
                                    newRequests.toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                ))
                      ],
                    ),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     setState(() {
                  //       showStatus = !showStatus;
                  //     });
                  //   },
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       Text(
                  //         'Stories',
                  //         style: TextStyle(
                  //             color: Colors.white,
                  //             fontFamily: 'Fredoka',
                  //             fontSize: 18),
                  //       ),
                  //       Icon(
                  //         showStatus
                  //             ? Icons.keyboard_arrow_up
                  //             : Icons.keyboard_arrow_down,
                  //         color: Colors.white,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              SliverToBoxAdapter(
                child: width > 1200
                    ? SizedBox.shrink()
                    : AnimatedContainer(
                        duration: Duration(milliseconds: 80),
                        curve: Curves.easeIn,
                        color: mainColor,
                        height: !isSearchOn ? 0 : 80,
                        margin: const EdgeInsets.only(
                          top: 0,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: secondColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5)),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: TextField(
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Fredoka',
                                    ),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                            color: Colors.grey[300],
                                            fontFamily: 'Fredoka'),
                                        hintText:
                                            'Search a user or conversation....'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: mainColor,
                  child: Container(
                    height: MediaQuery.of(context).size.height - 80,
                    width: MediaQuery.of(context).size.width,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: mode ? Color(0xff121212) : Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25))),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width > 1200
                              ? 500
                              : MediaQuery.of(context).size.width - 20,
                          child: Column(
                            children: [
                              Container(
                                // width: 300,
                                margin: EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                // decoration: BoxDecoration(
                                //   color: mainColor,
                                //   boxShadow: [
                                //     BoxShadow(
                                //       color: Colors.black.withOpacity(0.3),
                                //       blurRadius: 5,
                                //       spreadRadius: 1,
                                //     ),
                                //   ],
                                //   borderRadius: BorderRadius.circular(50),
                                // ),
                                child: TabBar(
                                  controller: _controller,
                                  tabs: [
                                    Tab(
                                      text: 'Chats',
                                      // child: Container(
                                      //   margin: EdgeInsets.all(5),
                                      //   decoration: BoxDecoration(
                                      //     borderRadius:
                                      //         BorderRadius.circular(50),
                                      //     color: tabIndex == 0
                                      //         ? secondColor
                                      //         : Colors.transparent,
                                      //   ),
                                      //   child: Center(
                                      //     child: Text('Chats'),
                                      //   ),
                                      // ),
                                    ),
                                    Tab(
                                      text: 'Stories',
                                      // child: Container(
                                      //   margin: EdgeInsets.all(5),
                                      //   decoration: BoxDecoration(
                                      //     borderRadius:
                                      //         BorderRadius.circular(50),
                                      //     color: tabIndex == 1
                                      //         ? secondColor
                                      //         : Colors.transparent,
                                      //   ),
                                      //   child: Center(
                                      //     child: Text('Stories'),
                                      //   ),
                                      // ),
                                    ),
                                  ],
                                  indicatorWeight: 3.0,
                                  labelColor:
                                      darkMode ? Colors.white : Colors.black,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  labelStyle: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 18,
                                  ),
                                  unselectedLabelStyle: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _controller,
                                  children: [
                                    _buildFriends(),
                                    _buildStatus(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        width < 1200
                            ? SizedBox.shrink()
                            : Expanded(
                                child: Material(
                                  elevation: 2,
                                  type: MaterialType.button,
                                  color: darkMode
                                      ? Colors.black.withOpacity(1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(25),
                                  child: Container(
                                    // width:
                                    //     MediaQuery.of(context).size.width / 2,
                                    height: MediaQuery.of(context).size.height,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    // padding: EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: PageView(
                                            controller: pageController,
                                            children: [
                                              currentChat != null
                                                  ? ChatHome(
                                                      currentUser: currentChat[
                                                          'currentUser'],
                                                      friendUser: currentChat[
                                                          'friendUser'],
                                                      chatId:
                                                          currentChat['chatId'],
                                                      isTabbed: true,
                                                      selectedIndex:
                                                          currentChat[
                                                              'selectedIndex'],
                                                    )
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            color: darkMode
                                                                ? Colors
                                                                    .grey[900]
                                                                : Colors.white,
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          child: Icon(
                                                            MdiIcons
                                                                .arrowLeftThick,
                                                            color: !darkMode
                                                                ? Colors.black
                                                                : Colors.white,
                                                            size: 60,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Text(
                                                          'Select a chat',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Fredoka',
                                                            fontSize: 25,
                                                            color: !darkMode
                                                                ? Colors
                                                                    .grey[900]
                                                                : Colors
                                                                    .grey[100],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ],
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

  _buildStatus() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.only(right: 10),
                width: 100,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50)),
                        margin: EdgeInsets.only(bottom: 10, right: 10),
                        height: 30,
                        width: 30,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.only(right: 10),
                width: 100,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.only(right: 10),
                width: 100,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.only(right: 10),
                width: 100,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.only(right: 10),
                width: 100,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildFriends() {
    return isLoading
        ? circularProgress(context)
        : friends.length > 0
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                child: Container(
                  //width: 1200,
                  child: RefreshIndicator(
                    onRefresh: () => _getFriends(),
                    child: ListView.builder(
                      itemCount: friends.length + 1,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        if (!mounted) {
                          return SizedBox.shrink();
                        } else {
                          if (index == friends.length) {
                            return SizedBox(
                              height: 60,
                            );
                          } else
                            return _buildEachTile(
                                user: friends[index],
                                chat: null,
                                chatId: friends[index].chatId,
                                index: index);
                        }
                      },
                    ),
                  ),
                ))
            : RefreshIndicator(
                onRefresh: () => _getFriends(),
                child: Column(
                  children: [
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      decoration: BoxDecoration(
                          color: mode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Search(currentUser: widget.user)));
                        },
                        title: Text(
                          'Invite Friends',
                          style: TextStyle(
                              color: mode ? Colors.white : Colors.black,
                              fontFamily: 'Fredoka'),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25)),
                          child: Icon(
                            MdiIcons.accountHeart,
                            color: secondColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
  }

  // _buildChatView() {
  //   return StreamBuilder(
  //     stream: usersRef.doc(widget.user.id).collection('friends').snapshots(),
  //     builder: (context, snapshot) {
  //       return !snapshot.hasData
  //           ? circularProgress(context)
  //           : Container(
  //               height: MediaQuery.of(context).size.height,
  //               width: MediaQuery.of(context).size.width,
  //               child: ListView.builder(
  //                 itemCount: snapshot.data.documents.length,
  //                 padding: EdgeInsets.zero,
  //                 itemBuilder: (context, index) {
  //                   Friend user =
  //                       Friend.fromDocument(snapshot.data.documents[index]);
  //                   if (!mounted) {
  //                     return SizedBox.shrink();
  //                   } else {
  //                     return BuildChatUsers(
  //                       mode: this.mode,
  //                       user: user,
  //                       currentUser: widget.user,
  //                     );
  //                   }
  //                 },
  //               ),
  //             );
  //     },
  //   );
  // }

  _buildEachTile({user, Chats chat, chatId, index}) {
    return StreamBuilder<QuerySnapshot>(
        stream: chatsRef
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          } else {
            Chats chat;
            if (snapshot.data.size > 0) {
              chat = Chats.fromDocument(snapshot.data.docs[0]);
            }
            if (MediaQuery.of(context).size.width < 1200) {
              selecetedIndex = null;
              currentChat = null;
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: selecetedIndex == index
                    ? secondColor
                    : chatIndex == index
                        ? mode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.2)
                        : mode
                            ? Colors.grey[900]
                            : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    spreadRadius: 1,
                    color: Colors.black.withOpacity(0.2),
                  )
                ],
              ),
              child: ListTile(
                onLongPress: () {
                  if (chatIndex == index) {
                    setState(() {
                      chatIndex = null;
                    });
                  } else {
                    setState(() {
                      chatIndex = index;
                    });
                  }
                },
                onTap: () {
                  if (chatIndex != index) {
                    if (MediaQuery.of(context).size.width > 1200) {
                      setState(() {
                        selecetedIndex = index;
                        currentChat = null;
                      });
                      Timer(Duration(milliseconds: 100), () {
                        setState(() {
                          currentChat = {
                            'currentUser': widget.user,
                            'friendUser': user,
                            'chatId': chatId,
                            'selectedIndex': index,
                          };
                        });
                      });
                    } else {
                      return Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatHome(
                                    currentUser: widget.user,
                                    friendUser: user,
                                    chatId: chatId,
                                    selectedIndex: index,
                                  )));
                    }
                  }
                },
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                leading: Container(
                  width: 50,
                  child: Row(
                    children: [
                      chatIndex == index
                          ? IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: mode ? Colors.white : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  chatIndex = null;
                                });
                              })
                          : Container(
                              padding: EdgeInsets.all(2),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(5)),
                              height: 45,
                              width: 45,
                              child: widget.user.photoUrl == ''
                                  ? Image.asset(
                                      'assets/icons/theme/icons8-account-64.png')
                                  : Image.network(widget.user.photoUrl),
                            ),
                    ],
                  ),
                ),
                title: Text(
                  user.username,
                  style: TextStyle(
                    color: selecetedIndex == index
                        ? Colors.white
                        : mode
                            ? Colors.white
                            : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: chat != null
                    ? chat.flag == 'GIF' || chat.flag == 'Sticker'
                        ? Row(
                            children: [
                              Icon(
                                chat.flag == 'Sticker'
                                    ? MdiIcons.sticker
                                    : MdiIcons.gif,
                                color: selecetedIndex == index
                                    ? Colors.white
                                    : mode
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.5),
                                size: chat.flag == 'GIF' ? 25 : 15,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                chat.flag == 'Sticker' ? 'Sticker' : 'GIF',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: selecetedIndex == index
                                        ? Colors.white
                                        : mode
                                            ? Colors.white.withOpacity(0.5)
                                            : Colors.black.withOpacity(0.5),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        : Container(
                            child: Text(
                              chat != null ? chat.msg : 'Start a PlatiQ',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: selecetedIndex == index
                                      ? Colors.white
                                      : mode
                                          ? Colors.white.withOpacity(0.5)
                                          : Colors.black.withOpacity(0.5),
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                    : Text(
                        chat != null ? chat.msg : 'Start a PlatiQ',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: mode
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5),
                            fontWeight: FontWeight.w600),
                      ),
                trailing: chatIndex == index
                    ? Container(
                        width: 100,
                        //color: secondColor,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: 20,
                                color: mode ? Colors.white : Colors.black,
                              ),
                              onPressed: () {
                                print('remove');
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.archive,
                                size: 20,
                                color: mode ? Colors.white : Colors.black,
                              ),
                              onPressed: () {
                                print('More');
                              },
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          chat == null
                              ? SizedBox.shrink()
                              : !chat.isSeen && chat.senderId != widget.user.id
                                  ? Expanded(
                                      child: Container(
                                        height: 20,
                                        width: 25,
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: Center(
                                          child: Text(
                                            'new',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(''),
                          Text(
                            chat == null
                                ? ''
                                : DateFormat('hh:mm a').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        chat.time.millisecondsSinceEpoch),
                                  ),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: selecetedIndex == index
                                    ? Colors.white
                                    : mode
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.5),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            );
          }
        });
  }
}

// class BuildChatUsers extends StatefulWidget {
//   final Friend user;
//   final bool mode;

//   final MyUser currentUser;
//   const BuildChatUsers(
//       {Key key,
//       @required this.user,
//       @required this.mode,
//       @required this.currentUser})
//       : super(key: key);

//   @override
//   _BuildChatUsersState createState() => _BuildChatUsersState();
// }

// class _BuildChatUsersState extends State<BuildChatUsers> {
//   bool isSelected = false;
//   bool newMsgs = false;
//   bool isLoading = false;
//   bool isOpened = false;

//   _buildTile(Chats chat) {
//     return Container(
//       //height: 70,
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       decoration: BoxDecoration(
//           color: isSelected == true
//               ? widget.mode
//                   ? Colors.white.withOpacity(0.2)
//                   : Colors.black.withOpacity(0.2)
//               : widget.mode ? Colors.grey[900] : Colors.grey[200],
//           borderRadius: BorderRadius.circular(10)),
//       child: ListTile(
//         contentPadding: EdgeInsets.symmetric(horizontal: 10),
//         leading: Container(
//           width: 50,
//           child: Row(
//             children: [
//               isSelected == true
//                   ? IconButton(
//                       icon: Icon(
//                         Icons.arrow_back,
//                         color: widget.mode ? Colors.white : Colors.black,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           this.isSelected = false;
//                         });
//                       })
//                   : Container(
//                       padding: EdgeInsets.all(2),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                           color: Colors.black,
//                           borderRadius: BorderRadius.circular(5)),
//                       height: 45,
//                       width: 45,
//                       child: widget.user.photoUrl == ''
//                           ? Image.asset(
//                               'assets/icons/theme/icons8-account-64.png')
//                           : Image.network(widget.user.photoUrl),
//                     ),
//             ],
//           ),
//         ),
//         title: Text(
//           widget.user.username,
//           style: TextStyle(
//             color: widget.mode ? Colors.white : Colors.black,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         subtitle: Row(
//           children: [
//             chat != null
//                 ? chat.flag == 'Sticker'
//                     ? Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: Icon(
//                           MdiIcons.sticker,
//                           size: 18,
//                           color: widget.mode
//                               ? Colors.white.withOpacity(0.5)
//                               : Colors.black.withOpacity(0.5),
//                         ),
//                       )
//                     : chat.flag == 'GIF'
//                         ? Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: Icon(
//                               MdiIcons.gif,
//                               size: 18,
//                               color: widget.mode
//                                   ? Colors.white.withOpacity(0.5)
//                                   : Colors.black.withOpacity(0.5),
//                             ),
//                           )
//                         : SizedBox.shrink()
//                 : SizedBox.shrink(),
//             Text(
//               chat != null ? chat.msg : 'Start a PlatiQ',
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                   color: widget.mode
//                       ? Colors.white.withOpacity(0.5)
//                       : Colors.black.withOpacity(0.5),
//                   fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//         trailing: isSelected == true
//             ? Container(
//                 width: 100,
//                 //color: secondColor,
//                 alignment: Alignment.center,
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         Icons.delete,
//                         size: 20,
//                         color: widget.mode ? Colors.white : Colors.black,
//                       ),
//                       onPressed: () {
//                         print('remove');
//                       },
//                     ),
//                     IconButton(
//                       icon: Icon(
//                         Icons.archive,
//                         size: 20,
//                         color: widget.mode ? Colors.white : Colors.black,
//                       ),
//                       onPressed: () {
//                         print('More');
//                       },
//                     ),
//                   ],
//                 ),
//               )
//             : Column(
//                 children: [
//                   !chat.isSeen
//                       ? Text('')
//                       : Container(
//                           height: 20,
//                           width: 20,
//                           margin: EdgeInsets.symmetric(vertical: 8),
//                           decoration: BoxDecoration(
//                               color: Colors.red,
//                               borderRadius: BorderRadius.circular(50)),
//                           child: Center(
//                             child: Text(
//                               'new',
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                   Text(
//                     chat == null
//                         ? ''
//                         : DateFormat('hh:mm a').format(
//                             DateTime.fromMillisecondsSinceEpoch(
//                                 chat.time.millisecondsSinceEpoch),
//                           ),
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                         color: widget.mode
//                             ? Colors.white.withOpacity(0.5)
//                             : Colors.black.withOpacity(0.5),
//                         fontStyle: FontStyle.italic,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!mounted) {
//       return SizedBox.shrink();
//     } else {
//       return StreamBuilder(
//           stream: chatsRef
//               .doc(widget.user.chatId)
//               .collection('messages')
//               .orderBy('timestamp', descending: true)
//               .limit(1)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return SizedBox.shrink();
//             } else {
//               // _getLastMessage(snapshot);
//               Chats chat = Chats.fromDocument(snapshot.data.docs[0]);
//               return _buildTile(chat);
//             }
//           });
//     }
//   }
// }
