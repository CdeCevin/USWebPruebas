import 'package:flutter/material.dart';
import 'package:urbansensor/screens/confirmar_cambio/cambio_contra.dart';
import 'package:urbansensor/widgets/boton_generico.dart';
import 'package:urbansensor/widgets/textinput.dart';
import 'package:urbansensor/screens/screen_login/login_fotter.dart';
import 'package:urbansensor/screens/screen_login/logo_imagen.dart';
import 'package:urbansensor/endpoints/auth.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double logoSize = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: logoSize, child: logoWidget()),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        TextInput(
                          hintText: 'Usuario',
                          controller: usernameController,
                          icon: Icons.email,
                        ),
                        SizedBox(height: 16),
                        TextInput(
                          hintText: 'Contraseña',
                          controller: passwordController,
                          obscureText: true,
                          icon: Icons.lock,
                          showPassword: true,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => cambioContra(),
                              ),
                            );
                          },
                          child: Text(
                            '',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        BotonGenerico(
                          text: 'Iniciar Sesión',
                          onPressed: () async {
                            String username = usernameController.text.trim();
                            String password = passwordController.text.trim();

                            if (username.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Por favor, completa todos los campos.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              return;
                            }
                            final AuthService authService = AuthService();
                            final bool success = await authService.login(
                              username,
                              password,
                            );
                            print('Success: $success');

                            if (success) {
                              Navigator.restorablePushReplacementNamed(
                                context,
                                'triptico',
                              );
                            } else {
                              // Mostrar mensaje de error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Por favor, verifique sus credenciales.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Image.asset(
                            'assets/logo2.png',
                            height: logoSize * 0.35,
                            width: logoSize * 0.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: LoginFooter(),
    );
  }
}
