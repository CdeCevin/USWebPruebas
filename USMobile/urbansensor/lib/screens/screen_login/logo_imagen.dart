import 'package:flutter/material.dart';

class logoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double widthPercentage = 1.02; // Porcentaje del ancho de la pantalla
    final double heightPercentage = 0.5; // Porcentaje del alto de la pantalla

    return Stack(
      children: [
        // Posicionamiento de la imagen
        Positioned(
          top: 130, // Ajusta según el porcentaje
          left: 110, // Ajusta según el porcentaje
          child: Image.asset(
            'assets/Logopelarco.png',
            width: 180,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        // Posicionamiento del título
        Positioned(
          top: screenSize.height * 0.08, // Ajusta según el porcentaje
          left: screenSize.width * 0.15, // Ajusta según el porcentaje
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Urban',
                  style: TextStyle(
                    color: Color(0xFF3B69AE), // Color para "Urban"
                    fontSize:
                        screenSize.width * 0.12, // Ajusta según el porcentaje
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(
                          screenSize.width * 0.007,
                          screenSize.width * 0.007,
                        ),
                        blurRadius: screenSize.width * 0.01,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                TextSpan(
                  text: ' Sensor',
                  style: TextStyle(
                    color: Color(0xFF2F1100), // Color para "Sensor"
                    fontSize:
                        screenSize.width * 0.12, // Ajusta según el porcentaje
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(
                          screenSize.width * 0.007,
                          screenSize.width * 0.007,
                        ),
                        blurRadius: screenSize.width * 0.01,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
