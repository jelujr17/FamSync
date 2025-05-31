import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class CampoNombreCrearEvento extends StatelessWidget {
  final TextEditingController nombreController;
  final String? Function(String?)? validator;

  const CampoNombreCrearEvento({
    super.key,
    required this.nombreController,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: nombreController,
        decoration: InputDecoration(
          labelText: 'nombre del Evento',
          labelStyle: const TextStyle(fontSize: 16, color: Colores.texto),
          hintText: 'Ingresa un nombre para el evento',
          hintStyle: const TextStyle(color: Colores.texto),
          prefixIcon: const Icon(Icons.shopping_bag, color: Colores.texto),
          filled: true,
          fillColor: Colores.fondoAux,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none, // Sin borde inicial
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colores.fondoAux, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colores.texto, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        style: const TextStyle(
            color: Colores.texto), // Cambia el color del texto aquí

        validator: validator,
      ),
    );
  }
}
