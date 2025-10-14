import 'package:flutter/material.dart';

class TextInputOculto extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry padding;
  final double widthPercentage;
  final double heightPercentage;
  final double borderRadius;

  const TextInputOculto({
    Key? key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.onChanged,
    this.padding = const EdgeInsets.all(10.0),
    this.widthPercentage = 0.83,
    this.heightPercentage = 0.07,
    this.borderRadius = 10, 
  }) : super(key: key);

  @override
  _TextInputOcultoState createState() => _TextInputOcultoState();
}

class _TextInputOcultoState extends State<TextInputOculto> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * widget.widthPercentage,
      height: screenHeight * widget.heightPercentage,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
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
                  color: Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ],
      ),
    );
  }
}

