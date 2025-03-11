
import 'package:flutter/material.dart';

class CampoNombreCrear extends StatelessWidget {
  final TextEditingController nombreController;
  final String? Function(String?)? validator;

  const CampoNombreCrear({
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
          labelText: 'Nombre del producto',
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          hintText: 'Ingresa un nombre para el producto',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.shopping_bag, color: Colors.blue),
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
            borderSide: const BorderSide(color: Colors.blue, width: 2),
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