import 'package:flutter/material.dart';

class TextoConDivisor extends StatelessWidget {
  final String title;
  final String text;

  TextoConDivisor({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FractionallySizedBox(
          widthFactor: 0.9,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        SizedBox(height: 2.0),
        FractionallySizedBox(
          widthFactor: 0.9,
          child: Text(text),
        ),
        FractionallySizedBox(
          widthFactor: 0.9,
          child: Divider(),
        ),
      ],
    );
  }
}
