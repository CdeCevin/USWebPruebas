import 'package:flutter/material.dart';

class InputFormulario extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsetsGeometry padding;
  final double widthPercentage;
  final double heightPercentage;
  final double borderRadius;
  final bool validateRut;
  final bool onlyNumbers;

  const InputFormulario({
    Key? key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.padding = const EdgeInsets.all(10.0),
    this.widthPercentage = 0.80,
    this.heightPercentage = 0.07,
    this.borderRadius = 12,
    this.validateRut = false,
    this.onlyNumbers = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (validateRut)
                Text(
                  '(eje: 12345678-9)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              if (onlyNumbers)
                Text(
                  '(eje: 912345678)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * heightPercentage,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: onlyNumbers ? TextInputType.phone : keyboardType,
            textInputAction: textInputAction,
            onFieldSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: padding,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

bool validarRut(String rut) {
  if (rut.isEmpty) return false;

  rut = rut.replaceAll('.', '').replaceAll('-', '');

  if (rut.length < 8 || rut.length > 9) return false;

  int rutBody = int.parse(rut.substring(0, rut.length - 1));
  String dv = rut.substring(rut.length - 1).toUpperCase();

  int m = 0, s = 1;
  for (; rutBody != 0; rutBody ~/= 10) {
    s = (s + rutBody % 10 * (9 - m++ % 6)) % 11;
  }
  String expectedDv = s != 0 ? (s - 1).toString() : 'K';

  return dv == expectedDv;
}
