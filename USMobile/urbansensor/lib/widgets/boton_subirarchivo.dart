import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BotonSubirArchivo extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double widthFactor;
  final double heightFactor;
  final double borderRadius;
  final double elevation;
  final double fontSize;
  final bool isBold;
  final Icon? icon;
  final Color iconColor;
  final double iconSpacing;

  BotonSubirArchivo({
    Key? key,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF3B69AE),
    this.textColor = Colors.white,
    this.widthFactor = 0.54,
    this.heightFactor = 0.055,
    this.borderRadius = 8,
    this.elevation = 6.0,
    this.fontSize = 22.0,
    this.isBold = true,
    this.icon = const Icon(Icons.attach_file),
    this.iconColor = Colors.white,
    this.iconSpacing = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * widthFactor,
        height: MediaQuery.of(context).size.height * heightFactor,
        child: ElevatedButton(
          onPressed: () async {
            final XFile? image =
                await _picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              // Haz algo con la imagen seleccionada
              print('Imagen seleccionada: ${image.path}');
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            elevation: MaterialStateProperty.all<double>(elevation),
            shadowColor: MaterialStateProperty.all<Color>(
              Colors.black.withOpacity(0.9),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                SizedBox(width: iconSpacing),
                Icon(
                  icon!.icon,
                  color: iconColor,
                ),
              ],
              Text(
                'Subir Imagen',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'Mulish',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: BotonSubirArchivo(
          onPressed: () {},
        ),
      ),
    ),
  ));
}
