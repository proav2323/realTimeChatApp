import 'package:flutter/material.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/User.dart';

class GroupMember extends StatefulWidget {
  GroupMember({super.key, required this.id, required this.delete});
  final String id;
  final Function(String id) delete;

  @override
  State<GroupMember> createState() => _GroupMemberState();
}

class _GroupMemberState extends State<GroupMember> {
  Auth autgh = Auth(callback: () {});
  User? user = null;
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      setState(() {
        loading = true;
      });
      autgh.getUserDb(widget.id).then((value) {
        setState(() {
          user = value;
          loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const SizedBox()
        : user == null
            ? const Text("Somethign Went Wrong")
            : GestureDetector(
                onTap: () {
                  widget.delete(widget.id);
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        user!.profileImg != null && user!.profileImg != ""
                            ? SizedBox(
                                width: 40,
                                height: 40,
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundImage:
                                      NetworkImage(user!.profileImg!),
                                ))
                            : const Icon(Icons.account_circle),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(user!.name)
                      ],
                    ),
                  ),
                ),
              );
  }
}
