import 'package:famsync/Model/Categorias.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class CampoCategoriaEditarTarea extends StatelessWidget {
  final String? categoriaSeleccionada;
  final List<String> categoriasDisponibles;
  final void Function(String?) onCategoriaSeleccionada;
  final List<Categorias> categorias;

  const CampoCategoriaEditarTarea({
    super.key,
    required this.categoriaSeleccionada,
    required this.categoriasDisponibles,
    required this.onCategoriaSeleccionada,
    required this.categorias,
  });

  @override
  Widget build(BuildContext context) {
    categorias.add(Categorias(
        CategoriaID: "0",
        Color: "000000",
        nombre: "Sin Categoría",
        PerfilID: "0"));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: DropdownButtonFormField<String>(
        value: categoriaSeleccionada,
        decoration: InputDecoration(
          labelText: 'Categoría del Evento',
          labelStyle: const TextStyle(fontSize: 16, color: Colores.texto),
          prefixIcon: const Icon(Icons.category, color: Colores.texto),
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
        dropdownColor: Colores.fondoAux, // Fondo del menú desplegable
        items: categorias.map((Categorias categoria) {
          return DropdownMenuItem<String>(
            value: categoria.nombre,
            child: Row(
              children: [
                const SizedBox(width: 10),
                // Esfera de color
                Text(
                  categoria.nombre,
                  style:
                      const TextStyle(color: Colores.texto), // Color del texto
                ),

                const SizedBox(
                    width: 10), // Espaciado entre la esfera y el texto
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(int.parse(
                        "0xFF${categoria.Color}")), // Color de la categoría
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onCategoriaSeleccionada,
        style: const TextStyle(
          color: Colores.texto, // Color del texto seleccionado
        ),
      ),
    );
  }
}
