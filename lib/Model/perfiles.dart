// ignore_for_file: avoid_print, non_constant_identifier_names
import 'dart:io';
import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:famsync/Error_Conexion.dart';

class Perfiles {
  final int Id;
  final int UsuarioId;
  final String Nombre;
  final String FotoPerfil;
  final int Pin;
  final String FechaNacimiento;
  final int Infantil;

  Perfiles({
    required this.Id,
    required this.UsuarioId,
    required this.Nombre,
    required this.FotoPerfil,
    required this.Pin,
    required this.FechaNacimiento,
    required this.Infantil,
  });
}

class ServicioPerfiles {
  final String _host = Host.host;

  // Obtener perfiles por usuario
  Future<List<Perfiles>> getPerfiles(
      BuildContext context, int UsuarioId) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/perfiles/getByUsuario?UsuarioId=$UsuarioId'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Perfiles(
          Id: data['Id'],
          UsuarioId: data['UsuarioId'],
          Nombre: data['Nombre'],
          FotoPerfil: data['FotoPerfil'],
          Pin: data['Pin'],
          FechaNacimiento: data['FechaNacimiento'],
          Infantil: data['Infantil'],
        );
      }).toList();
    } else {
      throw Exception('Error al obtener los perfiles');
    }
  }

  // Obtener perfil por ID
  Future<Perfiles?> getPerfilById(BuildContext context, int Id) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/perfiles/getById?Id=$Id'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> perfilData = responseData['arguments'];

      return Perfiles(
        Id: perfilData['Id'],
        UsuarioId: perfilData['UsuarioId'],
        Nombre: perfilData['Nombre'],
        FotoPerfil: perfilData['FotoPerfil'],
        Pin: perfilData['Pin'],
        FechaNacimiento: perfilData['FechaNacimiento'],
        Infantil: perfilData['Infantil'],
      );
    } else {
      throw Exception('Error al obtener el perfil por ID');
    }
  }

  // Registrar perfil
  Future<bool> registrarPerfil(
      BuildContext context,
      int UsuarioId,
      String Nombre,
      File imagen,
      int Pin,
      String FechaNacimiento,
      int Infantil) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$_host/perfiles/uploadImagen'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'imagen',
        imagen.path,
      ),
    );

    String nombre = "error";
    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        nombre = responseBody;
      } else {
        print('Error en la solicitud: ${responseBody.toString()}');
      }
    } catch (e) {
      print('Error al enviar la solicitud: $e');
    }

    Map<String, dynamic> jsonMap = json.decode(nombre);
    String imageUrl = jsonMap['imageUrl'];

    Map<String, dynamic> PerfilData = {
      'UsuarioId': UsuarioId,
      'Nombre': Nombre,
      'FotoPerfil': imageUrl,
      'Pin': Pin,
      'FechaNacimiento': FechaNacimiento,
      'Infantil': Infantil,
    };

    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/perfiles/create'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(PerfilData),
      ),
    );

    return response.statusCode == 200;
  }

  // Editar perfil
  Future<bool> editarPerfil(
      BuildContext context,
      int Id,
      String Nombre,
      File? imagen,
      int Pin,
      String FechaNacimiento,
      String? fotoAnterior,
      int Infantil) async {
    String imageUrl = fotoAnterior ?? '';

    if (imagen != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$_host/perfiles/uploadImagen'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'imagen',
          imagen.path,
        ),
      );

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonMap = json.decode(responseBody);
          imageUrl = jsonMap['imageUrl'];
        } else {
          print('Error en la solicitud: ${responseBody.toString()}');
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
      }
    }

    Map<String, dynamic> perfilData = {
      'Id': Id,
      'Nombre': Nombre,
      'FotoPerfil': imageUrl,
      'Pin': Pin,
      'FechaNacimiento': FechaNacimiento,
      'Infantil': Infantil,
    };

    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/perfiles/update'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(perfilData),
      ),
    );

    return response.statusCode == 200;
  }

  // Eliminar perfil
  Future<bool> eliminarPerfil(BuildContext context, int Id) async {
    final response = await HttpService.execute(
      context,
      () => http.delete(
        Uri.parse('http://$_host/perfiles/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Id': Id}),
      ),
    );

    return response.statusCode == 200;
  }

  // Obtener imagen de perfil
  Future<File> obtenerImagen(BuildContext context, String nombre) async {
    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/perfiles/receiveFile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"fileName": nombre}),
      ),
    );

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$nombre';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Error al obtener la imagen');
    }
  }
}

// Servicio global para manejar errores de conexión
class HttpService {
  static Future<http.Response> execute(
    BuildContext context,
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoconnectionScreen()),
      );
      rethrow;
    }
  }
}
