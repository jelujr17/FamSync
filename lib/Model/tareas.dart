// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class Tareas {
  final int Id;
  final int Creador;
  final List<int> Destinatario;
  final String Nombre;
  final String Descripcion;
  final int? Categoria;
  final int? IdEvento;
  final int Prioridad;
  final int Progreso;

  Tareas({
    required this.Id,
    required this.Creador,
    required this.Destinatario,
    required this.Nombre,
    required this.Descripcion,
    required this.Categoria,
    required this.IdEvento,
    required this.Prioridad,
    required this.Progreso,
  });
}

class ServicioTareas {
  // Datos estáticos para simular respuestas de la API
  final List<Tareas> _tareasEstaticas = [
    Tareas(
      Id: 1,
      Creador: 1,
      Destinatario: [1, 2],
      Nombre: "Limpiar la cocina",
      Descripcion: "Lavar los platos y limpiar las encimeras",
      Categoria: 1,
      IdEvento: null,
      Prioridad: 2,
      Progreso: 0,
    ),
    Tareas(
      Id: 2,
      Creador: 1,
      Destinatario: [1],
      Nombre: "Hacer la compra",
      Descripcion: "Comprar leche, huevos y pan",
      Categoria: 2,
      IdEvento: null,
      Prioridad: 1,
      Progreso: 1,
    ),
    Tareas(
      Id: 3,
      Creador: 2,
      Destinatario: [1, 2, 3],
      Nombre: "Preparar cena familiar",
      Descripcion: "Preparar pasta con salsa boloñesa",
      Categoria: 1,
      IdEvento: 1,
      Prioridad: 3,
      Progreso: 2,
    ),
    Tareas(
      Id: 4,
      Creador: 3,
      Destinatario: [3],
      Nombre: "Revisar documentos",
      Descripcion: "Revisar facturas pendientes",
      Categoria: 3,
      IdEvento: null,
      Prioridad: 2,
      Progreso: 0,
    ),
  ];

  // Obtener tareas por perfil
  Future<List<Tareas>> getTareas(BuildContext context, int IdPerfil) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Filtrar tareas donde el perfil es destinatario
    return _tareasEstaticas
        .where((tarea) => tarea.Destinatario.contains(IdPerfil))
        .toList();
  }

  // Obtener tarea por ID
  Future<Tareas?> getTareasById(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _tareasEstaticas.firstWhere((tarea) => tarea.Id == Id);
    } catch (e) {
      return null; // Si no encuentra la tarea
    }
  }

  // Registrar tarea
  Future<bool> registrarTarea(
      BuildContext context,
      int Creador,
      List<int> Destinatario,
      String Nombre,
      String Descripcion,
      int? IdEvento,
      int? Categoria,
      int Prioridad,
      int Progreso) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Simular ID generado para la nueva tarea
    final nuevoId = _tareasEstaticas.isNotEmpty
        ? _tareasEstaticas.map((t) => t.Id).reduce((a, b) => a > b ? a : b) + 1
        : 1;

    // Crear la nueva tarea
    final nuevaTarea = Tareas(
      Id: nuevoId,
      Creador: Creador,
      Destinatario: Destinatario,
      Nombre: Nombre,
      Descripcion: Descripcion,
      Categoria: Categoria,
      IdEvento: IdEvento,
      Prioridad: Prioridad,
      Progreso: Progreso,
    );

    // Añadir la tarea a la lista estática
    _tareasEstaticas.add(nuevaTarea);

    print('Tarea registrada con ID: $nuevoId');
    return true;
  }

  // Actualizar tarea
  Future<bool> actualizarTarea(
      BuildContext context,
      int Id,
      int Creador,
      List<int> Destinatario,
      String Nombre,
      String Descripcion,
      int? IdEvento,
      int? Categoria,
      int Prioridad,
      int Progreso) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Buscar índice de la tarea a actualizar
    final index = _tareasEstaticas.indexWhere((t) => t.Id == Id);
    if (index == -1) {
      return false; // No se encontró la tarea
    }

    // Crear la tarea actualizada
    final tareaActualizada = Tareas(
      Id: Id,
      Creador: Creador,
      Destinatario: Destinatario,
      Nombre: Nombre,
      Descripcion: Descripcion,
      Categoria: Categoria,
      IdEvento: IdEvento,
      Prioridad: Prioridad,
      Progreso: Progreso,
    );

    // Actualizar la tarea en la lista estática
    // (En una implementación real, se reemplazaría en la lista)

    print('Tarea con ID $Id actualizada');
    return true;
  }

  // Eliminar tarea
  Future<bool> eliminarTarea(BuildContext context, int IdTarea) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 400));

    // Buscar índice de la tarea a eliminar
    final index = _tareasEstaticas.indexWhere((t) => t.Id == IdTarea);
    if (index == -1) {
      return false; // No se encontró la tarea
    }

    // Eliminar la tarea de la lista estática
    // (En una implementación real, se eliminaría de la lista)

    print('Tarea con ID $IdTarea eliminada');
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
