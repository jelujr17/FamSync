// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

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
  // Datos estáticos para simular respuestas de la API
  static final List<Usuario> _usuariosEstaticos = [
    Usuario(
      Id: 1,
      Telefono: 123456789,
      Correo: "usuario1@ejemplo.com",
      Nombre: "Usuario Uno",
      Password: "password123",
    ),
    Usuario(
      Id: 2,
      Telefono: 987654321,
      Correo: "usuario2@ejemplo.com",
      Nombre: "Usuario Dos",
      Password: "clave456",
    ),
    Usuario(
      Id: 3,
      Telefono: 555555555,
      Correo: "admin@famsync.com",
      Nombre: "Administrador",
      Password: "admin123",
    ),
  ];

  // Obtener todos los usuarios
  Future<List<Usuario>> getUsuarios(BuildContext context) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 500));
    return _usuariosEstaticos;
  }

  // Obtener usuario por correo
  Future<Usuario?> getUsuarioByCorreo(
      BuildContext context, String correo) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _usuariosEstaticos.firstWhere(
        (usuario) => usuario.Correo.toLowerCase() == correo.toLowerCase(),
      );
    } catch (e) {
      // Si no encuentra el usuario, retorna null
      return null;
    }
  }

  // Obtener usuario por teléfono
  Future<Usuario?> getUsuarioByTelefono(
      BuildContext context, int telefono) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _usuariosEstaticos.firstWhere(
        (usuario) => usuario.Telefono == telefono,
      );
    } catch (e) {
      // Si no encuentra el usuario, retorna null
      return null;
    }
  }

  // Login de usuario
  Future<Usuario?> login(
      BuildContext context, String usuario, String password) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Intenta encontrar por correo o por nombre de usuario
      final foundUser = _usuariosEstaticos.firstWhere(
        (u) =>
            (u.Correo.toLowerCase() == usuario.toLowerCase() ||
                u.Nombre.toLowerCase() == usuario.toLowerCase()) &&
            u.Password == password,
      );
      return foundUser;
    } catch (e) {
      // Si no encuentra el usuario o la contraseña no coincide, retorna null
      return null;
    }
  }

  // Registrar usuario
  Future<int?> registrarUsuario(BuildContext context, int telefono,
      String correo, String nombre, String password) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Verificar si ya existe un usuario con ese correo o teléfono
    final existeUsuario = _usuariosEstaticos.any((u) =>
        u.Correo.toLowerCase() == correo.toLowerCase() ||
        u.Telefono == telefono);

    if (existeUsuario) {
      return null; // Simular error de usuario ya existente
    }

    // Simular ID generado para el nuevo usuario
    final nuevoId = _usuariosEstaticos.isNotEmpty
        ? _usuariosEstaticos.map((u) => u.Id).reduce((a, b) => a > b ? a : b) +
            1
        : 1;

    // Crear el nuevo usuario
    final nuevoUsuario = Usuario(
      Id: nuevoId,
      Telefono: telefono,
      Correo: correo,
      Nombre: nombre,
      Password: password,
    );

    // Añadir el usuario a la lista estática
    _usuariosEstaticos.add(nuevoUsuario);

    print('Usuario registrado con ID: $nuevoId');
    return nuevoId;
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
