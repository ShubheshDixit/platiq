import 'dart:async';
import 'dart:io';
import 'package:PlatiQ/pages/meeting.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:PlatiQ/models/chats.dart';
import 'package:PlatiQ/models/friend.dart';
import 'package:PlatiQ/models/users.dart';
import 'package:PlatiQ/pages/home.dart';
import 'package:PlatiQ/widgets/colors.dart';
import 'package:PlatiQ/widgets/progress.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:requests/requests.dart';
import 'dart:math' as math;
//import 'package:timeago/timeago.dart' as timeago;

import 'package:uuid/uuid.dart';

class ChatHome extends StatefulWidget {
  final MyUser currentUser;
  final Friend friendUser;

  final String chatId;

  final bool isTabbed;
  final selectedIndex;

  ChatHome(
      {Key key,
      this.currentUser,
      this.friendUser,
      this.chatId,
      this.isTabbed = false,
      this.selectedIndex})
      : super(key: key);

  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome>
    with SingleTickerProviderStateMixin {
  bool isChanged = false;
  final TextEditingController sendController = TextEditingController();
  final TextEditingController searchGifController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode focusNode = FocusNode();
  List<String> mediaUrls = [];
  bool hasChat = false;
  bool isDisplaySticker = false;
  bool isLoading = false;
  bool wasFocused = false;
  //TabController _controller;
  bool searchGif = false;
  bool gifMode = false;
  final client = GiphyClient(apiKey: 'z2dbRyg92us4xxsEp10z2asbTiH3q6yl');
  List<String> gifsList = [];
  bool isSelectGif = false;
  Timestamp currentTimestamp;
  List<Widget> chatsList = [];
  //ScrollController _scrollController = new ScrollController();
  bool firstState = true;
  int stickerIndex = 0;
  int keyboardSize;
  PageController pageController;
  int likeIndex;
  String selectedGif;

  // checkChats() {
  //   chatsRef.doc(widget.chatId).get().then((doc) {
  //     if (doc.exists) {
  //       setState(() {
  //         this.hasChat = true;
  //       });
  //       doc.reference.update({'${widget.currentUser.id}': DateTime.now()});
  //     }
  //   });
  // }

  onPageChanged(int index) {
    setState(() {
      stickerIndex = index;
    });
  }

  onTap(int pageIndex) {
    onPageChanged(pageIndex);
    //_controller.animateTo(pageIndex);
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // focusNode.addListener(() {
    //   if (focusNode.hasFocus) {
    //     setState(() {
    //       isDisplaySticker = false;
    //     });
    //   }
    // });
    //checkChats();
    _getChat();
  }

  // @override
  // void dispose() {
  //   BackButtonInterceptor.remove(myInterceptor);
  //   super.dispose();
  // }

  Future<void> _getChat() async {
    chatsList.clear();
    QuerySnapshot doc = await chatsRef
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    for (var i = firstState ? 0 : 1; i < doc.size; i++) {
      Chats chat = Chats.fromDocument(doc.docs[i]);
      //Timestamp timestamp = chat.time;
      bool isMe = chat.senderId == widget.currentUser.id;
      if (!isMe) {
        doc.docs[i].reference.update({'isSeen': true});
      }

      setState(() {
        chatsList.add(_buildChat(chat, isMe));
      });
    }
  }

  Future<bool> myInterceptor(
      bool stopDefaultButtonEvent, RouteInfo info) async {
    onBackPress();
    return true;
  }

  clearSearch() {
    setState(() {
      this.isChanged = false;
      this.sendController.clear();
    });
  }

  sendStickers(String stickerPath) async {
    mediaUrls.add(stickerPath);
    sendMessage('Sticker', flag: 'Sticker');
  }

  void sendMessage(String msg, {flag = 'text'}) async {
    if (flag == 'GIF') {
      msg = msg.length > 0 ? msg : ' ';
    }
    var id = Uuid().v4();
    if (!isLoading) {
      setState(() {
        isLoading = true;
        firstState = false;
      });
      if (msg != null && msg.length > 0) {
        final doc = await chatsRef.doc(widget.chatId).get();
        if (!doc.exists) {
          doc.reference.set({
            'startId': widget.currentUser.id,
            'friendId': widget.friendUser.id,
            'id': widget.chatId,
            'timestamp': DateTime.now(),
            '${widget.currentUser.id}': DateTime.now(),
            'lastMsg': msg.trim(),
          });
        }
        chatsRef.doc(widget.chatId).collection('messages').doc(id).set({
          'msg': msg.trim(),
          'senderId': widget.currentUser.id,
          'photoUrl': widget.currentUser.photoUrl,
          'mediaUrls': mediaUrls,
          'timestamp': DateTime.now(),
          'isLiked': false,
          'isSeen': false,
          'flag': '$flag',
          'id': id,
        });

        setState(() {
          if (!isDisplaySticker) {
            this.sendController.clear();
            isChanged = false;
          }
          mediaUrls.clear();
          setState(() {
            isLoading = false;
          });
        });
      }
      setState(() {
        firstState = false;
      });
      _getChat();
    }
  }

  // _buildTimestamp(time) {
  //   var dateTime =
  //       DateTime.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);
  //   var today = DateTime.now();

  //   return Container(
  //       height: 30,
  //       width: MediaQuery.of(context).size.width,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(
  //             dateTime.year == today.year && dateTime.month == today.month
  //                 ? dateTime.day == today.day
  //                     ? 'Today'
  //                     : today.day.toDouble() - dateTime.day.toDouble() == 1
  //                         ? 'Yesterday'
  //                         : DateFormat('dd, MMMM').format(
  //                             DateTime.fromMillisecondsSinceEpoch(
  //                                 time.millisecondsSinceEpoch),
  //                           )
  //                 : DateFormat('dd, MMMM').format(
  //                     DateTime.fromMillisecondsSinceEpoch(
  //                         time.millisecondsSinceEpoch),
  //                   ),
  //             style: TextStyle(color: darkMode ? Colors.white : Colors.black),
  //           ),
  //         ],
  //       ));
  // }

  _changeLike(Chats chat) async {
    if (chat.senderId != widget.currentUser.id) {
      chatsRef
          .doc(widget.chatId)
          .collection('messages')
          .doc(chat.id)
          .update({'isLiked': !chat.isLiked});
    }
    firstState = true;
    _getChat();
  }

  _buildChatTime(Chats chat, bool isMe) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        isMe
            ? chat.isLiked
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      MdiIcons.heart,
                      size: 25,
                      color: isMe ? secondColor : mainColor,
                    ),
                  )
                : SizedBox.shrink()
            : SizedBox.shrink(),
        Padding(
          padding: isMe
              ? const EdgeInsets.only(right: 10.0)
              : const EdgeInsets.only(left: 10.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              chat.time.toDate().day.compareTo(DateTime.now().day) < 0
                  ? DateFormat('dd MMM,hh:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          chat.time.millisecondsSinceEpoch),
                    )
                  : DateFormat('hh:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          chat.time.millisecondsSinceEpoch),
                    ),
              //timeago.format(chat.time.toDate()),
              style: TextStyle(
                  color: darkMode ? Colors.white : Colors.black,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        !isMe
            ? chat.isLiked
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      MdiIcons.heart,
                      size: 25,
                      color: isMe ? secondColor : mainColor,
                    ),
                  )
                : SizedBox.shrink()
            : SizedBox.shrink(),
        isMe
            ? chat.isSeen
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      MdiIcons.check,
                      size: 18,
                      color: darkMode ? Colors.white : Colors.black,
                    ),
                  )
                : SizedBox.shrink()
            : SizedBox.shrink(),
      ],
    );
  }

  _buildChat(Chats chat, bool isMe) {
    if (chat.flag == 'Sticker') {
      return GestureDetector(
        onDoubleTap: () {
          _changeLike(chat);
        },
        child: Container(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          //width: MediaQuery.of(context).size.width,
          margin: isMe
              ? EdgeInsets.only(
                  left: //MediaQuery.of(context).size.width > 1000
                      30,
                  //: MediaQuery.of(context).size.width * 0.4,
                  bottom: 10,
                  top: 10,
                )
              : EdgeInsets.only(
                  right: 30,
                  bottom: 10,
                  top: 10,
                ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: 150,
                child: Image.asset(
                  chat.mediaUrls[0],
                  fit: BoxFit.contain,
                ),
              ),
              _buildChatTime(chat, isMe)
            ],
          ),
        ),
      );
    } else if (chat.flag == 'GIF') {
      return GestureDetector(
        onDoubleTap: () => _changeLike(chat),
        child: Container(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          margin: isMe
              ? EdgeInsets.only(
                  left: 30,
                  bottom: 10,
                  top: 10,
                  right: 10,
                )
              : EdgeInsets.only(
                  right: 30,
                  bottom: 10,
                  top: 10,
                  left: 10,
                ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                //width: 300,
                decoration: BoxDecoration(
                  color: isMe ? mainColor : secondColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: isMe ? mainColor : secondColor, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: CachedNetworkImage(
                        width: 250,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) {
                          return circularProgress(context);
                        },
                        imageUrl: chat.mediaUrls[0],
                        httpHeaders: {'accept': 'image/*'},
                      ),
                    ),
                    chat.msg.length > 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 3),
                            child: Container(
                              width: 240,
                              child: Text(
                                chat.msg,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 5,
                                style: TextStyle(
                                    fontSize: 21,
                                    fontFamily: ('Gamja'),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                    //fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              _buildChatTime(chat, isMe)
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onDoubleTap: () => _changeLike(chat),
      child: Container(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe ? mainColor : secondColor,
                //borderRadius: BorderRadius.circular(8)
                borderRadius: isMe
                    ? BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
              ),
              margin: isMe
                  ? EdgeInsets.only(left: 100, bottom: 2, top: 5, right: 10)
                  : EdgeInsets.only(right: 100, bottom: 2, top: 5, left: 10),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Text(
                chat.msg,
                overflow: TextOverflow.clip,
                maxLines: 5,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontFamily: ('Gamja'),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildChatTime(chat, isMe)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTabbed) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor:
            darkMode ? Colors.black.withOpacity(1) : Colors.grey[100],
        body: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                image: AssetImage('assets/images/ocean_background.jpg'),
                fit: BoxFit.cover),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        icon: Icon(MdiIcons.phone),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Meeting(
                                        roomText: widget.chatId,
                                        subjectText: widget.friendUser.username,
                                        isVideo: false,
                                        currentUser: widget.currentUser,
                                      )));
                        }),
                    IconButton(
                        icon: Icon(MdiIcons.video),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Meeting(
                                        roomText: widget.chatId,
                                        subjectText: widget.friendUser.username,
                                        isVideo: true,
                                        currentUser: widget.currentUser,
                                      )));
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Home(
                                        user: widget.currentUser,
                                      )));
                        },
                        icon: Icon(
                          MdiIcons.closeCircle,
                          color: darkMode
                              ? Colors.grey[850]
                              : Colors.grey[400].withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: createChatsList(),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      if (MediaQuery.of(context).size.width > 1200) {
        return Home(
          user: widget.currentUser,
          currentChat: {
            'currentUser': widget.currentUser,
            'friendUser': widget.friendUser,
            'chatId': widget.chatId,
          },
          selecetedIndex: widget.selectedIndex,
        );
      } else {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: mainColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: mainColor,
            leading: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(50)),
              child: InkWell(
                focusColor: Colors.white,
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.only(right: 5.0, left: 15),
                  child: Container(
                    height: 40,
                    width: 30,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 50,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: widget.friendUser.photoUrl == ''
                      ? Image.asset('assets/icons/theme/icons8-account-64.png')
                      : Image.network(widget.friendUser.photoUrl),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    widget.friendUser.username,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: Icon(MdiIcons.phone),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Meeting(
                                      roomText: widget.chatId,
                                      subjectText: widget.friendUser.username,
                                      isVideo: false,
                                      currentUser: widget.currentUser,
                                    )));
                      }),
                  IconButton(
                      icon: Icon(MdiIcons.video),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Meeting(
                                      roomText: widget.chatId,
                                      subjectText: widget.friendUser.username,
                                      isVideo: true,
                                      currentUser: widget.currentUser,
                                    )));
                      }),
                ],
              )
            ],
          ),
          body: Container(
            color: mainColor,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
                color: darkMode ? Color(0xff121212) : Colors.white,
              ),
              child: createChatsList(),
            ),
          ),
        );
      }
    }
  }

  Future<bool> onBackPress() async {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
      return false;
    } else {
      if (MediaQuery.of(context).viewInsets.bottom > 1) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      } else
        Navigator.pop(context);
      return true;
    }
  }

  createChatsList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: ListView.builder(
                reverse: true,
                itemCount: chatsList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0)
                    return firstState
                        ? SizedBox.shrink()
                        : StreamBuilder<QuerySnapshot>(
                            stream: chatsRef
                                .doc(widget.chatId)
                                .collection('messages')
                                //.where('isSeen', isEqualTo: false)
                                .orderBy('timestamp', descending: true)
                                .limit(1)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return circularProgress(context);
                              } else {
                                Chats chat = Chats.fromDocument(
                                    snapshot.data.docs[index]);
                                bool isMe =
                                    chat.senderId == widget.currentUser.id;
                                if (!isMe && !chat.isSeen) {
                                  snapshot.data.docs[index].reference
                                      .update({'isSeen': true});
                                }

                                return _buildChat(chat, isMe);
                              }
                            });
                  else
                    return chatsList[index - 1];
                }),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0),
                        blurRadius: 5,
                        color: Color.fromARGB(30, 0, 0, 0),
                      )
                    ],
                    color: darkMode ? Colors.grey[900] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: secondColor,
                            borderRadius: BorderRadius.circular(50)),
                        child: isChanged || selectedGif != null
                            ? stickerButton()
                            : IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color:
                                      // !widget.darkMode
                                      //     ? Colors.black
                                      //     :
                                      Colors.white,
                                  size: 25,
                                ),
                                onPressed: () {}),
                      ),
                      Expanded(
                        child: TextField(
                          onTap: () {
                            if (selectedGif == null) {
                              setState(() {
                                isDisplaySticker = false;
                              });
                            } else {
                              try {
                                print(Platform.environment);
                                setState(() {
                                  wasFocused = true;
                                });
                              } catch (err) {}
                            }
                          },
                          textCapitalization: TextCapitalization.sentences,
                          //textInputAction: TextInputAction.send,
                          minLines: 1,
                          maxLines: 5,
                          style: TextStyle(
                              color: darkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600),
                          controller: sendController,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                            ),
                            border: InputBorder.none,
                            hintText: 'Message....',
                          ),
                          onChanged: (value) {
                            if (value.length > 0) {
                              setState(() {
                                this.isChanged = true;
                              });
                            } else {
                              setState(() {
                                this.isChanged = false;
                              });
                            }
                          },
                        ),
                      ),
                      isDisplaySticker
                          ? SizedBox.shrink()
                          : isChanged
                              ? Transform.rotate(
                                  angle: 180 * math.pi / 80,
                                  child: IconButton(
                                    icon: Icon(
                                      MdiIcons.clippy,
                                      size: 28,
                                      color: darkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    onPressed: () {
                                      print('pressed');
                                    },
                                  ),
                                )
                              : Row(
                                  children: [
                                    Transform.rotate(
                                      angle: 180 * math.pi / 80,
                                      child: IconButton(
                                        icon: Icon(
                                          MdiIcons.clippy,
                                          size: 28,
                                          color: darkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        onPressed: () {
                                          print('pressed');
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Send audio',
                                      padding: EdgeInsets.zero,
                                      icon: new Icon(
                                        MdiIcons.microphone,
                                        size: 28,
                                        color: darkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      onPressed: () {
                                        GetTenor(
                                          query: 'abe saale',
                                          limit: 20,
                                        ).getTenor();
                                      },
                                    ),
                                  ],
                                ),
                    ],
                  ),
                ),
              ),
              Container(
                  // height: 50,
                  // width: 50,
                  margin: EdgeInsets.only(left: 8, right: 2),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0),
                        blurRadius: 5,
                        spreadRadius: 5,
                        color: Color.fromARGB(25, 0, 0, 0),
                      )
                    ],
                    color: mainColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: isChanged || selectedGif != null
                      ? sendButton()
                      : stickerButton())
            ],
          ),
        ),
        isDisplaySticker ? createStickerTabs() : SizedBox.shrink(),
      ],
    );
  }

  sendButton() {
    return IconButton(
      icon: Padding(
        padding: const EdgeInsets.only(left: 2.0),
        child: Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        if (selectedGif == null) {
          sendMessage(sendController.text);
        } else {
          mediaUrls.add(selectedGif);
          sendMessage(sendController.text, flag: 'GIF');
          setState(() {
            selectedGif = null;
            isDisplaySticker = false;
          });
          sendController.clear();
        }
      },
    );
  }

  stickerButton() {
    return IconButton(
      icon: Icon(
        isDisplaySticker ? MdiIcons.close : MdiIcons.stickerEmoji,
        color: Colors.white,
      ),
      onPressed: () {
        if (!isDisplaySticker) {
          if (MediaQuery.of(context).viewInsets.bottom > 0)
            SystemChannels.textInput
                .invokeMethod('TextInput.hide')
                .catchError((err) {
              debugPrint(err.toString());
            });

          setState(() {
            isDisplaySticker = !isDisplaySticker;
            isSelectGif = false;
            searchGif = false;
          });
        } else {
          setState(() {
            isDisplaySticker = !isDisplaySticker;
            isSelectGif = false;
            searchGif = false;
            selectedGif = null;
            wasFocused = false;
          });
          if (MediaQuery.of(context).viewInsets.bottom <= 0)
            SystemChannels.textInput
                .invokeMethod('TextInput.show')
                .catchError((err) {
              debugPrint(err.toString());
            });
        }
      },
    );
  }

  createStickerTabs() {
    try {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: wasFocused ? 100 : 280,
        decoration: BoxDecoration(
          color: darkMode ? Colors.grey[900] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        margin: EdgeInsets.only(top: 5),
        // margin: EdgeInsets.symmetric(
        //     //vertical: 10,
        //     //horizontal: 10,
        //     ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            gifMode
                ? isLoading
                    ? Container(
                        height: 200,
                        child: Center(
                          child: circularProgress(context),
                        ),
                      )
                    : selectedGif == null
                        ? gifsList.length > 0
                            ? _buildGifPicker()
                            : SizedBox.shrink()
                        : Expanded(
                            child: GestureDetector(
                              onVerticalDragStart: (details) {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide')
                                    .catchError((err) {
                                  debugPrint(err.toString());
                                });
                                setState(() {
                                  wasFocused = false;
                                  selectedGif = null;
                                });
                              },
                              child: Container(
                                child: CachedNetworkImage(
                                  imageUrl: selectedGif,
                                  height: 250,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          )
                : Container(
                    height: 60,
                    // decoration: BoxDecoration(
                    //   color: darkMode ? Colors.grey[850] : Colors.grey[300],
                    //   borderRadius: BorderRadius.only(
                    //     topLeft: Radius.circular(15),
                    //     topRight: Radius.circular(15),
                    //   ),
                    // ),
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: List<Widget>.generate(10, (index) {
                        if (index == 1) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                stickerIndex = index;
                              });
                              pageController.animateToPage(index,
                                  duration: Duration(microseconds: 1),
                                  curve: Curves.bounceIn);
                            },
                            child: _buildStickerTab(index, 'gif'),
                          );
                        }
                        return InkWell(
                          onTap: () {
                            setState(() {
                              stickerIndex = index;
                            });
                            pageController.animateToPage(index,
                                duration: Duration(microseconds: 1),
                                curve: Curves.bounceIn);
                          },
                          child: _buildStickerTab(index, 'png'),
                        );
                      }),
                    ),
                  ),
            gifMode
                ? SizedBox.shrink()
                : Expanded(
                    child: _buildStickerTabView(),
                  ),
            wasFocused
                ? SizedBox.shrink()
                : Container(
                    color: darkMode
                        ? Colors.grey[850]
                        : Colors.grey[400].withOpacity(0.5),
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            searchGif ? Icons.arrow_back : Icons.search,
                            size: 20,
                            color: !gifMode
                                ? Colors.transparent
                                : darkMode
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          onPressed: () async {
                            setState(() {
                              searchGif = !searchGif;
                              searchGifController.clear();
                            });
                          },
                        ),
                        searchGif
                            ? Expanded(
                                child: TextField(
                                  style: TextStyle(
                                      color: darkMode
                                          ? Colors.white
                                          : Colors.black),
                                  controller: searchGifController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Seach a Giphy or tenor',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          searchGifController.clear();
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          color: darkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      )),
                                  onSubmitted: (msg) async {
                                    setState(() {
                                      gifsList.clear();
                                    });
                                    final gifs =
                                        await GetTenor(query: msg, limit: 20)
                                            .getTenor();
                                    setState(() {
                                      gifsList = gifs;
                                    });

                                    // final GiphyCollection gifs = await client.search(
                                    //   msg,
                                    //   offset: 1,
                                    //   limit: 100,
                                    //   rating: GiphyRating.r,
                                    // );
                                    // gifs.data.forEach((element) {
                                    //   //print(element.images.downsizedLarge.url);
                                    //   setState(() {
                                    //     gifsList.add(element);
                                    //   });
                                    // });
                                  },
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      MdiIcons.stickerEmoji,
                                      size: 20,
                                      color: !gifMode
                                          ? secondColor
                                          : darkMode
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        gifMode = false;
                                        isLoading = true;
                                        selectedGif = null;
                                      });
                                    },
                                  ),
                                  IconButton(
                                      icon: Icon(
                                        Icons.gif,
                                        size: 30,
                                        color: gifMode
                                            ? secondColor
                                            : darkMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          gifMode = true;
                                          gifsList.clear();
                                          isLoading = true;
                                        });
                                        var gifs = await GetTenor(
                                                query: 'trending', limit: 20)
                                            .getTenor();

                                        setState(() {
                                          gifsList = gifs;
                                        });

                                        setState(() {
                                          isLoading = false;
                                        });
                                      }),
                                ],
                              ),
                        searchGif
                            ? SizedBox.shrink()
                            : SizedBox(
                                width: 50,
                              )
                      ],
                    ),
                  ),
          ],
        ),
      );
    } catch (err) {
      print(err);
    }
  }

  _buildStickerTab(final int packNum, String type) {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              width: 2,
              color:
                  stickerIndex == (packNum) ? secondColor : Colors.transparent),
        ),
      ),
      child: Container(
        child: Image.asset(
          'assets/sticker_packs/${packNum + 1}/1.$type',
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          height: 40,
          width: 40,
        ),
      ),
    );
  }

  _buildStickerGrid(int packNum, int length, String type) {
    return Scrollbar(
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 1600
            ? 6
            : MediaQuery.of(context).size.width > 1200
                ? 5
                : MediaQuery.of(context).size.width > 700
                    ? 4
                    : 3,
        children: List.generate(length, (index) {
          return FlatButton(
            onPressed: () {
              final pack = packNum;
              final val = index + 1;
              sendStickers('assets/sticker_packs/$pack/$val.$type');
            },
            child: Image.asset(
              'assets/sticker_packs/$packNum/${index + 1}.$type',
              fit: BoxFit.cover,
            ),
          );
        }),
      ),
    );
  }

  _buildStickerTabView() {
    return PageView(
      controller: pageController,
      children: [
        _buildStickerGrid(1, 25, 'png'),
        _buildStickerGrid(2, 10, 'gif'),
        _buildStickerGrid(3, 51, 'png'),
        _buildStickerGrid(4, 29, 'webp'),
        _buildStickerGrid(5, 29, 'webp'),
        _buildStickerGrid(6, 29, 'webp'),
        _buildStickerGrid(7, 19, 'webp'),
        _buildStickerGrid(8, 23, 'webp'),
        _buildStickerGrid(9, 26, 'webp'),
        _buildStickerGrid(10, 29, 'webp'),
      ],
      onPageChanged: (pageIndex) => onTap(pageIndex),
    );
  }

  _buildGifPicker() {
    return Expanded(
      child: Scrollbar(
        child: Container(
          padding: EdgeInsets.all(5),
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1600
                ? 5
                : MediaQuery.of(context).size.width > 1200
                    ? 4
                    : MediaQuery.of(context).size.width > 700
                        ? 3
                        : 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            shrinkWrap: true,
            children: List.generate(gifsList.length, (index) {
              var gif = gifsList[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    //isDisplaySticker = false;
                    selectedGif = gif;
                  });
                },
                child: Container(
                  height: 100,
                  child: CachedNetworkImage(
                    fit: BoxFit.fitHeight,
                    height: 100,
                    //useOldImageOnUrlChange: true,
                    placeholder: (context, url) {
                      return circularProgress(context);
                    },
                    imageUrl: gif,
                    httpHeaders: {'accept': 'image/*'},
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class GetTenor {
  final String apikey = 'DV1CTE6FHHVC';
  final String query;
  final int limit;

  GetTenor({this.query, this.limit});
  Future getTenor() async {
    var url = query == 'trending'
        ? 'https://api.tenor.com/v1/trending?key=$apikey&limit=50'
        : 'https://api.tenor.com/v1/search?q=$query&key=$apikey&limit=$limit';
    List<String> gifUrls = [];
    var response = await Requests.get(url);

    if (response.statusCode == 200) {
      for (var res in response.json()['results']) {
        gifUrls.add(res['media'][0]['tinygif']['url']);
      }
      return gifUrls;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}
