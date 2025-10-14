import 'package:flutter/material.dart';

class PnjWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100.0,
      right: 0.0,
      child: Image.asset(
        'assets/circulo.png',
        width: 195.0,
        height: 190.0,
        fit: BoxFit.cover,
      ),
    );
  }
}
