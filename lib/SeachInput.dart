import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({
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
    this.submit = null,
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
  final Function(String)? submit;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).cardColor,
                style: BorderStyle.solid,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            labelText: title,
            errorText: error != "" ? error : null,
          ),
          keyboardType: keyboard,
          obscureText: obscureText,
          enableSuggestions: enableSuggestion,
          autocorrect: autocorrect,
          onChanged: validate,
          onFieldSubmitted: submit,
        ));
  }
}
