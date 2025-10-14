import 'package:flutter/material.dart';
import 'package:urbansensor/widgets/boton_generico.dart';
import 'package:urbansensor/widgets/appbar_generica.dart';
import 'package:urbansensor/widgets/textinput_oculto.dart';
import 'package:urbansensor/screens/screen_login/titulo.dart';
import 'package:urbansensor/screens/screen_login/screen_login.dart';
import 'package:urbansensor/widgets/barranavegacion.dart';
import 'package:urbansensor/endpoints/cambiar_contraseña.dart';

class recuperarPassword extends StatefulWidget {
  @override
  _RecuperarPasswordState createState() => _RecuperarPasswordState();
}

class _RecuperarPasswordState extends State<recuperarPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _hasMinLength = false;
  bool _passwordsMatch = false;
  bool _noSpaces = false;
  bool _hasLetter = false;
  bool _hasNumber = false;

  void _verRequerimientos() {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 6;
      _passwordsMatch = password == confirmPassword;
      _noSpaces = !password.contains(' ');
      _hasLetter = password.contains(RegExp(r'[A-Za-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  Future<void> _manejarContra(BuildContext context) async {
    _verRequerimientos();

    if (_hasMinLength &&
        _passwordsMatch &&
        _noSpaces &&
        _hasLetter &&
        _hasNumber) {
      setState(() {
        _isLoading = true;
      });

      String password = _passwordController.text;
      String confirmPassword = _confirmPasswordController.text;

      final response = await changePassword(context, password, confirmPassword);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['Msj'] ?? 'Error desconocido')),
      );

      if (response['Msj'] == 'Contraseña editada con éxito') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Por favor, asegúrese de que todas las condiciones de la contraseña estén satisfechas.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_verRequerimientos);
    _confirmPasswordController.addListener(_verRequerimientos);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.15;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: MyAppBar(
        title: 'Cambiar contraseña',
        appBarHeight: appBarHeight,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -30.0,
            right: 0.0,
            child: Image.asset(
              'assets/circulo.png',
              width: 195.0,
              height: 190.0,
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30.0),
                  TituloWidget(),
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contraseña nueva',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextInputOculto(
                          hintText: '*********',
                          controller: _passwordController,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirmar contraseña',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextInputOculto(
                          hintText: '*********',
                          controller: _confirmPasswordController,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requisitos de la contraseña:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        _requerimientosContra(
                            'Al menos 6 caracteres', _hasMinLength),
                        _requerimientosContra(
                            'Las contraseñas deben coincidir', _passwordsMatch),
                        _requerimientosContra(
                            'No contenga espacios', _noSpaces),
                        _requerimientosContra(
                            'Tiene al menos una letra', _hasLetter),
                        _requerimientosContra(
                            'Tiene al menos un número', _hasNumber),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : BotonGenerico(
                          text: 'Guardar Cambio',
                          onPressed: () {
                            _manejarContra(context);
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BarraNavegacion(currentIndex: 0),
    );
  }

  Widget _requerimientosContra(String requirement, bool satisfied) {
    return Row(
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.cancel,
          color: satisfied ? Colors.green : Colors.red,
        ),
        SizedBox(width: 8),
        Text(requirement),
      ],
    );
  }
}
