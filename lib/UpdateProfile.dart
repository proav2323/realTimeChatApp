import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/ChatDb.dart';
import 'package:realtimechatapp/Input.dart';
import 'package:realtimechatapp/User.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';
import "package:image_picker/image_picker.dart";

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController name = TextEditingController();
  String nameError = "";
  String img = "";
  File? image;
  bool pickedImage = false;
  bool loading = false;

  validate(String value) {
    if (value == "") {
      setState(() {
        nameError = "name is required";
      });
    } else {
      setState(() {
        nameError = "";
      });
    }
  }

  Future<void> getLostData() async {
    final ImagePicker picker = ImagePicker();
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    final List<XFile>? files = response.files;
    if (files != null) {
    } else {}
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
        pickedImage = true;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  submit() async {
    validate(name.text);
    if (nameError == "") {
      setState(() {
        loading = true;
      });
      bool data = await ChatDb()
          .updateProfile(name.text, image, context.read<UserCubit>().state!.id);

      if (data == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("profile updated")));

        User dataa = await Auth(callback: () {})
            .getUserDb(context.read<UserCubit>().state!.id);
        context.read<UserCubit>().login(dataa);
        Navigator.pop(context);
        setState(() {
          loading = false;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("something went wrong")));
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (context.read<UserCubit>().state == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("somehtign wnet wrong")));
    } else {
      name.text = context.read<UserCubit>().state!.name;
      if (mounted == true) {
        setState(() {
          img = context.read<UserCubit>().state!.profileImg != "" &&
                  context.read<UserCubit>().state!.profileImg != null
              ? context.read<UserCubit>().state!.profileImg!
              : "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, User?>(
      builder: (context, state) => Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Update Profile",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            Input(
              controller: name,
              title: "Name",
              error: nameError,
              validate: validate,
              gradiantColors: const [],
            ),
            const SizedBox(
              height: 5,
            ),
            pickedImage == false
                ? img == ""
                    ? GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 40,
                          decoration: const BoxDecoration(
                              border: Border.symmetric(
                                  vertical: BorderSide(),
                                  horizontal: BorderSide())),
                          child: const Center(
                            child: Text("Pick Profile Image"),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          setState(() {
                            pickedImage = false;
                            image = null;
                          });
                          pickImage();
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.width - 100,
                          width: MediaQuery.of(context).size.width - 100,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(img),
                          ),
                        ),
                      )
                : image != null
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            pickedImage = false;
                            image = null;
                          });
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.width - 100,
                          width: MediaQuery.of(context).size.width - 100,
                          child: CircleAvatar(
                            backgroundImage: FileImage(image!),
                          ),
                        ),
                      )
                    : const SizedBox(),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
                onPressed: submit,
                child: Row(
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
                    const Text("Update")
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
