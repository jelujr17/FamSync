// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class Modulos {
  final int Id;
  final String Nombre;
  final String Descripcion;

  Modulos({
    required this.Id,
    required this.Nombre,
    required this.Descripcion,
  });
}

class ServiciosModulos {
  // Datos estáticos para simular respuestas de la API
  final List<Modulos> _modulosEstaticos = [
    Modulos(
      Id: 1,
      Nombre: "Tareas",
      Descripcion: "Gestión de tareas y asignaciones para la familia",
    ),
    Modulos(
      Id: 2,
      Nombre: "Calendario",
      Descripcion: "Calendario compartido para eventos familiares",
    ),
    Modulos(
      Id: 3,
      Nombre: "Almacén",
      Descripcion: "Inventario de productos del hogar y lista de compras",
    ),
    Modulos(
      Id: 4,
      Nombre: "Finanzas",
      Descripcion: "Control de gastos e ingresos familiares",
    ),
    Modulos(
      Id: 5,
      Nombre: "Mensajes",
      Descripcion: "Comunicación entre miembros de la familia",
    ),
    Modulos(
      Id: 6,
      Nombre: "Multimedia",
      Descripcion: "Álbum de fotos y videos compartidos",
    ),
  ];

  // Obtener todos los módulos
  Future<List<Modulos>> getModulos(BuildContext context) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 500));

    return _modulosEstaticos;
  }

  // Obtener módulo por ID
  Future<Modulos?> getModulosById(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _modulosEstaticos.firstWhere((modulo) => modulo.Id == Id);
    } catch (e) {
      return null; // Si no encuentra el módulo
    }
  }

  // Registrar módulo (opcional, si necesitas esta funcionalidad)
  Future<bool> registrarModulo(
      BuildContext context, String Nombre, String Descripcion) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Simular ID generado para el nuevo módulo
    final nuevoId = _modulosEstaticos.isNotEmpty
        ? _modulosEstaticos.map((m) => m.Id).reduce((a, b) => a > b ? a : b) + 1
        : 1;

    // Crear el nuevo módulo
    final nuevoModulo = Modulos(
      Id: nuevoId,
      Nombre: Nombre,
      Descripcion: Descripcion,
    );

    // Añadir el módulo a la lista estática
    _modulosEstaticos.add(nuevoModulo);

    print('Módulo registrado con ID: $nuevoId');
    return true;
  }

  // Actualizar módulo (opcional, si necesitas esta funcionalidad)
  Future<bool> actualizarModulo(
      BuildContext context, int Id, String Nombre, String Descripcion) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Buscar índice del módulo a actualizar
    final index = _modulosEstaticos.indexWhere((m) => m.Id == Id);
    if (index == -1) {
      return false; // No se encontró el módulo
    }

    // Crear el módulo actualizado
    final moduloActualizado = Modulos(
      Id: Id,
      Nombre: Nombre,
      Descripcion: Descripcion,
    );

    // Actualizar el módulo en la lista estática
    _modulosEstaticos[index] = moduloActualizado;

    print('Módulo con ID $Id actualizado');
    return true;
  }

  // Eliminar módulo (opcional, si necesitas esta funcionalidad)
  Future<bool> eliminarModulo(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 400));

    // Buscar índice del módulo a eliminar
    final index = _modulosEstaticos.indexWhere((m) => m.Id == Id);
    if (index == -1) {
      return false; // No se encontró el módulo
    }

    // Eliminar el módulo de la lista estática
    _modulosEstaticos.removeAt(index);

    print('Módulo con ID $Id eliminado');
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
