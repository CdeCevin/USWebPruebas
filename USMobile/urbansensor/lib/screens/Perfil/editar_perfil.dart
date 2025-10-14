import 'package:flutter/material.dart';
import 'package:urbansensor/endpoints/perfil.dart';
import 'package:urbansensor/widgets/appbar_generica.dart';
import 'package:urbansensor/widgets/barranavegacion.dart';
import 'package:urbansensor/widgets/boton_generico.dart';

class input extends StatelessWidget {
  final String label;
  final String? initialValue;
  final TextEditingController controller;

  const input({
    Key? key,
    required this.label,
    this.initialValue,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        controller: controller,
      ),
    );
  }
}

class EditarInformacion extends StatefulWidget {
  const EditarInformacion({Key? key}) : super(key: key);

  @override
  State<EditarInformacion> createState() => _EditarInformacionState();
}

class _EditarInformacionState extends State<EditarInformacion> {
  late Future<Map<String, dynamic>> _profileFuture;
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileFuture = fetchProfile();
    _profileFuture.then((profileData) {
      _nombreController.text = profileData['Perfil']['Nombre'] ?? '';
      _apellidoController.text = profileData['Perfil']['Apellido'] ?? '';
      _correoController.text = profileData['Perfil']['Correo'] ?? '';
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    final nombre = _nombreController.text;
    final apellido = _apellidoController.text;
    final correo = _correoController.text;

    final response = await editProfile(
      nombre: nombre.isNotEmpty ? nombre : null,
      apellido: apellido.isNotEmpty ? apellido : null,
      correo: correo.isNotEmpty ? correo : null,
    );

    if (response.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Perfil actualizado exitosamente'),
      ));

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al actualizar el perfil'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: MyAppBar(
        title: 'Perfil',
        appBarHeight: appBarHeight,
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text(
                          'Cargando...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 50),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  'Editar Datos Personales',
                                  style: TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            input(
                              label: 'Nombre',
                              initialValue: _nombreController.text,
                              controller: _nombreController,
                            ),
                            SizedBox(height: 25),
                            input(
                              label: 'Apellido',
                              initialValue: _apellidoController.text,
                              controller: _apellidoController,
                            ),
                            SizedBox(height: 25),
                            input(
                              label: 'Correo electrónico',
                              initialValue: _correoController.text,
                              controller: _correoController,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      BotonGenerico(
                        text: 'Guardar Cambios',
                        onPressed: _guardarCambios,
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BarraNavegacion(currentIndex: 2),
    );
  }
}
