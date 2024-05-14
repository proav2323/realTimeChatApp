import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtimechatapp/Group.dart';
import 'package:realtimechatapp/GroupDb.dart';
import 'package:realtimechatapp/GroupMember.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';

class GroupMembers extends StatefulWidget {
  const GroupMembers({super.key, required this.group});
  final Group group;

  @override
  State<GroupMembers> createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        automaticallyImplyLeading: false,
      ),
      body: Column(
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
          ListView(
            children: widget.group.members
                .map((e) => GroupMember(id: e, delete: delete))
                .toList()
                .cast(),
          )
        ],
      ),
    );
  }
}
