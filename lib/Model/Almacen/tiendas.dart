// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:famsync/Error_Conexion.dart';

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
  final String _host = Host.host;

  // Obtener tiendas por usuario
  Future<List<Tiendas>> getTiendas(BuildContext context, int IdUsuario) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/tiendas/getByUsuario?IdUsuario=$IdUsuario'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Tiendas(
          Id: data['Id'],
          Nombre: data['Nombre'],
          IdUsuario: data['IdUsuario'],
        );
      }).toList();
    } else {
      throw Exception(
          'Error al obtener las tiendas de un usuario ${response.statusCode}');
    }
  }

  // Obtener tienda por ID
  Future<Tiendas?> getTiendasById(BuildContext context, int Id) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/tiendas/getById?Id=$Id'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> tiendaData = responseData['arguments'];

      return Tiendas(
        Id: tiendaData['Id'],
        Nombre: tiendaData['Nombre'],
        IdUsuario: tiendaData['IdUsuarioCreador'],
      );
    } else {
      throw Exception('Error al obtener la tienda por ID');
    }
  }

  // Registrar tienda
  Future<bool> registrarTienda(
      BuildContext context, String Nombre, int IdUsuario) async {
    Map<String, dynamic> TiendaData = {
      'Nombre': Nombre.toString(),
      'IdUsuario': IdUsuario
    };

    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/tiendas/create'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(TiendaData),
      ),
    );

    return response.statusCode == 200;
  }

  // Eliminar tienda
  Future<bool> eliminarTienda(BuildContext context, int IdTienda) async {
    final response = await HttpService.execute(
      context,
      () => http.delete(
        Uri.parse('http://$_host/tiendas/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Id': IdTienda}),
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
