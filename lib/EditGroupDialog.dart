import 'package:flutter/material.dart';
import 'package:realtimechatapp/GroupDb.dart';
import 'package:realtimechatapp/Input.dart';

class EdutGroup extends StatefulWidget {
  EdutGroup(
      {super.key,
      required this.chatId,
      required this.prevName,
      required this.callBack});
  String chatId;
  String prevName;
  Function() callBack;

  @override
  State<EdutGroup> createState() => _EdutGroupState();
}

class _EdutGroupState extends State<EdutGroup> {
  TextEditingController controller = TextEditingController();
  String textError = "";
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.text = widget.prevName;
  }

  void valudate(String value) {
    if (value.isEmpty || value == "") {
      setState(() {
        textError = "new message can't be empty";
      });
    } else {
      setState(() {
        textError = "";
      });
    }
  }

  Future<void> submit() async {
    valudate(controller.text);
    if (textError == "") {
      setState(() {
        loading = true;
      });
      bool dataa = await GroupDb().editGroup(widget.chatId, controller.text);

      if (dataa == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("group updated")));

        Navigator.pop(context);
        widget.callBack();
      }

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Edit Group Name",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 20,
          ),
          Input(
            controller: controller,
            title: "New Name",
            error: textError,
            validate: valudate,
            gradiantColors: const [],
          ),
          const SizedBox(
            height: 20,
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
                  const Text("Save")
                ],
              ))
        ],
      ),
    );
  }
}
