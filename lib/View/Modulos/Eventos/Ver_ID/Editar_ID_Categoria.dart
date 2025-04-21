import 'package:famsync/Model/categorias.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class CampoCategoriaEditarEvento extends StatelessWidget {
  final String? categoriaSeleccionada;
  final List<String> categoriasDisponibles;
  final void Function(String?) onCategoriaSeleccionada;
  final List<Categorias> categorias;

  const CampoCategoriaEditarEvento({
    super.key,
    required this.categoriaSeleccionada,
    required this.categoriasDisponibles,
    required this.onCategoriaSeleccionada,
    required this.categorias,
  });

@override
Widget build(BuildContext context) {
  // Asegúrate de que "Sin Categoría" esté en la lista
  if (!categorias.any((categoria) => categoria.Nombre == "Sin Categoría")) {
    categorias.add(Categorias(
      Id: 0,
      Nombre: "Sin Categoría",
      IdModulo: 0,
      Color: "000000",
      IdUsuario: 0,
    ));
  }

  // Elimina duplicados
  final nombresCategoria = categorias
      .map((categoria) => categoria.Nombre)
      .toSet() // Elimina duplicados
      .toList();

  // Si la categoría seleccionada no está en la lista, usa "Sin Categoría"
  final categoriaValida = nombresCategoria.contains(categoriaSeleccionada)
      ? categoriaSeleccionada
      : "Sin Categoría";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: 
      DropdownButtonFormField<String>(
        value: categoriaSeleccionada, // Asegúrate de que el valor sea válido
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
            value: categoria.Nombre,
            child: Row(
              children: [
                const SizedBox(width: 10),
                Text(
                  categoria.Nombre,
                  style: const TextStyle(color: Colores.texto),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(int.parse("0xFF${categoria.Color}")),
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
