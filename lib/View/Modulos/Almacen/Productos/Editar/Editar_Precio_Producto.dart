
import 'package:flutter/material.dart';

class CampoPrecioEditar extends StatelessWidget {
  final TextEditingController precioController;
  final String? Function(String?)? validator;

  const CampoPrecioEditar({
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
        keyboardType: const TextInputType.numberWithOptions(
            decimal: true), // Permite decimales
        decoration: InputDecoration(
          labelText: 'Precio',
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          hintText: 'Ingresa un precio para el producto',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.euro,
              color: Colors.green.shade700), // Ícono verde más oscuro
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none, // Sin borde inicial
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        validator: validator,
      ),
    );
  }
}