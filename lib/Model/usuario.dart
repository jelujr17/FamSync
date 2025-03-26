// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:famsync/components/host.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Error_Conexion.dart';

abstract class Authenticatable {}

// CLASES DE PERSONAS REALES
class Usuario implements Authenticatable {
  final int Id;
  final int Telefono;
  final String Correo;
  final String Nombre;
  final String Password;

  Usuario({
    required this.Id,
    required this.Telefono,
    required this.Correo,
    required this.Nombre,
    required this.Password,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      Id: map['Id'] as int,
      Telefono: map['Telefono'] as int,
      Correo: map['Correo'] as String,
      Nombre: map['Nombre'] as String,
      Password: map['Password'] as String,
    );
  }
}

class ServicioUsuarios {
  final String _host = Host.host;

  // Obtener todos los usuarios
  Future<List<Usuario>> getUsuarios(BuildContext context) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/usuario/get'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Usuario(
          Id: data['Id'],
          Telefono: data['Telefono'],
          Correo: data['Correo'],
          Nombre: data['Nombre'],
          Password: data['Password'],
        );
      }).toList();
    } else {
      throw Exception('Error al obtener los usuarios');
    }
  }

  // Obtener usuario por correo
  Future<Usuario?> getUsuarioByCorreo(
      BuildContext context, String correo) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/usuarios/getByCorreo?correo=$correo'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> usuarioData = responseData['arguments'];

      return Usuario(
        Id: usuarioData['Id'] ?? 0,
        Telefono: usuarioData['Telefono'] ?? 0,
        Correo: usuarioData['Correo'] ?? '',
        Nombre: usuarioData['Nombre'] ?? '',
        Password: usuarioData['Password'] ?? '',
      );
    } else {
      throw Exception('Error al obtener el usuario por correo');
    }
  }

  // Obtener usuario por teléfono
  Future<Usuario?> getUsuarioByTelefono(
      BuildContext context, int telefono) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/usuarios/getByTelefono?telefono=$telefono'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> usuarioData = responseData['arguments'];

      return Usuario(
        Id: usuarioData['Id'] ?? 0,
        Telefono: usuarioData['Telefono'] ?? 0,
        Correo: usuarioData['Correo'] ?? '',
        Nombre: usuarioData['Nombre'] ?? '',
        Password: usuarioData['Password'] ?? '',
      );
    } else {
      throw Exception('Error al obtener el usuario por teléfono');
    }
  }

  // Login de usuario
  Future<Usuario?> login(
      BuildContext context, String usuario, String password) async {
    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/usuarios/login'),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          'usuario': usuario,
          'password': password,
        }),
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return Usuario(
        Id: responseData['usuario']['Id'],
        Telefono: responseData['usuario']['Telefono'],
        Correo: responseData['usuario']['Correo'],
        Nombre: responseData['usuario']['Nombre'],
        Password: password,
      );
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }

  // Registrar usuario
  Future<int?> registrarUsuario(BuildContext context, int telefono,
      String correo, String nombre, String password) async {
    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/usuarios/create'),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          'Telefono': telefono,
          'Correo': correo,
          'Nombre': nombre,
          'Password': password,
        }),
      ),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      int userId = data["userId"];
      return userId;
    } else {
      throw Exception('Error al registrar usuario');
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
