import 'dart:math' as math;
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/Chat.dart';
import 'package:realtimechatapp/ChatDb.dart';
import 'package:realtimechatapp/ChatMessage.dart';
import 'package:realtimechatapp/Input.dart';
import 'package:realtimechatapp/Messaging.dart';
import 'package:realtimechatapp/PopumMenu.dart';
import 'package:realtimechatapp/User.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';

class NewChat extends StatefulWidget {
  NewChat(
      {super.key,
      required this.id,
      required this.userUi,
      this.chatLastMessage = ""});
  String id;
  bool userUi;
  String? chatLastMessage;

  @override
  State<NewChat> createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  User? user = null;
  Chat? chat = null;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {});

    Auth(callback: () {}).getUserDb(widget.id).then((value) {
      setState(() {
        user = value;
        loading = false;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {}
    });

    if (userUi == false &&
        mounted == true &&
        context.read<UserCubit>().state != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(context.read<UserCubit>().state!.id)
          .collection("chats")
          .doc(widget.id)
          .collection("messages")
          .where("reciverId", isEqualTo: context.read<UserCubit>().state!.id)
          .where("seen", isEqualTo: false)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(context.read<UserCubit>().state!.id)
              .collection("chats")
              .doc(widget.id)
              .collection("messages")
              .doc(element.get("id"))
              .update({"seen": true});

          FirebaseFirestore.instance
              .collection("users")
              .doc(widget.id)
              .collection("chats")
              .doc(context.read<UserCubit>().state!.id)
              .collection("messages")
              .doc(element.get("id"))
              .update({"seen": true});
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

  void sendMessage() {
    if (user != null &&
        context.read<UserCubit>().state != null &&
        search.text != "") {
      ChatDb()
          .sendMessage(
              search.text, context.read<UserCubit>().state!.id, user!.id)
          .then((value) {
        if (value == true) {
          if (_scrollController.hasClients) {
            _scrollToBottom();
          }
          Messaging().SendPushNotification(
              user!.id, context.read<UserCubit>().state!.id, search.text);
          search.clear();
        }
      });
    }
  }

  void selected(String data) {}

  void seen() {
    log("check", name: "cjck");
    FirebaseFirestore.instance
        .collection("users")
        .doc(context.read<UserCubit>().state!.id)
        .collection("chats")
        .doc(widget.id)
        .collection("messages")
        .where("reciverId", isEqualTo: context.read<UserCubit>().state!.id)
        .where("seen", isEqualTo: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(context.read<UserCubit>().state!.id)
            .collection("chats")
            .doc(widget.id)
            .collection("messages")
            .doc(element.get("id"))
            .update({"seen": true});

        FirebaseFirestore.instance
            .collection("users")
            .doc(widget.id)
            .collection("chats")
            .doc(context.read<UserCubit>().state!.id)
            .collection("messages")
            .doc(element.get("id"))
            .update({"seen": true});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: loading == false && user != null
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  user!.profileImg != ""
                      ? SizedBox(
                          width: 40,
                          height: 40,
                          child: CircleAvatar(
                              backgroundImage: NetworkImage(
                            user!.profileImg!,
                          )))
                      : const SizedBox(
                          height: 40,
                          width: 40,
                          child: Icon(
                            Icons.account_circle,
                          )),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user!.name,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        user!.online ? "online" : "offline",
                        style: TextStyle(
                            fontSize: 14,
                            color: user!.online ? Colors.green : Colors.red),
                      )
                    ],
                  )
                ],
              ),
              actions: [
                CustomPopumMenu(fun: selected, data: const [
                  PopupMenuItem(
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
                  )
                ])
              ],
            )
          : AppBar(automaticallyImplyLeading: false),
      floatingActionButton: _scrollController.hasClients
          ? _scrollController.position.pixels >=
                  _scrollController.position.maxScrollExtent
              ? SizedBox()
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
            : user != null
                ? [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(context.read<UserCubit>().state!.id)
                          .collection("chats")
                          .doc(user!.id)
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
                                          return ChatMessage(
                                            scrollController: _scrollController,
                                            message: e,
                                            chatId: user!.id,
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
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            controller: search,
                            title: "Message",
                            error: "",
                            validate: (String data) {},
                            gradiantColors: [],
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
