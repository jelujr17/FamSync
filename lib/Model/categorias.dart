// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class Categorias {
  final int Id;
  final int IdModulo;
  final String Color;
  final String Nombre;
  final int IdUsuario;

  Categorias({
    required this.Id,
    required this.IdModulo,
    required this.Color,
    required this.Nombre,
    required this.IdUsuario,
  });
}

class ServiciosCategorias {
  // Datos estáticos para simular respuestas de la API
  final List<Categorias> _categoriasEstaticas = [
    // Categorías para el módulo de Tareas (IdModulo: 1)
    Categorias(
      Id: 1,
      IdModulo: 1,
      Color: "#FF5733",
      Nombre: "Hogar",
      IdUsuario: 1,
    ),
    Categorias(
      Id: 2,
      IdModulo: 1,
      Color: "#33FF57",
      Nombre: "Trabajo",
      IdUsuario: 1,
    ),
    Categorias(
      Id: 3,
      IdModulo: 1,
      Color: "#3357FF",
      Nombre: "Escuela",
      IdUsuario: 1,
    ),

    // Categorías para el módulo de Calendario (IdModulo: 2)
    Categorias(
      Id: 4,
      IdModulo: 2,
      Color: "#FF33A8",
      Nombre: "Eventos familiares",
      IdUsuario: 1,
    ),
    Categorias(
      Id: 5,
      IdModulo: 2,
      Color: "#33FFF6",
      Nombre: "Citas médicas",
      IdUsuario: 1,
    ),

    // Categorías para el módulo de Almacén (IdModulo: 3)
    Categorias(
      Id: 6,
      IdModulo: 3,
      Color: "#FFD700",
      Nombre: "Alimentos",
      IdUsuario: 1,
    ),
    Categorias(
      Id: 7,
      IdModulo: 3,
      Color: "#9370DB",
      Nombre: "Limpieza",
      IdUsuario: 1,
    ),
    Categorias(
      Id: 8,
      IdModulo: 3,
      Color: "#20B2AA",
      Nombre: "Higiene personal",
      IdUsuario: 1,
    ),

    // Categorías para otros usuarios
    Categorias(
      Id: 9,
      IdModulo: 1,
      Color: "#FF8C00",
      Nombre: "Personal",
      IdUsuario: 2,
    ),
    Categorias(
      Id: 10,
      IdModulo: 2,
      Color: "#8A2BE2",
      Nombre: "Cumpleaños",
      IdUsuario: 2,
    ),
  ];

  // Obtener categorías por usuario
  Future<List<Categorias>> getCategorias(
      BuildContext context, int IdUsuario) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 500));

    return _categoriasEstaticas
        .where((categoria) => categoria.IdUsuario == IdUsuario)
        .toList();
  }

  // Obtener categorías por módulo
  Future<List<Categorias>> getCategoriasByModulo(
      BuildContext context, int IdUsuario, int IdModulo) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 400));

    return _categoriasEstaticas
        .where((categoria) =>
            categoria.IdUsuario == IdUsuario && categoria.IdModulo == IdModulo)
        .toList();
  }

  // Obtener categoría por ID
  Future<Categorias?> getCategoriasById(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _categoriasEstaticas.firstWhere((categoria) => categoria.Id == Id);
    } catch (e) {
      return null; // Si no encuentra la categoría
    }
  }

  // Registrar categoría
  Future<bool> registrarCategoria(BuildContext context, int IdModulo,
      String Nombre, String Color, int IdUsuario) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Simular ID generado para la nueva categoría
    final nuevoId = _categoriasEstaticas.isNotEmpty
        ? _categoriasEstaticas
                .map((c) => c.Id)
                .reduce((a, b) => a > b ? a : b) +
            1
        : 1;

    // Crear la nueva categoría
    final nuevaCategoria = Categorias(
      Id: nuevoId,
      IdModulo: IdModulo,
      Nombre: Nombre,
      Color: Color,
      IdUsuario: IdUsuario,
    );

    // Añadir la categoría a la lista estática
    _categoriasEstaticas.add(nuevaCategoria);

    print('Categoría registrada con ID: $nuevoId');
    return true;
  }

  // Actualizar categoría
  Future<bool> actualizarCategoria(BuildContext context, int Id, int IdModulo,
      String Nombre, String Color, int IdUsuario) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 600));

    // Buscar índice de la categoría a actualizar
    final index = _categoriasEstaticas.indexWhere((c) => c.Id == Id);
    if (index == -1) {
      return false; // No se encontró la categoría
    }

    // Crear la categoría actualizada
    final categoriaActualizada = Categorias(
      Id: Id,
      IdModulo: IdModulo,
      Nombre: Nombre,
      Color: Color,
      IdUsuario: IdUsuario,
    );

    // Actualizar la categoría en la lista estática
    _categoriasEstaticas[index] = categoriaActualizada;

    print('Categoría con ID $Id actualizada');
    return true;
  }

  // Eliminar categoría
  Future<bool> eliminarCategoria(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 400));

    // Buscar índice de la categoría a eliminar
    final index = _categoriasEstaticas.indexWhere((c) => c.Id == Id);
    if (index == -1) {
      return false; // No se encontró la categoría
    }

    // Eliminar la categoría de la lista estática
    _categoriasEstaticas.removeAt(index);

    print('Categoría con ID $Id eliminada');
    return true;
  }
}

// Servicio global para manejar errores de conexión (versión simulada)
class HttpService {
  static Future<http.Response> execute(
    BuildContext context,
    Future<http.Response> Function() httpCall,
  ) async {
    try {
      // Simular una respuesta HTTP exitosa
      final headers = {'content-type': 'application/json'};
      final body = utf8.encode(json.encode({'status': 'success'}));

      return http.Response.bytes(body, 200, headers: headers);
    } catch (e) {
      print('Error simulado en HttpService: $e');
      // Comentado para evitar navegación no deseada durante pruebas
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const NoconnectionScreen()),
      // );
      throw Exception('Error simulado en la conexión con la base de datos');
    }
  }
}
