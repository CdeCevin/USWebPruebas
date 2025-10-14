import 'package:flutter/material.dart';
import 'package:urbansensor/widgets/appbar_generica.dart';
import 'package:urbansensor/widgets/barranavegacion.dart'; // Asegúrate de importar tu widget BarraNavegacion

class PerfilUsuarioScreen extends StatelessWidget {
  const PerfilUsuarioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'PERFIL DE USUARIO',
        appBarHeight: 110,
      ),
      body: Center(
        child: Text('Esta es la pantalla de perfil de usuario'),
      ),
      bottomNavigationBar: BarraNavegacion(currentIndex: 0),
    );
  }
}

class InfoContainer extends StatelessWidget {
  final String label;

  const InfoContainer({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class EditPagePerson extends StatefulWidget {
  const EditPagePerson({super.key});

  @override
  State<EditPagePerson> createState() => _EditPagePersonState();
}

class _EditPagePersonState extends State<EditPagePerson> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BarraNavegacion(currentIndex: 0),
      appBar: MyAppBar(
        title: 'PERFIL DE USUARIO',
        appBarHeight: 110,
      ),
      key: scaffoldKey,
      backgroundColor: const Color(0xFFE5E5FF),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFCED9E8),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text(
                      'Mis Datos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Datos Personales',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Integración del nuevo widget InfoContainer
                    const InfoContainer(
                      label: 'Nombre',
                    ),
                    const InfoContainer(
                      label: 'Apellido',
                    ),
                    const InfoContainer(
                      label: 'Rut',
                    ),
                    const InfoContainer(
                      label: 'Cargo',
                    ),
                    const InfoContainer(
                      label: 'Telefono',
                    ),
                    const InfoContainer(
                      label: 'Correo electrónico',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 58, 108, 173),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 45),
                              elevation: 5,
                              shadowColor: Colors.black.withOpacity(0.50)),
                          child: const Text(
                            'Volver',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 58, 108, 173),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 50),
                              elevation: 5,
                              shadowColor: Colors.black.withOpacity(0.50)),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
