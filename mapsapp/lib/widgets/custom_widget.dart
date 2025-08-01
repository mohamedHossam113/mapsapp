import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomWidget extends StatefulWidget {
  const CustomWidget({
    super.key,
    this.hintText,
    this.onChanged,
    this.controller,
    this.obscureText = false,
  });

  final String? hintText;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final bool obscureText;

  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscureText;
  }

  void toggleObscureText() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: isObscured,
      validator: (data) {
        if (data == null || data.isEmpty) {
          return 'field is required';
        }
        return null;
      },
      onChanged: widget.onChanged,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: toggleObscureText,
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
              )
            : null,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
