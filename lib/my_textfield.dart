import 'dart:ui';

import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final TextInputType keyboard;
  final String hintText;
  final bool obscureText;

   MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
     required this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboard,
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.grey,
      decoration: InputDecoration(
          enabledBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(15.0)
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(15.0)
          ),
          fillColor: Colors.grey.shade700,
          filled: true,
          hintText: hintText,
          labelText: hintText,
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[500])),
      selectionHeightStyle: BoxHeightStyle.tight,
    );
  }
}