// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

// CLASE DE TIENDAS
class Tiendas {
  final int Id;
  final String Nombre;
  final int IdUsuario;

  Tiendas({
    required this.Id,
    required this.Nombre,
    required this.IdUsuario,
  });
}

class ServiciosTiendas {
  // Datos estáticos para simular respuestas de la API
  final List<Tiendas> _tiendasEstaticas = [
    Tiendas(
      Id: 1,
      Nombre: "Supermercado Central",
      IdUsuario: 1,
    ),
    Tiendas(
      Id: 2,
      Nombre: "Mercado Local",
      IdUsuario: 1,
    ),
    Tiendas(
      Id: 3,
      Nombre: "Tienda de Conveniencia",
      IdUsuario: 1,
    ),
    Tiendas(
      Id: 4,
      Nombre: "Farmacia",
      IdUsuario: 1,
    ),
    Tiendas(
      Id: 5,
      Nombre: "Ferretería",
      IdUsuario: 1,
    ),
    Tiendas(
      Id: 6,
      Nombre: "Supermercado Express",
      IdUsuario: 2,
    ),
    Tiendas(
      Id: 7,
      Nombre: "Tienda Online",
      IdUsuario: 2,
    ),
    Tiendas(
      Id: 8,
      Nombre: "Tienda Departamental",
      IdUsuario: 3,
    ),
  ];

  // Obtener tiendas por usuario
  Future<List<Tiendas>> getTiendas(BuildContext context, int IdUsuario) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 500));

    return _tiendasEstaticas
        .where((tienda) => tienda.IdUsuario == IdUsuario)
        .toList();
  }

  // Obtener tienda por ID
  Future<Tiendas?> getTiendasById(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _tiendasEstaticas.firstWhere((tienda) => tienda.Id == Id);
    } catch (e) {
      return null; // Si no encuentra la tienda
    }
  }

  // Registrar tienda
  Future<bool> registrarTienda(
      BuildContext context, String Nombre, int IdUsuario) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Simular ID generado para la nueva tienda
    final nuevoId = _tiendasEstaticas.isNotEmpty
        ? _tiendasEstaticas.map((t) => t.Id).reduce((a, b) => a > b ? a : b) + 1
        : 1;

    // Crear la nueva tienda
    final nuevaTienda = Tiendas(
      Id: nuevoId,
      Nombre: Nombre,
      IdUsuario: IdUsuario,
    );

    // Añadir la tienda a la lista estática
    _tiendasEstaticas.add(nuevaTienda);

    print('Tienda registrada con ID: $nuevoId');
    return true;
  }

  // Eliminar tienda
  Future<bool> eliminarTienda(BuildContext context, int IdTienda) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 400));

    // Buscar índice de la tienda a eliminar
    final index = _tiendasEstaticas.indexWhere((t) => t.Id == IdTienda);
    if (index == -1) {
      return false; // No se encontró la tienda
    }

    // Eliminar la tienda de la lista estática
    _tiendasEstaticas.removeAt(index);

    print('Tienda con ID $IdTienda eliminada');
    return true;
  }

  // Método adicional: Actualizar tienda
  Future<bool> actualizarTienda(
      BuildContext context, int Id, String Nombre, int IdUsuario) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 600));

    // Buscar índice de la tienda a actualizar
    final index = _tiendasEstaticas.indexWhere((t) => t.Id == Id);
    if (index == -1) {
      return false; // No se encontró la tienda
    }

    // Crear la tienda actualizada
    final tiendaActualizada = Tiendas(
      Id: Id,
      Nombre: Nombre,
      IdUsuario: IdUsuario,
    );

    // Actualizar la tienda en la lista estática
    _tiendasEstaticas[index] = tiendaActualizada;

    print('Tienda con ID $Id actualizada');
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
