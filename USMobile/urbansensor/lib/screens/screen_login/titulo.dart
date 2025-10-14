import 'package:flutter/material.dart';

class TituloWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Urban',
            style: TextStyle(
              color: Color(0xFF3B69AE), // Color para "Urban"
              fontSize: 48,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset:
                      Offset(2.0, 2.0), // Desplazamiento de la sombra en x, y
                  blurRadius: 3.0, // Radio de desenfoque de la sombra
                  color: Colors.black.withOpacity(0.3), // Color de la sombra
                ),
              ],
            ),
          ),
          TextSpan(
            text: ' Sensor',
            style: TextStyle(
              color: Color(0xFF2F1100), // Color para "Sensor"
              fontSize: 48,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset:
                      Offset(2.0, 2.0), // Desplazamiento de la sombra en x, y
                  blurRadius: 3.0, // Radio de desenfoque de la sombra
                  color: Colors.black.withOpacity(0.3), // Color de la sombra
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
