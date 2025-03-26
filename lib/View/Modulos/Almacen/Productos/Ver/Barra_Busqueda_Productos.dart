
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class BarraBusqueda extends StatelessWidget {
  const BarraBusqueda({super.key, required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colores.negro, // Fondo gris oscuro
          hintStyle: const TextStyle(
            color: Colores.amarillo, // Texto del placeholder en amarillo
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          hintText: "Buscar producto",
          prefixIcon: const Icon(Icons.search, color: Colores.amarillo,),
        ),
      ),
    );
  }
}