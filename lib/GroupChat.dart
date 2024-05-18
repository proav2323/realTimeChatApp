import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/ChatMessage.dart';
import 'package:realtimechatapp/EditDailog.dart';
import 'package:realtimechatapp/EditGroupDialog.dart';
import 'package:realtimechatapp/Group.dart';
import 'package:realtimechatapp/GroupDb.dart';
import 'package:realtimechatapp/GroupMembers.dart';
import 'package:realtimechatapp/GroupMessageUi.dart';
import 'package:realtimechatapp/Input.dart';
import 'package:realtimechatapp/Messaging.dart';
import 'package:realtimechatapp/PopumMenu.dart';
import 'package:realtimechatapp/User.dart';
import 'package:realtimechatapp/pages/Home.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';
import "dart:developer";

class GroupChat extends StatefulWidget {
  GroupChat(
      {super.key,
      required this.id,
      required this.userUi,
      this.chatLastMessage = ""});
  String id;
  bool userUi;
  String? chatLastMessage;

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  Group? chat = null;
  bool loading = false;
  String _orderBy =
      'createdAt'; //? HERE YOU PUT WHAT YOUR SORTING FIELD NAME IS
  bool _isDescending = false;
  late bool userUi;
  TextEditingController search = TextEditingController();
  late Stream<QuerySnapshot<Map<String, dynamic>>> chatsStream;
  ScrollController _scrollController = ScrollController();
  bool _firstAutoscrollExecuted = false;
  bool _shouldAutoscroll = false;

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _scrollListener() {
    _firstAutoscrollExecuted = true;

    if (_scrollController.hasClients &&
        _scrollController.position.pixels <
            _scrollController.position.maxScrollExtent) {
    } else {
      _shouldAutoscroll = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    setState(() {
      loading = true;
      userUi = widget.userUi;

      if (_scrollController.hasClients && _shouldAutoscroll) {
        _scrollToBottom();
      }

      if (!_firstAutoscrollExecuted && _scrollController.hasClients) {
        _scrollToBottom();
      }
    });

    FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.id)
        .get()
        .then((data) {
      GroupDb().getChat(data).then((value) {
        setState(() {
          chat = value;
          loading = false;
        });
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {}
    });

    if (userUi == false &&
        mounted == true &&
        context.read<UserCubit>().state != null) {
      FirebaseFirestore.instance
          .collection("groups")
          .doc(widget.id)
          .collection("messages")
          .where("reciverId",
              arrayContains: context.read<UserCubit>().state!.id)
          .where("seen", whereNotIn: [context.read<UserCubit>().state!.id])
          .get()
          .then((value) {
            value.docs.forEach((element) {
              FirebaseFirestore.instance
                  .collection("groups")
                  .doc(widget.id)
                  .collection("messages")
                  .doc(element.get("id"))
                  .update({
                "seen":
                    FieldValue.arrayUnion([context.read<UserCubit>().state!.id])
              });
            });
          });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    search.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
  }

  void sendMessage() async {
    if (context.read<UserCubit>().state != null &&
        search.text != "" &&
        chat != null) {
      List<dynamic> members = chat!.members
          .where((data) => data != context.read<UserCubit>().state!.id)
          .toList();

      List<dynamic> membersTokens = [];
      for (int i = 0; i < members.length; i++) {
        User user = await Auth(callback: () {}).getUserDb(members[i]);
        user.token.forEach((element) {
          membersTokens.add(element);
        });
      }
      GroupDb()
          .sendMessage(search.text, context.read<UserCubit>().state!.id,
              chat!.id, members)
          .then((value) {
        log(membersTokens.toString(), name: "check");
        if (value == true) {
          Messaging()
              .sendGroupPushNotification(
                  chat!.id,
                  context.read<UserCubit>().state!.id,
                  search.text,
                  membersTokens)
              .then((value) {
            if (value == true) {}
          });
          search.clear();
          if (_scrollController.hasClients) {
            _scrollToBottom();
          }
        }
      });
    }
  }

  void selected(String data) {
    if (data == "delete") {
      GroupDb().deleteGroup(chat!.id).then((value) {
        if (value == true) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("you have deleted the group")));
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const MyHomePage(
                        loginTry: false,
                      )),
              (route) => false);
        }
      });
    } else if (data == "leave") {
      GroupDb()
          .removeMember(context.read<UserCubit>().state!.id, chat!.id)
          .then((value) {
        if (value == true) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("you have left the group")));
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const MyHomePage(
                        loginTry: false,
                      )),
              (route) => false);
        }
      });
    } else if (data == "edit") {
      showDialog(
          context: context,
          builder: (BuildContext context) => Dialog(
              child: EdutGroup(
                  chatId: chat!.id,
                  prevName: chat!.name,
                  callBack: () {
                    FirebaseFirestore.instance
                        .collection("groups")
                        .doc(chat!.id)
                        .get()
                        .then((value) {
                      GroupDb().getChat(value).then((value) {
                        setState(() {
                          chat = value;
                        });
                      });
                    });
                  })));
    }
  }

  seen() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels <
            _scrollController.position.maxScrollExtent) {
      FirebaseFirestore.instance
          .collection("groups")
          .doc(widget.id)
          .collection("messages")
          .where("reciverId",
              arrayContains: context.read<UserCubit>().state!.id)
          .where("seen", whereNotIn: [context.read<UserCubit>().state!.id])
          .get()
          .then((value) {
            value.docs.forEach((element) {
              FirebaseFirestore.instance
                  .collection("groups")
                  .doc(widget.id)
                  .collection("messages")
                  .doc(element.get("id"))
                  .update({
                "seen":
                    FieldValue.arrayUnion([context.read<UserCubit>().state!.id])
              });
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: loading == false && chat != null
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                chat!.name,
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GroupMembers(group: chat!, id: chat!.id))),
                    icon: const Icon(Icons.group)),
                CustomPopumMenu(fun: selected, data: [
                  const PopupMenuItem(
                    value: "block",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.block),
                        SizedBox(
                          width: 5,
                        ),
                        Text("Block"),
                      ],
                    ),
                  ),
                  chat!.createdBy == context.read<UserCubit>().state!.id
                      ? const PopupMenuItem(
                          value: "edit",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.block),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Edit Name",
                              ),
                            ],
                          ))
                      : const PopupMenuItem(child: SizedBox()),
                  chat!.createdBy == context.read<UserCubit>().state!.id
                      ? const PopupMenuItem(
                          value: "delete",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.block),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Delete Group",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ))
                      : const PopupMenuItem(
                          value: "leave",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.block),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Leave Group",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          )),
                ])
              ],
            )
          : AppBar(automaticallyImplyLeading: false),
      floatingActionButton: _scrollController.hasClients
          ? _scrollController.position.pixels >=
                  _scrollController.position.maxScrollExtent
              ? const SizedBox()
              : FloatingActionButton(
                  onPressed: () {
                    // Add your onPressed action here
                    _scrollToBottom();
                  },
                  child: Icon(Icons.arrow_downward))
          : FloatingActionButton(
              onPressed: () {
                // Add your onPressed action here
                _scrollToBottom();
              },
              child: Icon(Icons.arrow_downward),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      body: Column(
        children: loading
            ? const [LinearProgressIndicator()]
            : chat != null
                ? [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("groups")
                          .doc(widget.id)
                          .collection("messages")
                          .orderBy(_orderBy, descending: _isDescending)
                          .snapshots(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot,
                      ) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.data == null ||
                            snapshot.data!.docs.isEmpty == true) {
                          return const Expanded(child: SizedBox());
                        }
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            seen();
                            _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent);
                          }
                        });
                        return Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                              Container(
                                margin: const EdgeInsets.all(8),
                                child: const Text(
                                  "messages",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                              Expanded(
                                  child: ListView(
                                shrinkWrap: true,
                                controller: _scrollController,
                                children: snapshot.data == null
                                    ? [SizedBox()]
                                    : snapshot.data!.docs
                                        .map((e) {
                                          return GroupMessageUi(
                                            message: e,
                                            group: chat!,
                                            chatId: widget.id,
                                            prevMessage: widget.userUi
                                                ? ""
                                                : widget.chatLastMessage!,
                                            key: Key(
                                                "${math.Random().nextDouble()}"),
                                          );
                                        })
                                        .toList()
                                        .cast(),
                              ))
                            ]));
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Input(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            controller: search,
                            title: "Message",
                            error: "",
                            validate: (String data) {},
                            gradiantColors: const [],
                          )),
                          IconButton(
                              onPressed: sendMessage,
                              icon: const Icon(Icons.send))
                        ],
                      ),
                    ),
                  ]
                : const [
                    Center(
                      child: Text("somehtign went wrong"),
                    )
                  ],
      ),
    );
  }
}
