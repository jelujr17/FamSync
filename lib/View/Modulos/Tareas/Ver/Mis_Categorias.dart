import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Model/tareas.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Banner_Mis_Categorias.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Tareas_Filtradas.dart';
import 'package:famsync/components/colores.dart';
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
  Map<int, int> tareasPorCategoria = {};
  List<Categorias> categorias = [];

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
    await tareasProvider.cargarTareas(
        context, widget.perfil.UsuarioId, widget.perfil.Id);
    await categoriasProvider.cargarCategorias(
        context, widget.perfil.UsuarioId, 5);

    // Asigna los datos cargados
    tareas = tareasProvider.tareas;
    categorias = categoriasProvider.categorias;
  }

  void obtenerTareasPorCategoria() {
    // Inicializa el mapa con todas las categorías
    tareasPorCategoria = {for (var categoria in categorias) categoria.Id: 0};

    // Cuenta las tareas por categoría
    for (final tarea in tareas) {
      if (tareasPorCategoria.containsKey(tarea.Categoria)) {
        if (tarea.Categoria != null) {
          tareasPorCategoria[tarea.Categoria!] =
              (tareasPorCategoria[tarea.Categoria!] ?? 0) + 1;
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
                .copyWith(color: Colores.amarillo, fontWeight: FontWeight.bold),
          ),
        ),
        if (categorias.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          ...categorias
              .where((categoria) =>
                  tareasPorCategoria[categoria.Id] != null &&
                  tareasPorCategoria[categoria.Id]! >
                      0) // Filtra categorías con tareas
              .toList()
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key; // Índice del elemento
            final categoria = entry.value; // Categoría actual

            // Determina el color del texto según el índice
            final colorTexto = index % 2 == 0
                ? Colores.amarillo // Índices pares
                : Colores.negro; // Índices impares
            final color = index % 2 == 0
                ? Colores.negro // Índices pares
                : Colores.amarillo; // Índices impares

            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: SecondaryCourseCard(
                title: categoria.Nombre,
                cantidadTareas: tareasPorCategoria[categoria.Id] ?? 0,
                colorl: color,
                colorCategoria: Color(int.parse("0xFF${categoria.Color}")),
                textColor: colorTexto, // Aplica el color dinámico
                onIconPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TareasFiltradas(
                        perfil: widget.perfil,
                        filtro: categoria.Nombre,
                      ), // Página de destino
                    ),
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}
