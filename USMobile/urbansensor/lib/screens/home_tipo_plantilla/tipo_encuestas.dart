import 'package:flutter/material.dart';
import 'package:urbansensor/screens/screen_formulario/main_formulario.dart';

class TipoEncuestas extends StatefulWidget {
  final String title;
  final List<Map<String, String>> children;
  final Function(String)? onTap;

  const TipoEncuestas({
    Key? key,
    required this.title,
    required this.children,
    this.onTap,
  }) : super(key: key);

  @override
  _TipoEncuestasState createState() => _TipoEncuestasState();
}

class _TipoEncuestasState extends State<TipoEncuestas> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF3A68AE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 17,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w800,
                      height: 0.06,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: isExpanded ? widget.children.length * 74.0 + 20.0 : 0,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 231, 231, 231),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            child: isExpanded
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 15),
                        for (final child in widget.children)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: _buildButton(child), // Cambia aquí
                          ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
          ),
        )
      ],
    );
  }

  Widget _buildButton(Map<String, String> child) {
    String id = child['Ver Encuesta'] ?? ''; // Obtener el ID de la encuesta

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Llamar a la función onTap y pasar el ID específico
            if (widget.onTap != null) {
              widget.onTap!(id); // Pasar el ID de la encuesta seleccionada
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromARGB(255, 46, 80, 129)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            shadowColor: MaterialStateProperty.all<Color>(const Color(0x3F000000)),
            elevation: MaterialStateProperty.all<double>(9),
            alignment: Alignment.centerLeft,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 17.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    child['Nombre'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToFormulario(String encuestaId) {
    // Verifica que el ID no esté vacío
    if (encuestaId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaginaFormulario(verEncuesta: encuestaId), // Pasar el ID aquí
        ),
      );
    } else {
      // Manejo de error: el ID está vacío
      print('Error: ID de encuesta vacío.');
    }
  }
}
