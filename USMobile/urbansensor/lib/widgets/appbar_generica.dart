import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double appBarHeight;
  final Color backgroundColor;
  final double
      titleFontSize; // Nuevo parámetro para el tamaño de la fuente del título

  const MyAppBar({
    Key? key,
    required this.title,
    required this.appBarHeight,
    this.backgroundColor = const Color.fromARGB(255, 59, 105, 174),
    this.titleFontSize =
        32, // Valor predeterminado para el tamaño de la fuente del título
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: appBarHeight,
      color: backgroundColor,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize:
                    titleFontSize, // Usar el tamaño de fuente proporcionado
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
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
