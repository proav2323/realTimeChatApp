import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/Group.dart';
import 'package:realtimechatapp/GroupDb.dart';
import 'package:realtimechatapp/GroupMember.dart';
import 'package:realtimechatapp/Input.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';

class GroupMembers extends StatefulWidget {
  const GroupMembers({super.key, required this.group, required this.id});
  final Group group;
  final String id;

  @override
  State<GroupMembers> createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  bool Addloading = false;
  TextEditingController email = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    email.dispose();
  }

  void delete(String id) {
    if (context.read<UserCubit>().state != null &&
        widget.group.createdBy == context.read<UserCubit>().state!.id) {
      GroupDb().removeMember(id, widget.group.id).then((value) {
        if (value) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Member Removed")));
        }
      });
    }
  }

  void addMember() {
    if (context.read<UserCubit>().state != null &&
        widget.group.createdBy == context.read<UserCubit>().state!.id &&
        Addloading == false &&
        email.text != "" &&
        email.text != null) {
      setState(() {
        Addloading = true;
      });
      FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email.text)
          .get()
          .then((value) {
        GroupDb()
            .addMember(value.docs[0].get("id"), widget.group.id)
            .then((value) {
          if (value) {
            email.clear();
            setState(() {
              Addloading = false;
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Member Added")));
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.group.name),
          automaticallyImplyLeading: false,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("groups")
              .doc(widget.id)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshow) {
            if (snapshow.hasError) {
              return const SizedBox();
            }

            if (snapshow.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshow.hasData || snapshow.data == null) {
              return const SizedBox();
            }
            List<dynamic> data = snapshow.data!.get("members");
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: EdgeInsets.all(8),
                  child: Text(
                    widget.group.name,
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                const SizedBox(height: 10),
                context.read<UserCubit>().state != null &&
                        widget.group.createdBy ==
                            context.read<UserCubit>().state!.id
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: Input(
                            controller: email,
                            title: "Members Email",
                            error: "",
                            validate: (String val) {},
                            gradiantColors: const [],
                          )),
                          const SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                              onPressed: addMember,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Addloading
                                      ? const SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CircularProgressIndicator(),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(Icons.add)
                                ],
                              ))
                        ],
                      )
                    : const SizedBox(
                        height: 10,
                      ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: data
                        .map((e) => GroupMember(id: e, delete: delete))
                        .toList()
                        .cast(),
                  ),
                )
              ],
            );
          },
        ));
  }
}
