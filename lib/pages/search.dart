import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:PlatiQ/models/users.dart';
import 'package:PlatiQ/pages/home.dart';
import 'package:PlatiQ/widgets/colors.dart';
import 'package:PlatiQ/widgets/progress.dart';
import 'package:uuid/uuid.dart';

class Search extends StatefulWidget {
  final MyUser currentUser;
  Search({this.currentUser});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot> searchResultsFuture;
  List<UserResult> searchResults = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //Stream<QuerySnapshot> searchUsernameResultsFuture;
  //StreamZip finalStreams;
  MyUser userSent;
  bool isLoading = false;
  bool isChanged = false;
  @override
  void initState() {
    super.initState();
    searchResults = [];
  }

  capitalize(String s) {
    if (s.contains(' ')) {
      return capitalize(s.split(' ')[0]) + ' ' + capitalize(s.split(' ')[1]);
    } else
      return s[0].toUpperCase() + s.substring(1);
  }

  handleSearch(String query) async {
    setState(() {
      this.isLoading = true;
      this.searchResults = [];
    });
    usersRef.where("email", isEqualTo: query).get().then((docs) {
      docs.docs.forEach((element) {
        MyUser user = MyUser.fromDocument(element);
        UserResult searchResult = UserResult(user, widget.currentUser, true);
        setState(() {
          this.searchResults.add(searchResult);
        });
      });
    });

    usersRef
        .where("username", whereIn: [
          query,
          query.toUpperCase(),
          query.toUpperCase(),
          capitalize(query),
        ])
        .get()
        .then((snapshot) {
          snapshot.docs.forEach((doc) {
            MyUser user = MyUser.fromDocument(doc);
            UserResult searchResult =
                UserResult(user, widget.currentUser, true);
            setState(() {
              this.searchResults.add(searchResult);
              this.isLoading = false;
            });
          });
        });

    setState(() {
      this.isLoading = false;
    });
  }

  clearSearch() {
    searchController.clear();
    setState(() {
      this.searchResults.clear();
      this.isChanged = false;
    });
  }

