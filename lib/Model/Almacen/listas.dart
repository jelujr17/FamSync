// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:famsync/Model/Almacen/producto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class Listas {
  final int Id;
  final String Nombre;
  final int IdPerfil;
  final int IdUsuario;
  final List<int> Visible;
  final List<int> Productos;

  Listas({
    required this.Id,
    required this.Nombre,
    required this.IdPerfil,
    required this.IdUsuario,
    required this.Visible,
    required this.Productos,
  });
}

class ServiciosListas {
  // Datos estáticos para simular respuestas de la API
  final List<Listas> _listasEstaticas = [
    Listas(
      Id: 1,
      Nombre: "Lista de compras semanal",
      IdPerfil: 1,
      IdUsuario: 1,
      Visible: [1, 2],
      Productos: [1, 2, 5], // Leche, Pan, Jugo
    ),
    Listas(
      Id: 2,
      Nombre: "Artículos de limpieza",
      IdPerfil: 1,
      IdUsuario: 1,
      Visible: [1],
      Productos: [3], // Detergente
    ),
    Listas(
      Id: 3,
      Nombre: "Productos de higiene",
      IdPerfil: 2,
      IdUsuario: 1,
      Visible: [1, 2],
      Productos: [4], // Pasta Dental
    ),
    Listas(
      Id: 4,
      Nombre: "Herramientas",
      IdPerfil: 3,
      IdUsuario: 2,
      Visible: [3],
      Productos: [6], // Martillo
    ),
    Listas(
      Id: 5,
      Nombre: "Papelería",
      IdPerfil: 3,
      IdUsuario: 2,
      Visible: [3],
      Productos: [7], // Cuaderno
    ),
  ];

  // Obtener listas por usuario y perfil
  Future<List<Listas>> getListas(
      BuildContext context, int IdUsuario, int IdPerfil) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 600));

    return _listasEstaticas
        .where((lista) =>
            lista.IdUsuario == IdUsuario && lista.Visible.contains(IdPerfil))
        .toList();
  }

  // Obtener lista por ID
  Future<Listas?> getListasById(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 300));

    print("Id = $Id");

    try {
      final lista = _listasEstaticas.firstWhere((lista) => lista.Id == Id);
      print('Lista encontrada: ${lista.Nombre}');
      return lista;
    } catch (e) {
      print('Error al obtener la lista: $e');
      return null; // Si no encuentra la lista
    }
  }

  // Incluir producto en una lista
  Future<bool> incluirProducto(
      BuildContext context, Productos producto, Listas lista) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Verificar si el producto ya está en la lista
    List<int> productos = lista.Productos;
    if (productos.contains(producto.Id)) {
      return false;
    }

    // Añadir el producto a la lista
    productos.add(producto.Id);

    // Buscar índice de la lista a actualizar
    final index = _listasEstaticas.indexWhere((l) => l.Id == lista.Id);
    if (index == -1) {
      return false; // No se encontró la lista
    }

    // Crear la lista actualizada
    final listaActualizada = Listas(
      Id: lista.Id,
      Nombre: lista.Nombre,
      IdPerfil: lista.IdPerfil,
      IdUsuario: lista.IdUsuario,
      Visible: lista.Visible,
      Productos: productos,
    );

    // Actualizar la lista en la lista estática
    _listasEstaticas[index] = listaActualizada;

    print('Producto ${producto.Id} añadido a la lista ${lista.Id}');
    return true;
  }

  // Registrar una nueva lista
  Future<bool> registrarLista(BuildContext context, String Nombre, int IdPerfil,
      int IdUsuario, List<int> Visible) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Asegurarse que el perfil creador esté en la lista de visibles
    if (!Visible.contains(IdPerfil)) {
      Visible.add(IdPerfil);
    }

    // Simular ID generado para la nueva lista
    final nuevoId = _listasEstaticas.isNotEmpty
        ? _listasEstaticas.map((l) => l.Id).reduce((a, b) => a > b ? a : b) + 1
        : 1;

    // Crear la nueva lista
    final nuevaLista = Listas(
      Id: nuevoId,
      Nombre: Nombre,
      IdPerfil: IdPerfil,
      IdUsuario: IdUsuario,
      Visible: Visible,
      Productos: [], // Lista vacía inicialmente
    );

    // Añadir la lista a la lista estática
    _listasEstaticas.add(nuevaLista);

    print('Lista registrada con ID: $nuevoId');
    return true;
  }

  // Actualizar una lista
  Future<bool> actualizarLista(BuildContext context, int Id, String Nombre,
      List<int> Visible, List<int> Productos) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 600));

    // Buscar índice de la lista a actualizar
    final index = _listasEstaticas.indexWhere((l) => l.Id == Id);
    if (index == -1) {
      return false; // No se encontró la lista
    }

    // Crear la lista actualizada
    final listaActualizada = Listas(
      Id: Id,
      Nombre: Nombre,
      IdPerfil: _listasEstaticas[index].IdPerfil,
      IdUsuario: _listasEstaticas[index].IdUsuario,
      Visible: Visible,
      Productos: Productos,
    );

    // Actualizar la lista en la lista estática
    _listasEstaticas[index] = listaActualizada;

    print('Lista con ID $Id actualizada');
    return true;
  }

  // Eliminar una lista
  Future<bool> eliminarLista(BuildContext context, int idLista) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 400));

    // Buscar índice de la lista a eliminar
    final index = _listasEstaticas.indexWhere((l) => l.Id == idLista);
    if (index == -1) {
      return false; // No se encontró la lista
    }

    // Eliminar la lista de la lista estática
    _listasEstaticas.removeAt(index);

    print('Lista con ID $idLista eliminada');
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
