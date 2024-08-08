import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final TextStyle textStyle;
  final VoidCallback onPressed;

  const CustomChip({
    Key? key,
    required this.label,
    this.backgroundColor = Colors.blue,
    this.textStyle = const TextStyle(color: Colors.white),
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Chip(
        label: Text(
          label,
          style: textStyle,
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
