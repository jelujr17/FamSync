import 'package:famsync/Model/Categorias.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Model/Tareas.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Banner_Mis_Categorias.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Tareas_Filtradas.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MisCategorias extends StatefulWidget {
  const MisCategorias({
    super.key,
    required this.perfil,
  });

  final Perfiles perfil;

  @override
  MisCategoriasState createState() => MisCategoriasState();
}

class MisCategoriasState extends State<MisCategorias> {
  List<Tareas> tareas = [];
  Map<String, int> tareasPorCategoria = {};
  List<Categorias> categorias = [];
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cargarDatos();
    });
  }

  Future<void> cargarDatos() async {
    final tareasProvider = Provider.of<TareasProvider>(context, listen: false);
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: false);

    // Carga las tareas y categorías
    await tareasProvider.cargarTareas(user!.uid, widget.perfil.PerfilID);
    await categoriasProvider.cargarCategorias(
        user!.uid, widget.perfil.PerfilID);

    // Asigna los datos cargados
    tareas = tareasProvider.tareas;
    categorias = categoriasProvider.categorias;
  }

  void obtenerTareasPorCategoria() {
    // Inicializa el mapa con todas las categorías
    tareasPorCategoria = {
      for (var categoria in categorias) categoria.CategoriaID: 0
    };

    // Cuenta las tareas por categoría
    for (final tarea in tareas) {
      if (tareasPorCategoria.containsKey(tarea.CategoriaID)) {
        if (tarea.CategoriaID != null) {
          tareasPorCategoria[tarea.CategoriaID!] =
              (tareasPorCategoria[tarea.CategoriaID!] ?? 0) + 1;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tareasProvider =
        Provider.of<TareasProvider>(context, listen: true); // Escuchar cambios
    tareas = tareasProvider.tareas; // Actualizar la lista local de tareas
    obtenerTareasPorCategoria(); // Recalcular las tareas por categoría

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "Mis categorías",
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Colores.texto, fontWeight: FontWeight.bold),
          ),
        ),
        if (categorias.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];

                // Determina el color del texto según el índice
                final colorTexto = index % 2 == 0
                    ? Colores.texto // Índices pares
                    : Colores.fondoAux; // Índices impares
                final color = index % 2 == 0
                    ? Colores.fondoAux // Índices pares
                    : Colores.texto; // Índices impares

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SecondaryCourseCard(
                    title: categoria.nombre,
                    cantidadTareas:
                        tareasPorCategoria[categoria.CategoriaID] ?? 0,
                    colorl: color,
                    colorCategoria: Color(int.parse("0xFF${categoria.Color}")),
                    textColor: colorTexto, // Aplica el color dinámico
                    onIconPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TareasFiltradas(
                            perfil: widget.perfil,
                            filtro: categoria.nombre,
                          ), // Página de destino
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
