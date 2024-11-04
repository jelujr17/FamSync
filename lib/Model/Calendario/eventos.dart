// ignore_for_file: avoid_print, non_constant_identifier_names
 
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
  final List<int> Visible;
  final int IdCategoria;

  Eventos(
      {required this.Id,
      required this.Nombre,
      required this.Descripcion,
      required this.FechaInicio,
      required this.FechaFin,
      required this.IdUsuarioCreador,
      required this.IdPerfilCreador,
      required this.Visible,
      required this.IdCategoria});
}

class ServicioEventos {
  final String _host = 'localhost:3000';
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
            Visible: List<int>.from(jsonDecode(data['Visible'])),
            IdCategoria: data['IdCategoria']);
      }).toList();
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
          Visible: List<int>.from(jsonDecode(eventoData['Visible'])),
          IdCategoria: eventoData['IdCategoria']);
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
      List<int> Visible,
      int IdCategoria) async {
    Visible.add(IdPerfilCreador);
    Map<String, dynamic> EventoData = {
      'Nombre': Nombre.toString(),
      'Descripcion': Descripcion.toString(),
      'FechaInicio': FechaInicio.toString(),
      'FechaFin': FechaFin.toString(),
      'IdPerfilCreador': IdPerfilCreador,
      'IdUsuarioCreador': IdUsuarioCreador,
      'Visible': jsonEncode(Visible).toString(),
      'IdCategoria': IdCategoria
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
      List<int> Visible,
      int IdCategoria) async {
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
        'Visible': jsonEncode(Visible).toString(),
        'IdCategoria': IdCategoria
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
}
