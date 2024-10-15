// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:bcrypt/bcrypt.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class Authenticatable {}

// CLASES DE PERSONAS REALES
class Usuario implements Authenticatable {
  final int Id;
  final int Telefono;
  final String Correo;
  final String Nombre;
  final String Password;

  Usuario(
      {required this.Id,
      required this.Telefono,
      required this.Correo,
      required this.Nombre,
      required this.Password});

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
        Id: map['Id'] as int,
        Telefono: map['Telefono'] as int,
        Correo: map['Correo'] as String,
        Nombre: map['Nombre'] as String,
        Password: map['Password'] as String);
  }
}

class ServicioUsuarios {
  final String _host = 'localhost:3000';
  // BUSCAR USUARIOS //
  Future<List<Usuario>> getUsuarios() async {
    http.Response response =
        await http.get(Uri.parse('http://$_host/usuario/get'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
      print(responseData);
      List<Usuario> usuarios = responseData
          .map((data) => Usuario(
                Id: data['Id'],
                Telefono: data['Telefono'],
                Correo: data['Correo'],
                Nombre: data['Nombre'],
                Password: data['Password'],
              ))
          .toList();
      return usuarios;
    } else {
      throw Exception(
          'Error al obtener los usuarios'); // Lanzar una excepción en caso de error
    }
  }

  Future<Usuario?> getUsuarioByCorreo(String correo) async {
    http.Response response = await http.get(
      Uri.parse('http://$_host/usuarios/getByCorreo?correo=$correo'),
      headers: {'Content-type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
          'Respuesta de la API: $responseData'); // Imprimir respuesta para depuración

      // Acceder a los argumentos
      Map<String, dynamic> usuarioData = responseData['arguments'];

      // Crear el objeto Usuario con los datos del argumento
      Usuario usuario = Usuario(
        Id: usuarioData['Id'] ?? 0, // Valor por defecto en caso de null
        Telefono: usuarioData['Telefono'] ?? 0,
        Correo: usuarioData['Correo'] ?? '',
        Nombre: usuarioData['Nombre'] ?? '',
        Password: usuarioData['Password'] ?? '',
      );
      return usuario;
    } else {
      throw Exception('Error al obtener el usuario por correo');
    }
  }

  Future<Usuario?> getUsuarioByTelefono(int telefono) async {
    http.Response response = await http.get(
      Uri.parse('http://$_host/usuarios/getByTelefono?telefono=$telefono'),
      headers: {'Content-type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
          'Respuesta de la API: $responseData'); // Imprimir respuesta para depuración

      // Acceder a los argumentos
      Map<String, dynamic> usuarioData = responseData['arguments'];

      // Crear el objeto Usuario con los datos del argumento
      Usuario usuario = Usuario(
        Id: usuarioData['Id'] ?? 0, // Valor por defecto en caso de null
        Telefono: usuarioData['Telefono'] ?? '',
        Correo: usuarioData['Correo'] ?? '',
        Nombre: usuarioData['Nombre'] ?? '',
        Password: usuarioData['Password'] ?? '',
      );
      return usuario;
    } else {
      throw Exception('Error al obtener el usuario por telefono');
    }
  }

  Future<Usuario?> login(String usuario, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://$_host/usuarios/login'),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          'usuario': usuario,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        // Crear el objeto Usuario con los datos devueltos
        return Usuario(
          Id: responseData['usuario']['Id'],
          Telefono: responseData['usuario']['Telefono'],
          Correo: responseData['usuario']['Correo'],
          Nombre: responseData['usuario']['Nombre'],
          Password: password, // Asegúrate de no almacenar la contraseña
        );
      } else {
        print(response.statusCode);
        throw Exception('Error al iniciar sesión');
      }
    } catch (e) {
      print('Error en la función de login: $e');
      return null; // Manejo de errores
    }
  }

  // REGISTRO DE USUARIO
  Future<bool> isCorreoRegistered(String correo) async {
    try {
      Usuario? usuario = await getUsuarioByCorreo(correo);
      // Si se obtiene un usuario, el correo está registrado
      return usuario != null;
    } catch (e) {
      // Manejar el error en caso de que la llamada a la API falle
      print('Error al verificar el correo: $e');
      return false; // Devuelve false en caso de error
    }
  }

  Future<bool> isTelefonoRegistered(int telefono) async {
    try {
      Usuario? usuario = await getUsuarioByTelefono(telefono);
      // Si se obtiene un usuario, el teléfono está registrado
      return usuario != null;
    } catch (e) {
      // Manejar el error en caso de que la llamada a la API falle
      print('Error al verificar el teléfono: $e');
      return false; // Devuelve false en caso de error
    }
  }

  Future<bool> registrarUsuario(
      int telefono, String correo, String nombre, String password) async {
    if (await isCorreoRegistered(correo)) {
      print('El correo ya está registrado');
      return false;
    }

    if (await isTelefonoRegistered(telefono)) {
      print('El teléfono ya está registrado');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('http://$_host/usuarios/create'),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          'Telefono': telefono,
          'Correo': correo,
          'Nombre': nombre,
          'Password': password,
        }),
      );

      if (response.statusCode == 201) {
        print('Usuario registrado exitosamente');
        return true;
      } else {
        print('Error en el registro: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al registrar usuario: $e');
      return false;
    }
  }
}
