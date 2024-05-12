import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtimechatapp/GroupDb.dart';
import 'package:realtimechatapp/GroupMember.dart';
import 'package:realtimechatapp/Input.dart';
import 'package:realtimechatapp/User.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({super.key});

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  String nameError = "";
  String emailError = "";
  List<String> members = [];
  bool loading = false;
  bool Addloading = false;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    members.add(context.read<UserCubit>().state!.id);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    name.dispose();
    email.dispose();
  }

  void validateName(String val) {
    if (val == "" || val.isEmpty) {
      setState(() {
        nameError = "Name Is Required";
      });
    } else {
      setState(() {
        nameError = "";
      });
    }
  }

  void validateEmail(String val) {
    if (val == "" && (members.isEmpty || members.length <= 1)) {
      setState(() {
        emailError = "atleat one more Members Is Required";
      });
    } else {
      setState(() {
        emailError = "";
      });
    }
  }

  void addMember() {
    if (email.text.isNotEmpty && email.text != "" && Addloading == false) {
      String emaill = email.text;
      setState(() {
        Addloading = true;
      });
      db
          .collection("users")
          .where("email", isEqualTo: emaill)
          .limit(1)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          members.remove(value.docs[0].get("id"));
          members.add(value.docs[0].get("id"));
          email.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("no user found with this email")));
        }
        setState(() {
          Addloading = false;
        });
      });
    }
  }

  void create() {
    validateName(name.text);

    if (nameError == "" &&
        members.length > 1 &&
        context.read<UserCubit>().state != null) {
      setState(() {
        loading = true;
      });
      GroupDb()
          .createGroup(name.text, members, context.read<UserCubit>().state!.id)
          .then((value) {
        if (value == true) {
          setState(() {
            loading = false;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Group Created")));
        }
      });
    }
  }

  void delte(String id) {
    if (context.read<UserCubit>().state == null ||
        context.read<UserCubit>().state!.id == id) {
    } else {
      members.remove(id);
      setState(() {
        members = members;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Add A Group",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(
              height: 10,
            ),
            Input(
              controller: name,
              title: "Name",
              error: nameError,
              validate: validateName,
              gradiantColors: [],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: Input(
                  controller: email,
                  title: "Members Email",
                  error: emailError,
                  validate: validateEmail,
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
            ),
            const SizedBox(
              height: 10,
            ),
            members.isNotEmpty
                ? Expanded(
                    child: ListView(
                    children: members
                        .map((e) => GroupMember(
                              id: e,
                              delete: delte,
                            ))
                        .toList()
                        .cast(),
                  ))
                : Text("No Members Till Now"),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    loading
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text("Create"),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
