// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:famsync/Error_Conexion.dart';

class Tareas {
  final int Id;
  final int Creador;
  final List<int> Destinatario;
  final String Nombre;
  final String Descripcion;
  final int Categoria;
  final int? IdEvento;
  final int Prioridad;
  final int Progreso;

  Tareas({
    required this.Id,
    required this.Creador,
    required this.Destinatario,
    required this.Nombre,
    required this.Descripcion,
    required this.Categoria,
    required this.IdEvento,
    required this.Prioridad,
    required this.Progreso,
  });
}

class ServicioTareas {
  final String _host = Host.host;

  // Obtener tareas por perfil
  Future<List<Tareas>> getTareas(BuildContext context, int IdPerfil) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/tareas/getByUsuario?IdPerfil=$IdPerfil'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Tareas(
          Id: data['Id'],
          Creador: data['Creador'],
          Destinatario: List<int>.from(jsonDecode(data['Destinatario'])),
          Nombre: data['Nombre'],
          Descripcion: data['Descripcion'],
          Categoria: data['Categoria'],
          IdEvento: data['IdEvento'],
          Prioridad: data['Prioridad'],
          Progreso: data['Progreso'],
        );
      }).toList();
    } else {
      throw Exception('Error al obtener las tareas de un usuario');
    }
  }

  // Obtener tarea por ID
  Future<Tareas?> getTareasById(BuildContext context, int Id) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/tareas/getById?Id=$Id'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> tareaData = responseData['arguments'];

      return Tareas(
        Id: tareaData['Id'],
        Creador: tareaData['Creador'],
        Destinatario: List<int>.from(jsonDecode(tareaData['Destinatario'])),
        Nombre: tareaData['Nombre'],
        Descripcion: tareaData['Descripcion'],
        Categoria: tareaData['Categoria'],
        IdEvento: tareaData['IdEvento'],
        Prioridad: tareaData['Prioridad'],
        Progreso: tareaData['Progreso'],
      );
    } else {
      throw Exception('Error al obtener la tarea por ID');
    }
  }

  // Registrar tarea
  Future<bool> registrarTarea(
      BuildContext context,
      int Creador,
      List<int> Destinatario,
      String Nombre,
      String Descripcion,
      int? IdEvento,
      int Categoria,
      int Prioridad,
      int Progreso) async {
    Map<String, dynamic> TareaData = {
      'Creador': Creador,
      'Destinatario': jsonEncode(Destinatario).toString(),
      'Nombre': Nombre.toString(),
      'Descripcion': Descripcion.toString(),
      'Categoria': Categoria,
      'IdEvento': IdEvento,
      'Prioridad': Prioridad,
      'Progreso': Progreso,
    };

    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/tareas/create'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(TareaData),
      ),
    );

    return response.statusCode == 200;
  }

  // Actualizar tarea
  Future<bool> actualizarTarea(
      BuildContext context,
      int Id,
      int Creador,
      List<int> Destinatario,
      String Nombre,
      String Descripcion,
      int IdEvento,
      int Categoria,
      int Prioridad,
      int Progreso) async {
    final response = await HttpService.execute(
      context,
      () => http.put(
        Uri.parse('http://$_host/tareas/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Id': Id,
          'Creador': Creador,
          'Destinatario': jsonEncode(Destinatario).toString(),
          'Nombre': Nombre.toString(),
          'Descripcion': Descripcion.toString(),
          'Categoria': Categoria,
          'IdEvento': IdEvento,
          'Prioridad': Prioridad,
          'Progreso': Progreso,
        }),
      ),
    );

    return response.statusCode == 200;
  }

  // Eliminar tarea
  Future<bool> eliminarTarea(BuildContext context, int IdTarea) async {
    final response = await HttpService.execute(
      context,
      () => http.delete(
        Uri.parse('http://$_host/tareas/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'IdTarea': IdTarea}),
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
