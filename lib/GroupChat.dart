import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtimechatapp/ChatMessage.dart';
import 'package:realtimechatapp/Group.dart';
import 'package:realtimechatapp/GroupDb.dart';
import 'package:realtimechatapp/GroupMessageUi.dart';
import 'package:realtimechatapp/Input.dart';
import 'package:realtimechatapp/PopumMenu.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';

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

  void sendMessage() {
    if (context.read<UserCubit>().state != null &&
        search.text != "" &&
        chat != null) {
      List<dynamic> members = chat!.members
          .where((data) => data != context.read<UserCubit>().state!.id)
          .toList();
      GroupDb()
          .sendMessage(search.text, context.read<UserCubit>().state!.id,
              chat!.id, members)
          .then((value) {
        if (value == true) {
          search.clear();
          if (_scrollController.hasClients) {
            _scrollToBottom();
          }
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("message send")));
        }
      });
    }
  }

  void selected(String data) {}

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
                IconButton(onPressed: () {}, icon: const Icon(Icons.group)),
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
                                            key:
                                                Key("${Random().nextDouble()}"),
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
