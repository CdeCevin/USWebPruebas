import 'package:flutter/material.dart';
import 'package:urbansensor/widgets/appbar_generica.dart';
import 'package:urbansensor/widgets/barranavegacion.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.15;

    return Scaffold(
      appBar: MyAppBar(
        title: 'Perfil',
        appBarHeight: appBarHeight,
      ),
      body: Center(
        child: Text(
          'ocurrio un error',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BarraNavegacion(currentIndex: 0),
    );
  }
}
