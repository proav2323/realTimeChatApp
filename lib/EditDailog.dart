import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtimechatapp/ChatDb.dart';
import 'package:realtimechatapp/Input.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';

class EditDailog extends StatefulWidget {
  EditDailog({
    super.key,
    required this.prevText,
    required this.chatId,
    required this.messageId,
    required this.chatLastMessage,
  });
  String prevText;
  String chatId;
  String messageId;
  String chatLastMessage;

  @override
  State<EditDailog> createState() => _EditDailogState();
}

class _EditDailogState extends State<EditDailog> {
  TextEditingController controller = TextEditingController();
  String textError = "";
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.text = widget.prevText;
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
      if (widget.chatLastMessage == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("somehtign went wrong")));
      } else {
        setState(() {
          loading = true;
        });
        bool dataa = await ChatDb().updateMessage(
            widget.chatId,
            widget.messageId,
            context.read<UserCubit>().state!.id,
            controller.text,
            widget.chatLastMessage,
            widget.prevText);

        if (dataa == true) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("message upadted")));

          Navigator.pop(context);
        }

        setState(() {
          loading = false;
        });
      }
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
            "Edit Your Messages",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 20,
          ),
          Input(
            controller: controller,
            title: "New Message",
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
