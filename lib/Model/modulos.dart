// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:famsync/Error_Conexion.dart';

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
  final String _host = Host.host;

  // Obtener todos los módulos
  Future<List<Modulos>> getModulos(BuildContext context) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/modulos/get'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Modulos(
          Id: data['Id'],
          Nombre: data['Nombre'],
          Descripcion: data['Descripcion'],
        );
      }).toList();
    } else {
      throw Exception('Error al obtener los módulos');
    }
  }

  // Obtener módulo por ID
  Future<Modulos?> getModulosById(BuildContext context, int Id) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/modulos/getById?Id=$Id'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> modulosData = responseData['arguments'];

      return Modulos(
        Id: modulosData['Id'],
        Nombre: modulosData['Nombre'],
        Descripcion: modulosData['Descripcion'],
      );
    } else {
      throw Exception('Error al obtener el módulo por ID');
    }
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