  buildNoContent() {
    final orientation = MediaQuery.of(context).orientation;
    return MediaQuery.of(context).viewInsets.bottom > 0
        ? SizedBox.shrink()
        : StreamBuilder(
            stream: usersRef
                .doc(widget.currentUser.id)
                .collection('requestsGot')
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? circularProgress(context)
                  : snapshot.data.documents.length == 0
                      ? Container(
                          child: Center(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: <Widget>[
                                Image.asset(
                                  'assets/icons/material/icons8-view-64.png',
                                  height: orientation == Orientation.portrait
                                      ? 150
                                      : 100,
                                ),
                                Text(
                                  "Find Users",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    //fontStyle: FontStyle.italic,
                                    fontFamily: 'Oleo',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 45.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 20),
                                child: Row(
                                  children: [
                                    Text(
                                      'Friend Requests : ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Fredoka',
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              //Padding(padding: EdgeInsets.all(10)),
                              Divider(
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                                color: Colors.grey,
                              ),
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder: (context, index) {
                                      usersRef
                                          .doc(snapshot.data.documents[index]
                                              .get('senderId'))
                                          .get()
                                          .then((doc) {
                                        setState(() {
                                          userSent = MyUser.fromDocument(doc);
                                        });
                                      });

                                      return userSent == null
                                          ? circularProgress(context)
                                          : UserResult(userSent,
                                              widget.currentUser, false);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
            });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                mainColor,
                secondColor,
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 700,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            // width: 40,
                            // height: 40,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              MdiIcons.arrowLeftThick,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Add People',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          isChanged
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.black,
                                  ),
                                  onPressed: clearSearch,
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                          Container(
                            //padding: const EdgeInsets.only(left: 10),
                            width: 300,
                            child: TextField(
                              maxLines: 1,
                              controller: searchController,
                              style: TextStyle(
                                  color: Colors.black, fontFamily: 'Fredoka'),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: 'Fredoka'),
                                hintText: 'Search a user or conversation....',
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
                              onSubmitted: handleSearch,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  isLoading
                      ? circularProgress(context)
                      : searchResults.length == 0
                          ? buildNoContent()
                          : Expanded(
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                padding: EdgeInsets.zero,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemCount: searchResults.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return searchResults[index];
                                  },
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserResult extends StatefulWidget {
  final MyUser user;
  final MyUser currentUser;
  final bool endInfo;

  UserResult(this.user, this.currentUser, this.endInfo);
  @override
  _UserResultState createState() => _UserResultState();
}

class _UserResultState extends State<UserResult> {
  bool isSent = false;
  bool isFriend = false;
  bool isMe = false;
  checkRequest() {
    if (widget.currentUser.id == widget.user.id) {
      setState(() {
        isMe = true;
      });
    } else {
      usersRef
          .doc(widget.currentUser.id)
          .collection('requestsSent')
          .doc(widget.user.id)
          .get()
          .then((value) {
        setState(() {
          if (value.exists) {
            this.isSent = true;
          }
        });
      });
      usersRef
          .doc(widget.currentUser.id)
          .collection('friends')
          .doc(widget.user.id)
          .get()
          .then((value) {
        if (value.exists) {
          if (mounted) {
            setState(() {
              this.isFriend = true;
            });
          }
        }
      });
    }
  }

  @override
  void initState() {
    checkRequest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 20, right: 20),
      //margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: widget.user.photoUrl == ''
                ? AssetImage('assets/icons/theme/icons8-account-64.png')
                : CachedNetworkImageProvider(widget.user.photoUrl),
          ),
          title: Text(
            widget.user.username,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          subtitle: Text(
            widget.user.email,
            style: TextStyle(color: textColor),
          ),
          trailing: !widget.endInfo
              ? InkWell(
                  onTap: () {
                    final chatId = Uuid().v4();
                    usersRef
                        .doc(widget.currentUser.id)
                        .collection('friends')
                        .doc(widget.user.id)
                        .set({
                      'id': widget.user.id,
                      'photoUrl': widget.user.photoUrl,
                      'email': widget.user.email,
                      'username': widget.user.username,
                      'timestamp': DateTime.now(),
                      'mobile': '',
                      'online': true,
                      'chatId': chatId,
                    });
                    usersRef
                        .doc(widget.user.id)
                        .collection('friends')
                        .doc(widget.currentUser.id)
                        .set({
                      'id': widget.currentUser.id,
                      'photoUrl': widget.currentUser.photoUrl,
                      'email': widget.currentUser.email,
                      'username': widget.currentUser.username,
                      'timestamp': DateTime.now(),
                      'mobile': '',
                      'online': true,
                      'chatId': chatId,
                    });
                    usersRef
                        .doc(widget.user.id)
                        .collection('requestsSent')
                        .doc(widget.currentUser.id)
                        .delete();
                    usersRef
                        .doc(widget.user.id)
                        .collection('requestsGot')
                        .doc(widget.currentUser.id)
                        .get()
                        .then((doc) {
                      if (doc.exists) {
                        doc.reference.delete();
                      }
                    });
                    usersRef
                        .doc(widget.currentUser.id)
                        .collection('requestsGot')
                        .doc(widget.user.id)
                        .delete();
                    usersRef
                        .doc(widget.currentUser.id)
                        .collection('requestsSent')
                        .doc(widget.user.id)
                        .get()
                        .then((doc) {
                      if (doc.exists) {
                        doc.reference.delete();
                      }
                    });
                    showSnackbar(context, msg: 'Request Accepted');
                  },
                  child: Text(
                    'Accept',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'Fredoka'),
                  ),
                )
              : isFriend
                  ? SizedBox.shrink()
                  : isSent
                      ? InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      'Do you want to cancel the request?',
                                      style: TextStyle(fontFamily: "Fredoka"),
                                    ),
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FlatButton(
                                              onPressed: () {
                                                usersRef
                                                    .doc(widget.user.id)
                                                    .collection('requestsGot')
                                                    .doc(widget.currentUser.id)
                                                    .delete();
                                                usersRef
                                                    .doc(widget.currentUser.id)
                                                    .collection('requestsSent')
                                                    .doc(widget.user.id)
                                                    .delete();
                                                setState(() {
                                                  this.isSent = false;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text('Yes')),
                                          FlatButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('No'))
                                        ],
                                      )
                                    ],
                                  );
                                });
                          },
                          child: Container(
                            height: 50,
                            width: 40,
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 9,
                                  //right: 9,
                                  //left: 2,
                                  child: Container(
                                    height: 30,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                            colors: [
                                              mainColor,
                                              secondColor,
                                            ]),
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                  ),
                                ),
                                Positioned(
                                  bottom: 16,
                                  left: 5,
                                  child: Text(
                                    'Sent',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Fredoka',
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: 50,
                          width: 40,
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 9,
                                //right: 9,
                                //left: 2,
                                child: Container(
                                  height: 30,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            mainColor,
                                            secondColor,
                                          ]),
                                      borderRadius: BorderRadius.circular(25)),
                                ),
                              ),
                              Center(
                                child: isMe
                                    ? Text(
                                        'Me',
                                        style: TextStyle(
                                            fontFamily: "Fredoka",
                                            color: Colors.white),
                                      )
                                    : IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: textColor,
                                        ),
                                        onPressed: () {
                                          usersRef
                                              .doc(widget.user.id)
                                              .collection('requestsGot')
                                              .doc(widget.currentUser.id)
                                              .set({
                                            'senderId': widget.currentUser.id,
                                            'status': 'Pending',
                                            'timestamp': DateTime.now()
                                          });
                                          usersRef
                                              .doc(widget.currentUser.id)
                                              .collection('requestsSent')
                                              .doc(widget.user.id)
                                              .set({
                                            'receiverId': widget.user.id,
                                            'status': 'Pending',
                                            'timestamp': DateTime.now(),
                                          });
                                          showSnackbar(context,
                                              msg: 'Request Sent');
                                          setState(() {
                                            this.isSent = true;
                                          });
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
        ),
      ),
    );
  }
}
