// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';

class Tareas {
  final int Id;
  final int Creador;
  final List<int> Destinatario;
  final String Nombre;
  final String Descripcion;
  final int Estado;
  final int Categoria;

  Tareas({
    required this.Id,
    required this.Creador,
    required this.Destinatario,
    required this.Nombre,
    required this.Descripcion,
    required this.Estado,
    required this.Categoria,
  });
}

class ServicioTareas {
  final String _host = 'localhost:3000';
  // BUSCAR USUARIOS //
  Future<List<Tareas>> getTareas(int IdPerfil) async {
    http.Response response = await http.get(
      Uri.parse('http://$_host/tareas/getByUsuario?IdPerfil=$IdPerfil'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
      print(responseData);
      List<Tareas> tareas = responseData.map((data) {
        return Tareas(
            Id: data['Id'],
            Creador: data['Creador'],
            Destinatario: List<int>.from(jsonDecode(data['Destinatario'])),
            Nombre: data['Nombre'],
            Descripcion: data['Descripcion'],
            Estado: data['Estado'],
            Categoria: data['Categoria']);
      }).toList();
      return tareas;
    } else {
      throw Exception(
          'Error al obtener las tareas de un usuario'); // Lanzar una excepción en caso de error
    }
  }

  Future<Tareas?> getTareasById(int Id) async {
    print("Id = $Id");
    http.Response response = await http.get(
      Uri.parse('http://$_host/tareas/getById?Id=$Id'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
          'Respuesta de la API: $responseData'); // Imprimir respuesta para depuración

      // Acceder a los argumentos
      Map<String, dynamic> tareaData = responseData['arguments'];

      Tareas tarea = Tareas(
          Id: tareaData['Id'],
          Creador: tareaData['Creador'],
          Destinatario: List<int>.from(jsonDecode(tareaData['Destinatario'])),
          Nombre: tareaData['Nombre'],
          Descripcion: tareaData['Descripcion'],
          Estado: tareaData['Estado'],
          Categoria: tareaData['Categoria']);
      return tarea;
    } else {
      throw Exception(
          'Error al obtener la tarea por ID'); // Lanzar una excepción en caso de error
    }
  }

  // Registro de producto
  Future<bool> registrarTarea(int Creador, List<int> Destinatario,
      String Nombre, String Descripcion, int Estado, int Categoria) async {
    Map<String, dynamic> TareaData = {
      'Creador': Creador,
      'Destinatario': jsonEncode(Destinatario).toString(),
      'Nombre': Nombre.toString(),
      'Descripcion': Descripcion.toString(),
      'Estado': Estado,
      'Categoria': Categoria,
    };

    http.Response response1 = await http.post(
      Uri.parse('http://$_host/tareas/create'),
      headers: {'Content-type': 'application/json'},
      body: json.encode(TareaData),
    );
    if (response1.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> actualizarTarea(int Id, int Creador, List<int> Destinatario,
      String Nombre, String Descripcion, int Estado, int Categoria) async {
    final response = await http.put(
      Uri.parse('http://$_host/tareas/update'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Id': Id,
        'Creador': Creador,
        'Destinatario': jsonEncode(Destinatario).toString(),
        'Nombre': Nombre.toString(),
        'Descripcion': Descripcion.toString(),
        'Estado': Estado,
        'Categoria': Categoria,
      }),
    );

    if (response.statusCode == 200) {
      return true; // La actualización fue exitosa
    } else {
      // Manejo de errores
      print('Error al actualizar la tarea: ${response.statusCode}');
      return false; // La actualización falló
    }
  }

  Future<bool> eliminarTarea(int IdTarea) async {
    try {
      final response = await http.delete(
        Uri.parse('http://$_host/tarea/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'IdTarea': IdTarea}), // Enviamos el ID en el cuerpo
      );

      if (response.statusCode == 200) {
        print('Tarea eliminada con éxito');
        return true;
      } else {
        print('Error al eliminar la tarea: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al enviar solicitud de eliminación de la tarea: $e');
      return false;
    }
  }
}
