import 'package:flutter/material.dart';

class BotonPlantillaEnviadas extends StatelessWidget {
  final String texto1;
  final String texto2;
  final bool encuestasSelected;
  final VoidCallback onPressed1;
  final VoidCallback onPressed2;

  const BotonPlantillaEnviadas({
    Key? key,
    required this.texto1,
    required this.texto2,
    required this.encuestasSelected,
    required this.onPressed1,
    required this.onPressed2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth <= 600;

    final double buttonWidth =
        isSmallScreen ? screenWidth * 0.7 / 2 : screenWidth * 0.3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPressed1,
          child: Container(
            width: buttonWidth,
            decoration: BoxDecoration(
              color: encuestasSelected
                  ? Color(0xFF284B81)
                  : const Color.fromARGB(255, 217, 217, 217),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
              ),
            ),
            margin: EdgeInsets.symmetric(vertical: 1.5, horizontal: 0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  texto1,
                  style: TextStyle(
                    fontFamily: 'Khula ExtraBold',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: encuestasSelected
                        ? Colors.white
                        : Color.fromRGBO(74, 72, 115, 0.8),
                  ),
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: onPressed2,
          child: Container(
            width: buttonWidth,
            decoration: BoxDecoration(
              color: encuestasSelected
                  ? const Color.fromARGB(255, 217, 217, 217)
                  : Color(0xFF284B81),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            margin: EdgeInsets.symmetric(vertical: 1.5, horizontal: 0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  texto2,
                  style: TextStyle(
                    fontFamily: 'Khula ExtraBold',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: encuestasSelected
                        ? Color.fromRGBO(74, 72, 115, 0.8)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
