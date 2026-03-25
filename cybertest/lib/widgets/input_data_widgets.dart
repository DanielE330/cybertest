import 'package:flutter/material.dart';

class InputData extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String hint;
  final String? Function(String?)? validator;

  const InputData({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.hint = '',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          decoration: InputDecoration(labelText: label),
        ),
        Text(
          hint,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}