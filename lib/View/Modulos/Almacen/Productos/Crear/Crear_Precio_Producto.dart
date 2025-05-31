import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoPrecioCrear extends StatelessWidget {
  final TextEditingController precioController;
  final String? Function(String?)? validator;

  const CampoPrecioCrear({
    super.key,
    required this.precioController,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: precioController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              RegExp(r'[0-9.]')), // Permitir solo números y puntos
          TextInputFormatter.withFunction((oldValue, newValue) {
            // Reemplazar comas por puntos
            final newText = newValue.text.replaceAll(',', '.');
            return newValue.copyWith(
              text: newText,
              selection: TextSelection.collapsed(offset: newText.length),
            );
          }),
        ],
        decoration: InputDecoration(
          labelText: 'precio',
          labelStyle: const TextStyle(fontSize: 16, color: Colores.texto),
          hintText: 'Ingresa un precio para el producto',
          hintStyle: const TextStyle(color: Colores.texto),
          prefixIcon: Icon(Icons.euro, color: Colores.texto),
          filled: true,
          fillColor: Colores.fondoAux,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
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
