import 'package:flutter/material.dart';
import 'package:smart_family/View/navegacion_dart';
import 'package:smart_family/components/colores.dart';

class InicioScreen extends StatefulWidget {
  final int IdUsuario;

  const InicioScreen({super.key, required this.IdUsuario});

  @override
  InicioScreenState createState() => InicioScreenState();
}

class InicioScreenState extends State<InicioScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      // Aquí puedes manejar la navegación según el índice seleccionado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Text('Página $_selectedIndex'),
      ),
      bottomNavigationBar: FloatingNavigationBar(
        onTabSelected: _onTabSelected,
        initialIndex: _selectedIndex,
      ),
    );
  }
}
