import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Tareas/card_tarea.dart';
import 'package:famsync/View/Modulos/Tareas/categorias_tareas.dart';
import 'package:famsync/View/Modulos/Tareas/modelo_tarea.dart';
import 'package:famsync/View/Modulos/Tareas/tareas.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/categorias.dart';

class Agenda extends StatefulWidget {
  const Agenda({super.key, required this.perfil});
  final Perfiles perfil;

  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  List<Categorias> categoriasTareasAux = [];

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Color getContrastingTextColor(Color backgroundColor) {
    // Calcular el brillo del color de fondo usando la fórmula de luminancia relativa
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    // Si el color es oscuro, usar texto blanco; si es claro, usar texto negro
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Future<void> cargarCategorias() async {
    // Simulación de una llamada asíncrona

    categoriasTareasAux = await ServiciosCategorias()
        .getCategoriasByModulo(widget.perfil.UsuarioId, 5);
    if (mounted) {
      setState(() {
        // Actualiza el estado aquí
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Agenda",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: estadosTareas
                      .map(
                        (course) => Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: CourseCard(
                            title: course.title,
                            iconSrc: course.iconSrc,
                            color: course.color,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Mis categorías",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              if (categoriasTareasAux.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ...categoriasTareasAux.map((categoria) => Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: SecondaryCourseCard(
                        title: categoria.Nombre,
                        iconsSrc: "assets/icons/code.svg",
                        colorl: Color(int.parse("0xFF${categoria.Color}")),
                        textColor: getContrastingTextColor(Color(int.parse(
                            "0xFF${categoria.Color}"))), // Color del texto dinámico
                        onIconPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TareasPage(
                                perfil: widget.perfil,
                              ), // Página de destino
                            ),
                          );
                        },
                      ),
                    )),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
