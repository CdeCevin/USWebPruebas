import 'package:flutter/material.dart';

class DropdownBotonEstado extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  DropdownBotonEstado({this.onChanged});

  @override
  _DropdownBotonEstadoState createState() => _DropdownBotonEstadoState();
}

class _DropdownBotonEstadoState extends State<DropdownBotonEstado> {
  String dropdownValue = 'Estados';
  bool _isOpen = false;
  Color? selectedColor;
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _createOverlay();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _createOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 174,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 35),
          child: Material(
            color: Colors.transparent,
            child: _buildDropdown(),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 174,
            height: 35,
            decoration: BoxDecoration(
              color: Color(0xFF3B69AE),
              borderRadius:
                  BorderRadius.circular(4), // Ajusta el radio de las esquinas
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: _toggleDropdown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dropdownValue,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedColor ?? Colors.transparent,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      width: 174,
      decoration: BoxDecoration(
        color: Color(0xFF284B81),
        borderRadius:
            BorderRadius.circular(2), // Ajusta el radio de las esquinas
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildItem('Todos', const Color.fromARGB(255, 255, 255, 255)),
          _buildDivider(),
          _buildItem('Derivada', Color(0xFFEAA51E)),
          _buildDivider(),
          _buildItem('En proceso', Color(0xFFEAF471)),
          _buildDivider(),
          _buildItem('Finalizada', Color(0xFF69DBFF)),
          _buildDivider(),
          _buildItem('Iniciada', Color(0xFF4CAF50)),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildItem(String label, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          dropdownValue = label;
          selectedColor = color;
          _isOpen = false;
        });
        _removeOverlay();
        widget.onChanged?.call(label);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 10,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }
}
