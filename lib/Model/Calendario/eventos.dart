// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Eventos(
      {required this.Id,
      required this.Nombre,
      required this.Descripcion,
      required this.FechaInicio,
      required this.FechaFin,
      required this.IdUsuarioCreador,
      required this.IdPerfilCreador,
      required this.IdCategoria,
      required this.Participantes,
      required this.IdTarea});
}

class ServicioEventos {
  final String _host = Host.host;
  // BUSCAR USUARIOS //
  Future<List<Eventos>> getEventos(int IdUsuarioCreador, int IdPerfil) async {
    http.Response response = await http.get(
      Uri.parse(
          'http://$_host/eventos/getByUsuario?IdUsuarioCreador=$IdUsuarioCreador&IdPerfil=$IdPerfil'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
      print(responseData);
      List<Eventos> eventos = responseData.map((data) {
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
            IdTarea: data['IdTarea']);
      }).toList();
      return eventos;
    } else {
      throw Exception(
          'Error al obtener los productos de un usuario'); // Lanzar una excepción en caso de error
    }
  }

  Future<List<Eventos>> getEventosDiarios(
      int IdUsuarioCreador, int IdPerfil) async {
    http.Response response = await http.get(
      Uri.parse(
          'http://$_host/eventos/getByUsuarioDiario?IdUsuarioCreador=$IdUsuarioCreador&IdPerfil=$IdPerfil'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
      print(responseData);
      List<Eventos> eventos = responseData.map((data) {
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
            IdTarea: data['IdTarea']);
      }).toList();
      print('------------------------------------${eventos.length}');
      return eventos;
    } else {
      throw Exception(
          'Error al obtener los productos de un usuario'); // Lanzar una excepción en caso de error
    }
  }

  Future<Eventos?> getEventoById(int Id) async {
    print("Id = $Id");
    http.Response response = await http.get(
      Uri.parse('http://$_host/eventos/getById?Id=$Id'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
          'Respuesta de la API: $responseData'); // Imprimir respuesta para depuración

      // Acceder a los argumentos
      Map<String, dynamic> eventoData = responseData['arguments'];

      Eventos evento = Eventos(
          Id: eventoData['Id'],
          Nombre: eventoData['Nombre'],
          Descripcion: eventoData['Descripcion'],
          FechaInicio: eventoData['FechaInicio'],
          FechaFin: eventoData['FechaFin'],
          IdUsuarioCreador: eventoData['IdUsuarioCreador'],
          IdPerfilCreador: eventoData['IdPerfilCreador'],
          IdCategoria: eventoData['IdCategoria'],
          Participantes: eventoData['Participantes'],
          IdTarea: eventoData['IdTarea']);
      return evento;
    } else {
      throw Exception(
          'Error al obtener el evento por ID'); // Lanzar una excepción en caso de error
    }
  }

  // Registro de producto
  Future<bool> registrarEvento(
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
      'Participantes': jsonEncode(Participantes).toString()
    };

    http.Response response1 = await http.post(
      Uri.parse('http://$_host/eventos/create'),
      headers: {'Content-type': 'application/json'},
      body: json.encode(EventoData),
    );
    if (response1.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> actualizarEvento(
      int Id,
      String Nombre,
      String Descripcion,
      DateTime FechaInicio,
      DateTime FechaFin,
      int IdUsuarioCreador,
      int IdPerfilCreador,
      int IdCategoria,
      List<int> Participantes) async {
    final response = await http.put(
      Uri.parse('http://$_host/eventos/update'),
      headers: {
        'Content-Type': 'application/json',
      },
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
    );

    if (response.statusCode == 200) {
      return true; // La actualización fue exitosa
    } else {
      // Manejo de errores
      print('Error al actualizar el evento: ${response.statusCode}');
      return false; // La actualización falló
    }
  }

  // Función para eliminar la foto anterior
  Future<bool> eliminarEvento(int idEvento) async {
    try {
      final response = await http.delete(
        Uri.parse('http://$_host/eventos/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'IdEvento': idEvento}), // Enviamos el ID en el cuerpo
      );

      if (response.statusCode == 200) {
        print('Evento eliminado con éxito');
        return true;
      } else {
        print('Error al eliminar el evento: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al enviar solicitud de eliminación de evento: $e');
      return false;
    }
  }
}
