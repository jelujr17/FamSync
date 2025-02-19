// ignore_for_file: avoid_print, non_constant_identifier_names
import 'dart:io';

import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

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
  final String _host = Host.host;

  // BUSCAR USUARIOS //
  Future<List<Perfiles>> getPerfiles(int UsuarioId) async {
    http.Response response = await http.get(
      Uri.parse('http://$_host/perfiles/getByUsuario?UsuarioId=$UsuarioId'),
      headers: {'Content-type': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
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
      Uri.parse('http://$_host/perfiles/getById?Id=$Id'),
      headers: {'Content-type': 'application/json'},
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
          'Respuesta de la API: $responseData'); // Imprimir respuesta para depuración

      // Acceder a los argumentos
      Map<String, dynamic> perfilData = responseData['arguments'];

      Perfiles perfil = Perfiles(
        Id: perfilData['Id'] ?? 0, // Valor por defecto en caso de null
        UsuarioId: perfilData['UsuarioId'] ?? '',
        Nombre: perfilData['Nombre'] ?? '',
        FotoPerfil: perfilData['FotoPerfil'] ?? '',
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

  Future<List<Perfiles>> getPerfilesByPerfil(List<int> IdPerfiles) async {
    List<Perfiles> perfilesProductos = [];

    try {
      for (int i = 0; i < IdPerfiles.length; i++) {
        // Realiza una solicitud HTTP para obtener el perfil por ID
        http.Response response = await http.get(
          Uri.parse('http://$_host/perfiles/getById?Id=${IdPerfiles[i]}'),
          headers: {'Content-type': 'application/json'},
        );

        // Si la respuesta es exitosa
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          print('Respuesta de la API: $responseData'); // Para depuración

          // Acceder a los argumentos del perfil
          Map<String, dynamic> perfilData = responseData['arguments'];

          // Crear un objeto 'Perfiles' con los datos recibidos
          Perfiles perfil = Perfiles(
            Id: perfilData['Id'] ?? 0,
            UsuarioId: perfilData['UsuarioId'] ?? '',
            Nombre: perfilData['Nombre'] ?? '',
            FotoPerfil: perfilData['FotoPerfil'] ?? '',
            Pin: perfilData['Pin'] ?? '',
            FechaNacimiento: perfilData['FechaNacimiento'] ?? '',
            Infantil: perfilData['Infantil'] ?? '',
          );

          perfilesProductos.add(perfil);
        } else {
          // Si la respuesta no es exitosa, lanza un error
          throw Exception(
              'Error al obtener el perfil con ID ${IdPerfiles[i]}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error durante la obtención de perfiles: $e');
      rethrow; // Relanzar el error para ser manejado por la capa superior
    }

    return perfilesProductos; // Devolver la lista de perfiles obtenidos
  }

  // Registro de usuario con verificación
  Future<bool> registrarPerfil(int UsuarioId, String Nombre, File imagen,
      int Pin, String FechaNacimiento, int Infantil) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$_host/perfiles/uploadImagen'),
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
      Uri.parse('http://$_host/perfiles/create'),
      headers: {'Content-type': 'application/json'},
      body: json.encode(PerfilData),
    );
    if (response1.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> editarPerfil(int Id, String Nombre, File? imagen, int Pin,
      String FechaNacimiento, String? fotoAnterior, int Infantil) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$_host/perfiles/uploadImagen'),
    );

    // Paso 2: Adjuntar el archivo a la solicitud
    request.files.add(
      await http.MultipartFile.fromPath(
        'imagen',
        imagen!.path,
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

    // Actualizar el perfil en la base de datos con la nueva imagen
    Map<String, dynamic> perfilData = {
      'Id': Id,
      'Nombre': Nombre,
      'FotoPerfil': imageUrl,
      'Pin': Pin,
      'FechaNacimiento': FechaNacimiento,
      'Infantil': Infantil
    };

    try {
      http.Response response1 = await http.post(
        Uri.parse('http://$_host/perfiles/update'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(perfilData),
      );

      return response1.statusCode == 200;
    } catch (e) {
      print('Error al actualizar el perfil: $e');
      return false;
    }
  }

// Función para eliminar la foto anterior
  Future<void> eliminarFotoAnterior(String fotoUrl) async {
    // Aquí haces la lógica para eliminar la imagen del servidor o sistema de archivos
    try {
      final response = await http.get(
        Uri.parse('http://$_host/perfiles/eliminarImagen?urlImagen=$fotoUrl'),
        headers: {'Content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Foto anterior eliminada con éxito');
      } else {
        print('Error al eliminar la foto anterior: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar solicitud de eliminación de imagen: $e');
    }
  }

  Future<void> eliminarPerfil(int Id) async {
    /*
    MySqlConnection conn = await DB().conexion();
 

    try {
      await conn.query('DELETE FROM perfiles WHERE Id = ?', [Id]);

      return true;
    } catch (e) {
      print('Eliminación de perfil fallido: $e');
      return false;
    } finally {
      await conn.close();
    }*/
  }

  Future<File> obtenerImagen(String nombre) async {
    try {
      // Obtener el directorio temporal del dispositivo
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$nombre';
      final file = File(filePath);

      // Verificar si la imagen ya está guardada en caché
      if (await file.exists()) {
        print("Imagen cargada desde caché: $filePath");
        return file; // Retorna la imagen desde el almacenamiento temporal
      }

      // Si no existe en caché, hacer la solicitud al servidor
      Map<String, dynamic> data = {"fileName": nombre};
      final response = await http.post(
        Uri.parse('http://$_host/perfiles/receiveFile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print("Imagen descargada y guardada en caché: $filePath");
        return file; // Devuelve el archivo descargado
      } else {
        print("Imagen no encontrada en el servidor: ${response.statusCode}");
        throw Exception('Error al obtener el archivo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener la imagen: $e');
      throw Exception('No se pudo obtener la imagen.');
    }
  }
}
