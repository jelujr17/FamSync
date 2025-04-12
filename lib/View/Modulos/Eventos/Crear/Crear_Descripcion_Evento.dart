import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class CampoDescripcionCrearEvento extends StatelessWidget {
  final TextEditingController descripcionController;
  final String? Function(String?)? validator;

  const CampoDescripcionCrearEvento({
    super.key,
    required this.descripcionController,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: descripcionController,
        decoration: InputDecoration(
          labelText: 'Descripción del Evento',
          labelStyle: const TextStyle(fontSize: 16, color: Colores.texto),
          hintText: 'Ingresa una descripción para el evento',
          hintStyle: const TextStyle(color: Colores.texto),
          prefixIcon: const Icon(Icons.description, color: Colores.texto),
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
          color: Colores.texto, // Cambia el color del texto aquí
        ),
        maxLines: 5, // Permite que el campo tenga hasta 5 líneas
        minLines: 3, // Mínimo de 3 líneas para que sea más grande
        keyboardType:
            TextInputType.multiline, // Permite entrada de texto multilinea
        validator: validator,
      ),
    );
  }
}
