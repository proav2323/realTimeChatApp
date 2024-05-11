import 'dart:developer';
import 'dart:math' as ma;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:realtimechatapp/AddGroupDailog.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/Chat.dart';
import 'package:realtimechatapp/ChatDb.dart';
import 'package:realtimechatapp/ChatUi.dart';
import 'package:realtimechatapp/Input.dart';
import 'package:realtimechatapp/PopumMenu.dart';
import 'package:realtimechatapp/SeachInput.dart';
import 'package:realtimechatapp/SearchPage.dart';
import 'package:realtimechatapp/Socket.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realtimechatapp/UpdateProfile.dart';
import 'package:realtimechatapp/User.dart' as Us;
import 'package:realtimechatapp/UserUi.dart';
import 'package:realtimechatapp/pages/Login.dart';
import 'package:realtimechatapp/state/Chat/ChatCubit.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.loginTry = false});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
  final bool loginTry;
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool connected = false;
  bool loading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  Us.User? user = null;
  bool tryLogin = false;
  AppLifecycleState? _lastLifecycleState;
  ChatDb chatdb = ChatDb();
  bool chatLoading = false;
  Stream<QuerySnapshot> chatStream = Stream.empty();
  Stream<QuerySnapshot> userStream = Stream.empty();
  TextEditingController search = TextEditingController();

  Future<void> selectedUpadte(String value) async {
    if (value == "update") {
      showDialog(
          context: context,
          builder: (BuildContext context) => const Dialog(
                child: UpdateProfile(),
              ));
    } else if (value == "settings") {
    } else {
      auth.signOut().then((value) {
        Auth(callback: () {}).upadetOnline(
            context.read<UserCubit>().state != null
                ? context.read<UserCubit>().state!.id
                : "",
            false);
        context.read<UserCubit>().login(null);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (auth.currentUser != null || context.read<UserCubit>().state != null) {
      getChats();
      if (context.read<UserCubit>().state == null) {
        Auth authC = Auth(callback: authCallBack);
        authC.getUserDb(auth.currentUser!.uid).then((value) {
          Us.User user = value;
          context.read<UserCubit>().login(user);
        });
      }
      Socket socket = Socket(callabck: callBack);
      socket.init();
      connected = socket.getConnected();
      loading = socket.getLoading();
      setState(() {
        chatLoading = true;
      });
      chatdb.getAllUserChats(auth.currentUser!.uid).then((value) {
        setState(() {
          chatLoading = false;
        });
      });
    }

    auth.authStateChanges().listen((event) {
      if (event == null) {
      } else {
        Auth authC = Auth(callback: authCallBack);
        authC.getUserDb(event.uid).then((value) {
          Us.User user = value;
          getChats();
          if (mounted) {
            context.read<UserCubit>().login(user);
            log(context.read<UserCubit>().state!.email, name: "home");
          }
        });
      }
    });

    if (widget.loginTry) {
      Future.delayed(Duration(seconds: 3));
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (auth.currentUser == null &&
            context.read<UserCubit>().state == null) {
          log("dslmc", name: "home");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Login()),
              (Route<dynamic> route) => false);
        }
      });
    } else {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (auth.currentUser == null &&
            context.read<UserCubit>().state == null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Login()),
              (Route<dynamic> route) => false);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    search.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      log("loll", name: "detached");
      Socket.socket.disconnect();
    } else if (state == AppLifecycleState.resumed) {
      Socket socket = Socket(callabck: callBack);
      socket.init();
      getChats();
    } else if (state == AppLifecycleState.hidden) {
      Socket socket = Socket(callabck: callBack);
      socket.init();
      getChats();
    }
  }

  callBack(bool chnage) {
    log("this calback", name: "callback");
    if (auth.currentUser != null && chnage == true) {
      Auth authC = Auth(callback: authCallBack);
      authC.getUserDb(auth.currentUser!.uid).then((value) {
        Us.User user = value;
        if (mounted) {
          context.read<UserCubit>().login(user);
          log(context.read<UserCubit>().state!.email, name: "home and data");
        }
      });
    }
  }

  authCallBack() {}

  getChats() {
    if (auth.currentUser != null) {
      CollectionReference chatrRef = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection("chats");
      if (mounted) {
        setState(() {
          chatStream =
              chatrRef.orderBy("lastMessageAt", descending: true).snapshots();
        });
      }

      chatrRef.get().then((value) {
        List<String> data = [];
        value.docs.forEach((element) {
          data.add(element.get("id"));
        });
        log(data.toString(), name: "get users checking");
        getUsers(data);
      });
    } else {
      if (mounted == true) {
        setState(() {
          chatStream = Stream.empty();
        });
      }
    }
  }

  getUsers(List<String> ids) {
    List<String> data = [...ids, auth.currentUser!.uid];
    log(data.toString(), name: "get users checking");
    if (auth.currentUser != null && mounted == true) {
      setState(() {
        userStream = FirebaseFirestore.instance
            .collection('users')
            .where("id", whereNotIn: data)
            .snapshots();
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, List<Chat>?>(
        builder: (context, chatState) => BlocBuilder<UserCubit, Us.User?>(
            builder: (context, state) => Scaffold(
                appBar: AppBar(
                  title: Text("Chatty"),
                  actions: state != null
                      ? [
                          state.profileImg != ""
                              ? CustomPopumMenu(
                                  icon: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircleAvatar(
                                        radius: 48,
                                        backgroundImage:
                                            NetworkImage(state.profileImg!),
                                      )),
                                  fun: selectedUpadte,
                                  data: const [
                                    PopupMenuItem(
                                      value: "update",
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Update Profile"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: "settings",
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.settings),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Settings"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: "logout",
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.logout),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Logout"),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : CustomPopumMenu(
                                  icon: Icon(Icons.account_circle),
                                  fun: selectedUpadte,
                                  data: const [
                                    PopupMenuItem(
                                      value: "update",
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Update Profile"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: "settings",
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.settings),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Settings"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: "logout",
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.logout),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("Logout"),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                        ]
                      : [],
                  bottom: PreferredSize(
                      preferredSize:
                          Size(MediaQuery.of(context).size.width, 70),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(8),
                        child: SizedBox(
                            width: double.infinity,
                            child: SearchInput(
                              controller: search,
                              title: "Search",
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 2),
                              error: "",
                              validate: (String val) {},
                              gradiantColors: const [],
                              submit: (String val) {
                                if (val != "") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SearchPage(search: val)));
                                }
                              },
                            )),
                      )),
                ),
                floatingActionButton: state != null
                    ? FloatingActionButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              const Dialog.fullscreen(
                            child: AddGroup(),
                          ),
                        ),
                        child: const Icon(Icons.add),
                      )
                    : const SizedBox(),
                body: SingleChildScrollView(
                    child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(auth.currentUser!.uid)
                          .collection("chats")
                          .orderBy("lastMessageAt", descending: true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.data == null || snapshot.data!.size == 0) {
                          return Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("users")
                                    .where("id", whereNotIn: [
                                  auth.currentUser!.uid
                                ]).snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshott) {
                                  if (snapshott.hasError) {
                                    return const Text('Something went wrong');
                                  }

                                  if (snapshott.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (snapshott.data == null ||
                                      snapshott.data!.size == 0) {
                                    return const SizedBox();
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding:
                                              const EdgeInsets.only(left: 4),
                                          child: const Text(
                                            "Other Users",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          )),
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 4),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: snapshott.data == null
                                                ? const [SizedBox()]
                                                : snapshott.data!.docs
                                                    .map((e) {
                                                      return UserUi(
                                                          e: e,
                                                          key: Key(
                                                              "${ma.Random().nextDouble()}"));
                                                    })
                                                    .toList()
                                                    .cast(),
                                          )),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Container(
                                padding: const EdgeInsets.only(left: 4),
                                child: const Text(
                                  "your chats",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                width: MediaQuery.of(context).size.width,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: snapshot.data == null
                                      ? [const SizedBox()]
                                      : snapshot.data!.docs
                                          .map((e) {
                                            return ChatUi(
                                              key: Key(
                                                  "${ma.Random().nextDouble()}"),
                                              e: e,
                                            );
                                          })
                                          .toList()
                                          .cast(),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .where("id", whereNotIn: [
                                ...snapshot.data!.docs.map((e) => e.get("id")),
                                auth.currentUser!.uid
                              ]).snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshott) {
                                if (snapshott.hasError) {
                                  return const Text('Something went wrong');
                                }

                                if (snapshott.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshott.data == null ||
                                    snapshott.data!.size == 0) {
                                  return const SizedBox();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: const Text(
                                          "Other Users",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        )),
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 4),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: snapshott.data == null
                                              ? const [SizedBox()]
                                              : snapshott.data!.docs
                                                  .map((e) {
                                                    return UserUi(
                                                      e: e,
                                                      key: Key(
                                                          "${ma.Random().nextDouble()}"),
                                                    );
                                                  })
                                                  .toList()
                                                  .cast(),
                                        )),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                )))));
  }
}
