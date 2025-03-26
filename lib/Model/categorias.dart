// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:famsync/Error_Conexion.dart';

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
  final String _host = Host.host;

  // Obtener categorías por usuario
  Future<List<Categorias>> getCategorias(
      BuildContext context, int IdUsuario) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/categorias/getByPerfil?IdUsuario=$IdUsuario'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Categorias(
          Id: data['Id'],
          IdModulo: data['IdModulo'],
          Color: data['Color'],
          Nombre: data['Nombre'],
          IdUsuario: data['IdUsuario'],
        );
      }).toList();
    } else {
      throw Exception(
          'Error al obtener las categorías de un perfil ${response.statusCode}');
    }
  }

  // Obtener categorías por módulo
  Future<List<Categorias>> getCategoriasByModulo(
      BuildContext context, int IdUsuario, int IdModulo) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse(
            'http://$_host/categorias/getByModulo?IdUsuario=$IdUsuario&IdModulo=$IdModulo'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Categorias(
          Id: data['Id'],
          IdModulo: data['IdModulo'],
          Color: data['Color'],
          Nombre: data['Nombre'],
          IdUsuario: data['IdUsuario'],
        );
      }).toList();
    } else {
      throw Exception(
          'Error al obtener las categorías por módulo ${response.statusCode}');
    }
  }

  // Obtener categoría por ID
  Future<Categorias?> getCategoriasById(BuildContext context, int Id) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/categorias/getById?Id=$Id'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> categoriaData = responseData['arguments'];

      return Categorias(
        Id: categoriaData['Id'],
        IdModulo: categoriaData['IdModulo'],
        Nombre: categoriaData['Nombre'],
        Color: categoriaData['Color'],
        IdUsuario: categoriaData['IdUsuario'],
      );
    } else {
      throw Exception('Error al obtener la categoría por ID');
    }
  }

  // Registrar categoría
  Future<bool> registrarCategoria(BuildContext context, int IdModulo,
      String Nombre, String Color, int IdUsuario) async {
    Map<String, dynamic> CategoriaData = {
      'IdModulo': IdModulo,
      'Nombre': Nombre.toString(),
      'Color': Color.toString(),
      'IdUsuario': IdUsuario
    };

    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/categorias/create'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(CategoriaData),
      ),
    );

    return response.statusCode == 200;
  }

  // Eliminar categoría
  Future<bool> eliminarCategoria(BuildContext context, int Id) async {
    final response = await HttpService.execute(
      context,
      () => http.delete(
        Uri.parse('http://$_host/categorias/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Id': Id}),
      ),
    );

    return response.statusCode == 200;
  }
}

// Servicio global para manejar errores de conexión
class HttpService {
  static Future<http.Response> execute(
    BuildContext context,
    Future<http.Response> Function() httpCall,
  ) async {
    try {
      // Ejecuta la llamada HTTP
      return await httpCall();
    } catch (e) {
      // Si ocurre un error, navega a la pantalla de error de conexión
      print('Error en la llamada HTTP: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoconnectionScreen()),
      );
      // Lanza una excepción para detener el flujo
      throw Exception('Error en la conexión con la base de datos');
    }
  }
}
