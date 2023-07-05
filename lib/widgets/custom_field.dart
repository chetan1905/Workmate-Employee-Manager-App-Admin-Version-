// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class CustomField extends StatefulWidget {
  final String? labelText;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  const CustomField(
      {super.key,
      required this.controller,
      required this.labelText,
      required this.suffixIcon,
      required this.obscureText});

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        cursorColor: Colors.cyan,
        cursorHeight: 24,
        decoration: InputDecoration(
            suffixIcon: widget.suffixIcon,
            suffixIconColor: Colors.cyan,
            labelText: widget.labelText,
            labelStyle: TextStyle(color: Colors.cyan, fontSize: 24),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan, width: 2)),
            filled: true,
            fillColor: Colors.white),
      ),
    );
  }
}
