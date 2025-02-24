import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart' show Color;

class Course {
  final String title, description, iconSrc;
  final Color color;

  Course({
    required this.title,
    this.description = 'Build and animate an iOS app from scratch',
    this.iconSrc = "assets/icons/ios.svg",
    this.color = const Color(0xFF7553F6),
  });
}

final List<Course> estadosTareas = [
  Course(
    title: "Todas",
    iconSrc: "assets/icons/code.svg",
    color: Colores.botones,
  ),
  Course(
    title: "Programadas",
    iconSrc: "assets/icons/code.svg",
    color: Colores.botonesSecundarios,
  ),
  Course(
    title: "Por hacer",
    iconSrc: "assets/icons/code.svg",
    color: Colores.botones,
  ),
  Course(
    title: "Completadas",
    iconSrc: "assets/icons/code.svg",
    color: Colores.botonesSecundarios,
  ),
  Course(
    title: "Urgentes",
    iconSrc: "assets/icons/code.svg",
    color: Colores.botones,
  ),
];

