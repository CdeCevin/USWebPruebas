import 'package:flutter/material.dart';

class TarjetaIncidencia extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String id;
  final VoidCallback onTap;

  TarjetaIncidencia({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.id,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double cardHeight = MediaQuery.of(context).size.height * 0.09;

    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF3B69AE),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Container(
            height: cardHeight,
            width: MediaQuery.of(context).size.width * 0.95,
            child: Row(
              children: [
                Container(
                  height: cardHeight,
                  width: cardHeight * 0.8,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 38),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 24.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomIcons {
  static const IconData abierto = IconData(0xef48, fontFamily: 'MaterialIcons');
  static const IconData enproceso = IconData(
    0xe3bb,
    fontFamily: 'MaterialIcons',
  );
  static const IconData derivada = IconData(
    0xf0455,
    fontFamily: 'MaterialIcons',
  );
  static const IconData cerrada = IconData(
    0xf06a4,
    fontFamily: 'MaterialIcons',
  );
  static const IconData finalizada = IconData(
    0xef48,
    fontFamily: 'MaterialIcons',
  );
  static const IconData iniciada = IconData(
    0xe5ca,
    fontFamily: 'MaterialIcons',
  );
}
