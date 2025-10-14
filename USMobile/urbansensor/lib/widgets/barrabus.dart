import 'package:flutter/material.dart';

class BarraBusqueda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 247, 242, 242),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: Offset(2, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 247, 242, 242),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.search,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 40,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(
                hintText: 'Buscar...',
                hintStyle: TextStyle(color: Color.fromARGB(131, 0, 0, 0)),
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarraBusqueda2 extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const BarraBusqueda2({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: Offset(2, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              color: Color.fromARGB(224, 255, 255, 255),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.search,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 40,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration.collapsed(
                hintText: 'Buscar...',
                hintStyle: TextStyle(color: Color.fromARGB(131, 0, 0, 0)),
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarraBusqueda3 extends StatelessWidget {
  final TextEditingController searchController;

  BarraBusqueda3({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: Offset(2, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.search,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 40,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration.collapsed(
                hintText: 'Buscar...',
                hintStyle: TextStyle(color: Color.fromARGB(131, 0, 0, 0)),
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
