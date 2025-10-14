import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final bool showPassword; // Nuevo parámetro
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsetsGeometry padding;
  final double widthPercentage;
  final double heightPercentage;
  final double borderRadius;
  final IconData? icon;

  const TextInput({
    Key? key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.showPassword = false, // Inicializado como false
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.padding = const EdgeInsets.all(10.0),
    this.widthPercentage = 0.83,
    this.heightPercentage = 0.07,
    this.borderRadius = 20,
    this.icon,
  }) : super(key: key);

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * widget.widthPercentage,
      height: screenHeight * widget.heightPercentage,
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText && !_showPassword,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,
          contentPadding: widget.padding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 3.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 0, 0, 0),
              width: 1.3,
            ),
          ),
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
