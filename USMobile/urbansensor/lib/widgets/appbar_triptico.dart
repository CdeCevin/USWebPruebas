import 'package:flutter/material.dart';

class MyAppBarTriptico extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double appBarHeight;
  final Color backgroundColor;
  final double titleFontSize; 
  final Widget? bottomWidget; // Parámetro para el botón que se mostrará abajo

  const MyAppBarTriptico({
    super.key,
    required this.title,
    required this.appBarHeight,
    this.backgroundColor = const Color.fromARGB(255, 59, 105, 174),
    this.titleFontSize = 32,
    this.bottomWidget, // Añadir widget en la parte inferior (botón)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: appBarHeight,
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centra los elementos
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0), // Ajuste de Padding para bajar el texto
            child: Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                color: Colors.white,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          if (bottomWidget != null) bottomWidget!, // Mostrar el botón si existe
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
