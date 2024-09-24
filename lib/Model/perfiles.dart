// ignore_for_file: avoid_print, non_constant_identifier_names
import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:smart_family/Library/db_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// CLASES DE PERSONAS REALES
class Perfiles {
  final int Id;
  final int UsuarioId;
  final String Nombre;
  final String FotoPerfil;
  final int Pin;
  final String FechaNacimiento;
  final int Infantil;

  Perfiles(
      {required this.Id,
      required this.UsuarioId,
      required this.Nombre,
      required this.FotoPerfil,
      required this.Pin,
      required this.FechaNacimiento,
      required this.Infantil});
}

class ServicioPerfiles {
  // BUSCAR USUARIOS //
  Future<List<Perfiles>> getPerfiles(int UsuarioId) async {
    http.Response response = await http.get(
      Uri.parse(
          'http://localhost:3000/perfiles/getByUsuario?UsuarioId=$UsuarioId'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
      print(responseData);
      List<Perfiles> perfiles = responseData
          .map((data) => Perfiles(
                Id: data['Id'],
                UsuarioId: data['UsuarioId'],
                Nombre: data['Nombre'],
                FotoPerfil: data['FotoPerfil'],
                Pin: data['Pin'],
                FechaNacimiento: data['FechaNacimiento'],
                Infantil: data['Infantil'],
              ))
          .toList();
      return perfiles;
    } else {
      throw Exception(
          'Error al obtener los perfiles'); // Lanzar una excepción en caso de error
    }
  }

  Future<Perfiles?> getPerfilById(int Id) async {
    http.Response response = await http.get(
      Uri.parse('http://localhost:3000/perfiles/getById?Id=$Id'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
          'Respuesta de la API: $responseData'); // Imprimir respuesta para depuración

      // Acceder a los argumentos
      Map<String, dynamic> perfilData = responseData['arguments'];

      // Crear el objeto Usuario con los datos del argumento
      Perfiles perfil = Perfiles(
        Id: perfilData['Id'] ?? 0, // Valor por defecto en caso de null
        UsuarioId: perfilData['UsuarioId'] ?? '',
        Nombre: perfilData['Nombre'] ?? '',
        FotoPerfil: perfilData['FotoPerfilId'] ?? '',
        Pin: perfilData['Pin'] ?? '',
        FechaNacimiento: perfilData['FechaNacimiento'] ?? '',
        Infantil: perfilData['Infantil'] ?? '',
      );
      return perfil;
    } else {
      throw Exception(
          'Error al obtener el perfil'); // Lanzar una excepción en caso de error
    }
  }

  // Registro de usuario con verificación
  Future<bool> registrarPerfil(int UsuarioId, String Nombre, File imagen,
      int Pin, String FechaNacimiento, int Infantil) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/perfiles/uploadImagen'),
    );

    // Paso 2: Adjuntar el archivo a la solicitud
    request.files.add(
      await http.MultipartFile.fromPath(
        'imagen',
        imagen.path,
      ),
    );
// Envía la solicitud y maneja la respuesta
    String nombre = "error";
    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // La solicitud se completó con éxito
        print('Solicitud completada con éxito');

        // Lee el cuerpo de la respuesta como una cadena
        print('Cuerpo de la respuesta: $responseBody');
        nombre = responseBody;
      } else {
        // Error en la solicitud
        print('Error en la solicitud: ${responseBody.toString()}');
      }
    } catch (e) {
      // Error al enviar la solicitud
      print('Error al enviar la solicitud: $e');
    }

    Map<String, dynamic> jsonMap = json.decode(nombre);
    String imageUrl = jsonMap['imageUrl'];

    // Dividir la cadena por el carácter '.' y obtener el nombre del archivo sin la extensión

    // Paso 3: Guardar el producto en la base de datos con la URL de la imagen
    Map<String, dynamic> PerfilData = {
      'UsuarioId': UsuarioId,
      'Nombre': Nombre.toString(),
      'FotoPerfil': imageUrl,
      'Pin': Pin,
      'FechaNacimiento': FechaNacimiento.toString(),
      'Infantil': Infantil,
    };

    http.Response response1 = await http.post(
      Uri.parse('http://localhost:3000/perfiles/create'),
      headers: {'Content-type': 'application/json'},
      body: json.encode(PerfilData),
    );
    if (response1.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> editarPerfil(int Id, String Nombre, int FotoPerfilId, int Pin,
      String FechaNacimiento) async {
    MySqlConnection conn = await DB().conexion();
    print("-------");
    print(Id);
    print(Nombre);
    print(FotoPerfilId);
    print(Pin);
    print(FechaNacimiento);
    try {
      await conn.query(
          'UPDATE perfiles SET Nombre = ?, FotoPerfilId = ?, Pin = ?, FechaNacimiento = ? WHERE Id = ?',
          [Nombre, FotoPerfilId, Pin, FechaNacimiento, Id]);

      return true;
    } catch (e) {
      print('Registro de perfil fallido: $e');
      return false;
    } finally {
      await conn.close();
    }
  }

  Future<bool> eliminarPerfil(int Id) async {
    MySqlConnection conn = await DB().conexion();
    print("-------");
    print(Id);

    try {
      await conn.query('DELETE FROM perfiles WHERE Id = ?', [Id]);

      return true;
    } catch (e) {
      print('Eliminación de perfil fallido: $e');
      return false;
    } finally {
      await conn.close();
    }
  }

  Future<File> obtenerImagen(String nombre) async {
    Map<String, dynamic> data = {"fileName": nombre};
    // Realizar la solicitud al servidor
    final response = await http.post(
      Uri.parse('http://localhost:3000/perfiles/receiveFile'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode(data),
    );
    // Verificar si la solicitud fue exitosa
    if (response.statusCode == 200) {
      // Guardar el contenido de la respuesta en un archivo temporal
      const tempDir =
          'C:\\Users\\mario\\Documents\\Imagenes_Smart_Family\\Perfiles\\';
      final filePath =
          '$tempDir/$nombre'; // Puedes usar un nombre de archivo específico si lo deseas
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print("imagen encontrada");
      return file; // Devolver el archivo creado
    } else {
      print("imagen no encontrada");
      // Si hay un error en la solicitud, lanzar una excepción
      throw Exception('Error al obtener el archivo: ${response.statusCode}');
    }
  }
}
