// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:famsync/Error_Conexion.dart';

class Eventos {
  final int Id;
  final String Nombre;
  final String Descripcion;
  final String FechaInicio;
  final String FechaFin;
  final int IdUsuarioCreador;
  final int IdPerfilCreador;
  final int IdCategoria;
  final List<int> Participantes;
  final int? IdTarea;

  Eventos({
    required this.Id,
    required this.Nombre,
    required this.Descripcion,
    required this.FechaInicio,
    required this.FechaFin,
    required this.IdUsuarioCreador,
    required this.IdPerfilCreador,
    required this.IdCategoria,
    required this.Participantes,
    required this.IdTarea,
  });
}

class ServicioEventos {
  final String _host = Host.host;

  // Obtener eventos por usuario y perfil
  Future<List<Eventos>> getEventos(
      BuildContext context, int IdUsuarioCreador, int IdPerfil) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse(
            'http://$_host/eventos/getByUsuario?IdUsuarioCreador=$IdUsuarioCreador&IdPerfil=$IdPerfil'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Eventos(
          Id: data['Id'],
          Nombre: data['Nombre'],
          Descripcion: data['Descripcion'],
          FechaInicio: data['FechaInicio'],
          FechaFin: data['FechaFin'],
          IdUsuarioCreador: data['IdUsuarioCreador'],
          IdPerfilCreador: data['IdPerfilCreador'],
          IdCategoria: data['IdCategoria'],
          Participantes: List<int>.from(jsonDecode(data['Participantes'])),
          IdTarea: data['IdTarea'],
        );
      }).toList();
    } else {
      throw Exception('Error al obtener los eventos de un usuario');
    }
  }

  // Obtener eventos diarios
  Future<List<Eventos>> getEventosDiarios(
      BuildContext context, int IdUsuarioCreador, int IdPerfil) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse(
            'http://$_host/eventos/getByUsuarioDiario?IdUsuarioCreador=$IdUsuarioCreador&IdPerfil=$IdPerfil'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Eventos(
          Id: data['Id'],
          Nombre: data['Nombre'],
          Descripcion: data['Descripcion'],
          FechaInicio: data['FechaInicio'],
          FechaFin: data['FechaFin'],
          IdUsuarioCreador: data['IdUsuarioCreador'],
          IdPerfilCreador: data['IdPerfilCreador'],
          IdCategoria: data['IdCategoria'],
          Participantes: List<int>.from(jsonDecode(data['Participantes'])),
          IdTarea: data['IdTarea'],
        );
      }).toList();
    } else {
      throw Exception('Error al obtener los eventos diarios');
    }
  }

  // Obtener evento por ID
  Future<Eventos?> getEventoById(BuildContext context, int Id) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/eventos/getById?Id=$Id'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> eventoData = responseData['arguments'];

      return Eventos(
        Id: eventoData['Id'],
        Nombre: eventoData['Nombre'],
        Descripcion: eventoData['Descripcion'],
        FechaInicio: eventoData['FechaInicio'],
        FechaFin: eventoData['FechaFin'],
        IdUsuarioCreador: eventoData['IdUsuarioCreador'],
        IdPerfilCreador: eventoData['IdPerfilCreador'],
        IdCategoria: eventoData['IdCategoria'],
        Participantes: List<int>.from(jsonDecode(eventoData['Participantes'])),
        IdTarea: eventoData['IdTarea'],
      );
    } else {
      throw Exception('Error al obtener el evento por ID');
    }
  }

  // Registrar evento
  Future<bool> registrarEvento(
      BuildContext context,
      String Nombre,
      String Descripcion,
      DateTime FechaInicio,
      DateTime FechaFin,
      int IdUsuarioCreador,
      int IdPerfilCreador,
      int IdCategoria,
      List<int> Participantes) async {
    Map<String, dynamic> EventoData = {
      'Nombre': Nombre.toString(),
      'Descripcion': Descripcion.toString(),
      'FechaInicio': FechaInicio.toString(),
      'FechaFin': FechaFin.toString(),
      'IdPerfilCreador': IdPerfilCreador,
      'IdUsuarioCreador': IdUsuarioCreador,
      'IdCategoria': IdCategoria,
      'Participantes': jsonEncode(Participantes).toString(),
    };

    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/eventos/create'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(EventoData),
      ),
    );

    return response.statusCode == 200;
  }

  // Actualizar evento
  Future<bool> actualizarEvento(
      BuildContext context,
      int Id,
      String Nombre,
      String Descripcion,
      DateTime FechaInicio,
      DateTime FechaFin,
      int IdUsuarioCreador,
      int IdPerfilCreador,
      int IdCategoria,
      List<int> Participantes) async {
    final response = await HttpService.execute(
      context,
      () => http.put(
        Uri.parse('http://$_host/eventos/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Id': Id,
          'Nombre': Nombre.toString(),
          'Descripcion': Descripcion.toString(),
          'FechaInicio': FechaInicio.toString(),
          'FechaFin': FechaFin.toString(),
          'IdPerfilCreador': IdPerfilCreador,
          'IdUsuarioCreador': IdUsuarioCreador,
          'IdCategoria': IdCategoria,
          'Participantes': jsonEncode(Participantes).toString(),
        }),
      ),
    );

    return response.statusCode == 200;
  }

  // Eliminar evento
  Future<bool> eliminarEvento(BuildContext context, int idEvento) async {
    final response = await HttpService.execute(
      context,
      () => http.delete(
        Uri.parse('http://$_host/eventos/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'IdEvento': idEvento}),
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
