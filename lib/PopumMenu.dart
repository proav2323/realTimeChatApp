import "package:flutter/material.dart";

class CustomPopumMenu extends StatelessWidget {
  CustomPopumMenu(
      {super.key, this.icon = null, required this.fun, required this.data});
  Widget? icon;
  List<PopupMenuEntry<String>> data;
  Function(String) fun;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (BuildContext con) {
        return data;
      },
      icon: icon,
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: fun,
    );
  }
}
