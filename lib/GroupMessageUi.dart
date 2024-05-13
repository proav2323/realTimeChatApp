import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/ChatDb.dart';
import 'package:realtimechatapp/EditDailog.dart';
import 'package:realtimechatapp/Group.dart';
import 'package:realtimechatapp/GroupDb.dart';
import 'package:realtimechatapp/GroupMessages.dart';
import 'package:realtimechatapp/PopumMenu.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';
import 'package:realtimechatapp/User.dart';

class GroupMessageUi extends StatefulWidget {
  GroupMessageUi({
    super.key,
    required this.message,
    required this.chatId,
    required this.prevMessage,
    required this.group,
  });
  dynamic message;
  String chatId;
  String prevMessage;
  Group group;

  @override
  State<GroupMessageUi> createState() => _GroupMessageUiState();
}

class _GroupMessageUiState extends State<GroupMessageUi> {
  late GroupMessages message;
  bool loading = true;
  User? senderUser = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted == true) {
      setState(() {
        message = GroupDb().getMessage(widget.message);
      });
      Auth(callback: () {})
          .getUserDb(widget.message.get("senderId"))
          .then((value) {
        setState(() {
          senderUser = value;
          loading = false;
        });
      });
    }
  }

  void selected(String value) {
    if (value == "edit") {
      showDialog(
          context: context,
          builder: (BuildContext context) => Dialog(
                child: EditDailog(
                  prevText: message.message,
                  chatId: widget.chatId,
                  messageId: message.id,
                  chatLastMessage: widget.prevMessage,
                  data: true,
                ),
              ));
    } else if (value == "delete") {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Delete Message'),
          content: Text("the message ${message.message} will be deleted"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                bool data = await GroupDb().deleteMessage(
                    widget.chatId,
                    message.id,
                    context.read<UserCubit>().state!.id,
                    widget.prevMessage,
                    message.message);
                Navigator.pop(context, 'ok');

                if (data == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("message deleted")));
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? const CircularProgressIndicator()
        : senderUser != null
            ? Align(
                alignment:
                    message.senderId == context.read<UserCubit>().state!.id
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                child: message.senderId == context.read<UserCubit>().state!.id
                    ? CustomPopumMenu(
                        icon: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    senderUser!.profileImg != "" &&
                                            senderUser!.profileImg != null
                                        ? SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  senderUser!.profileImg!),
                                            ),
                                          )
                                        : const SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: Icon(Icons.account_circle),
                                          ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        child: const Text(
                                          "You",
                                          style: const TextStyle(fontSize: 12),
                                        )),
                                  ],
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Card(
                              color: message.senderId ==
                                      context.read<UserCubit>().state!.id
                                  ? Colors.green
                                  : Theme.of(context).cardTheme.color,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  message.deleted == true
                                      ? "Message Was Deleted"
                                      : message.edited
                                          ? "${message.message} (edited)"
                                          : message.message,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    child: Text(
                                      DateFormat("MM-dd HH:mm")
                                          .format(message.created_at.toDate()),
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                message.senderId ==
                                        context.read<UserCubit>().state!.id
                                    ? message.seen.length ==
                                            message.recieverId.length
                                        ? Container(
                                            margin: const EdgeInsets.only(
                                                right: 5, left: 5),
                                            child: const Icon(
                                              Icons.remove_red_eye_sharp,
                                              size: 12,
                                            ),
                                          )
                                        : Container(
                                            margin: const EdgeInsets.only(
                                                right: 5, left: 5),
                                            child: const Icon(
                                              Icons.check,
                                              size: 12,
                                            ),
                                          )
                                    : const SizedBox()
                              ],
                            )
                          ],
                        ),
                        fun: selected,
                        data: const [
                          PopupMenuItem(
                            value: "edit",
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.edit),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Edit"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "delete",
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.delete),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Delete"),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  senderUser!.profileImg != "" &&
                                          senderUser!.profileImg != null
                                      ? SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                senderUser!.profileImg!),
                                          ),
                                        )
                                      : const SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: Icon(Icons.account_circle),
                                        ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        senderUser!.name,
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                ],
                              )),
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            color: message.senderId ==
                                    context.read<UserCubit>().state!.id
                                ? Colors.green
                                : Theme.of(context).cardTheme.color,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                message.deleted == true
                                    ? "Message Was Deleted"
                                    : message.edited
                                        ? "${message.message} (edited)"
                                        : message.message,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text(
                                    DateFormat("MM-dd HH:mm")
                                        .format(message.created_at.toDate()),
                                    style: TextStyle(fontSize: 12),
                                  )),
                              message.senderId ==
                                      context.read<UserCubit>().state!.id
                                  ? message.seen.length ==
                                          widget.group.members.length
                                      ? Container(
                                          child: Icon(
                                            Icons.remove_red_eye_sharp,
                                            size: 12,
                                          ),
                                          margin: EdgeInsets.only(
                                              right: 5, left: 5),
                                        )
                                      : Container(
                                          child: Icon(
                                            Icons.check,
                                            size: 12,
                                          ),
                                          margin: EdgeInsets.only(
                                              right: 5, left: 5),
                                        )
                                  : SizedBox()
                            ],
                          )
                        ],
                      ),
              )
            : const SizedBox();
  }
}
