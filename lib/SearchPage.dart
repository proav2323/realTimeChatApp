import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key, required this.search});
  String search;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
