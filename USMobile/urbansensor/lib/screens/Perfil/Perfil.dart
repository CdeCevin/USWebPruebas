import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:urbansensor/endpoints/perfil.dart';
import 'package:urbansensor/endpoints/logout.dart';
import 'package:urbansensor/screens/recuperar_password/recuperar_password.dart';
import 'package:urbansensor/screens/routes/app_routes.dart';
import 'package:urbansensor/screens/Perfil/editar_perfil.dart';

class Perfil extends StatefulWidget {
  static String id = 'perfil';
  const Perfil({Key? key}) : super(key: key);

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = fetchProfile();
  }

  void _actualizarPerfil() async {
    setState(() {
      _profileFuture = fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final profileData = snapshot.data!['Perfil'];
            final nombre = profileData['Nombre'];
            final apellido = profileData['Apellido'];
            final correo = profileData['Correo'];
            final cargo = profileData['Cargo'];

            return Column(
              children: [
                SizedBox(height: 30),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 20),
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  "$nombre $apellido",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20),
                                ),
                                Text(
                                  correo,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  cargo,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 4),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        topLeft: Radius.circular(30.0),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          topLeft: Radius.circular(30.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 58, 58, 58)
                                .withOpacity(0.5),
                          ),
                        ],
                      ),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          SizedBox(height: 20),
                          ListTile(
                            leading: const Icon(Icons.settings, size: 30),
                            title: const Text(
                              'Cambiar Contraseña',
                              style: TextStyle(fontSize: 20),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => recuperarPassword()),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          ListTile(
                            leading: const Icon(Icons.receipt, size: 30),
                            title: const Text(
                              'Editar Perfil',
                              style: TextStyle(fontSize: 20),
                            ),
                            onTap: () async {
                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditarInformacion()),
                              );

                              if (result != null && result) {
                                _actualizarPerfil();
                              }
                            },
                          ),
                          SizedBox(height: 20),
                          ListTile(
                            leading:
                                const Icon(Icons.logout_outlined, size: 30),
                            title: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(fontSize: 20),
                            ),
                            onTap: () async {
                              bool? result = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    content: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              "Cerrar Sesión",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "¿Está seguro de que desea cerrar sesión?",
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 20),
                                            ButtonBar(
                                              alignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Color.fromARGB(
                                                                    255,
                                                                    59,
                                                                    105,
                                                                    174)),
                                                    shape: MaterialStateProperty
                                                        .all<OutlinedBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Confirmar",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.red),
                                                    shape: MaterialStateProperty
                                                        .all<OutlinedBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Cancelar",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                              if (result != null && result) {
                                bool success = await logout();
                                if (success) {
                                  Navigator.pushReplacementNamed(
                                      context, AppRoutes.initialRoute);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error al cerrar sesión')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
