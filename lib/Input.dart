import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.controller,
    required this.title,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    required this.error,
    this.keyboard = TextInputType.text,
    this.autocorrect = true,
    this.obscureText = false,
    this.enableSuggestion = true,
    required this.validate,
    required this.gradiantColors,
  });
  final TextEditingController controller;
  final String title;
  final EdgeInsets padding;
  final String error;
  final TextInputType keyboard;
  final bool obscureText;
  final bool enableSuggestion;
  final bool autocorrect;
  final Function(String) validate;
  final List<Color> gradiantColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: title,
            errorText: error != "" ? error : null,
          ),
          keyboardType: keyboard,
          obscureText: obscureText,
          enableSuggestions: enableSuggestion,
          autocorrect: autocorrect,
          onChanged: validate,
        ));
  }
}
