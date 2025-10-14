import 'package:flutter/material.dart';
import 'package:urbansensor/widgets/boton_generico.dart';
import 'package:urbansensor/widgets/appbar_generica.dart';
import 'package:urbansensor/widgets/textinput.dart';
import 'package:urbansensor/screens/screen_login/titulo.dart';
import 'package:urbansensor/screens/recuperar_password/circulo.dart';
import 'package:urbansensor/screens/screen_login/login_fotter.dart';
import 'package:urbansensor/screens/screen_login/screen_login.dart';

class cambioContra extends StatelessWidget {
  final TextEditingController textEditingController1 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.15;

    bool isValidEmail(String email) {
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return emailRegExp.hasMatch(email);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(
        title: 'Recuperación de Cuenta',
        appBarHeight: appBarHeight,
        titleFontSize: 28,
      ),
      body: Stack(
        children: [
          PnjWidget(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: TituloWidget(),
                ),
                SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ingrese Correo de Verificación',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextInput(
                        controller: textEditingController1,
                        hintText: '',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                BotonGenerico(
                  text: 'Confirmar',
                  onPressed: () {
                    String texto1 = textEditingController1.text;
                    if (isValidEmail(texto1)) {
                      // El correo electrónico es válido
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Color.fromARGB(255, 59, 105, 174),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 10.0,
                            title: Text(
                              'Correo de Verificación',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              'Se ha enviado un correo de verificación a $texto1',
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                  ); // Redirigir a la pantalla de inicio de sesión
                                },
                                child: Text(
                                  'Volver',
                                  style: TextStyle(color: Colors.white),
                                ), // Cambiar el color del botón
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // El correo electrónico no es válido, mostrar un mensaje de error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Por favor, ingrese un correo electrónico válido.',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center, // Centrar el texto
                          ),
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const LoginFooter(),
    );
  }
}
