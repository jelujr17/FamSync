// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:mysql1/mysql1.dart';
import 'package:smart_family/Library/db_data.dart';

// CLASES DE PERSONAS REALES
class Categorias {
  final int Id;
  final int IdModulo;
  final int IdColor;
  final String Nombre;
  final int IdCreador;
  final String Descripcion;

  Categorias(
      {required this.Id,
      required this.IdModulo,
      required this.IdColor,
      required this.Nombre,
      required this.IdCreador,
      required this.Descripcion});
}

class ServicioCategorias {}
