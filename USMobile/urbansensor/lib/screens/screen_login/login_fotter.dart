import 'package:flutter/material.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurveClipper(),
      child: Container(
        color: const Color.fromARGB(255, 59, 105, 174),
        height: 130, // Altura del footer
        child: const Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Alineación central vertical
          children: [
            SizedBox(
                height: 40), // Espacio en blanco arriba para mover hacia abajo
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 20), // Padding horizontal
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white,
                      thickness: 2, // Grosor de las líneas
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20), // Padding horizontal para el texto
                    child: Text(
                      'Urban Sensor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17, // Tamaño del texto
                        fontFamily: 'Roboto', // Fuente del texto
                        fontWeight: FontWeight.w400, // Peso de la fuente
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white,
                      thickness: 2, // Grosor de las líneas
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0); // Mover al origen superior izquierdo
    path.quadraticBezierTo(size.width / 2, size.height / 1.5, size.width, 0);
    path.lineTo(size.width, size.height); // Extender hacia abajo
    path.lineTo(0, size.height); // Extender hacia la izquierda
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
