import 'package:famsync/components/colores.dart';
import 'package:famsync/components/iconos_SVG.dart';
import 'package:flutter/material.dart' show Color;

class Estados {
  final String titulo, descripcion, iconSrc;
  final Color color, colorTexto;

  Estados(
      {required this.titulo,
      required this.descripcion,
      required this.iconSrc,
      required this.color,
      required this.colorTexto});
}

final List<Estados> estadosTareas = [
  Estados(
    titulo: "Todas",
    descripcion: "Muestra todas las tareas, sin importar su estado.",
    iconSrc: Iconos_SVG.todasTareasIcono,
    color: Colores.amarillo,
    colorTexto: Colores.negro,
  ),
  Estados(
    titulo: "Programadas",
    descripcion: "Tareas que tienen una fecha programada para completarse.",
    iconSrc: Iconos_SVG.programadasTareas,
    color: Colores.negro,
    colorTexto: Colores.amarillo,
  ),
  Estados(
    titulo: "Por hacer",
    descripcion: "Tareas pendientes que aún no han sido iniciadas.",
    iconSrc: Iconos_SVG.porHacerTareas,
    color: Colores.amarillo,
    colorTexto: Colores.negro,
  ),
  Estados(
    titulo: "Completadas",
    descripcion: "Tareas que ya han sido finalizadas con éxito.",
    iconSrc: Iconos_SVG.completadasTareas,
    color: Colores.negro,
    colorTexto: Colores.amarillo,
  ),
  Estados(
    titulo: "Urgentes",
    descripcion:
        "Tareas que requieren atención inmediata debido a su prioridad.",
    iconSrc: Iconos_SVG.urgenteTareas,
    color: Colores.amarillo,
    colorTexto: Colores.negro,
  ),
  Estados(
    titulo: "En proceso",
    descripcion:
        "Tareas empezasas que no se han completado.",
    iconSrc: Iconos_SVG.urgenteTareas,
    color: Colores.negro,
    colorTexto: Colores.amarillo,
  )
];
