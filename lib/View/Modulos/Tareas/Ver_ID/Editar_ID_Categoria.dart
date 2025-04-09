import 'package:famsync/Model/categorias.dart';
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
        Id: 0,
        Nombre: "Sin Categoría",
        IdModulo: 0,
        Color: "000000",
        IdUsuario: 0));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: DropdownButtonFormField<String>(
        value: categoriaSeleccionada,
        decoration: InputDecoration(
          labelText: 'Categoría de la Tarea',
          labelStyle: const TextStyle(fontSize: 16, color: Colores.amarillo),
          prefixIcon: const Icon(Icons.category, color: Colores.amarillo),
          filled: true,
          fillColor: Colores.negro,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none, // Sin borde inicial
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colores.negro, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colores.amarillo, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        dropdownColor: Colores.negro, // Fondo del menú desplegable
        items: categorias.map((Categorias categoria) {
          return DropdownMenuItem<String>(
            value: categoria.Nombre,
            child: Row(
              children: [
                const SizedBox(width: 10),
                // Esfera de color
                Text(
                  categoria.Nombre,
                  style: const TextStyle(
                      color: Colores.amarillo), // Color del texto
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
          color: Colores.amarillo, // Color del texto seleccionado
        ),
      ),
    );
  }
}
