// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:famsync/Error_Conexion.dart';

class Listas {
  final int Id;
  final String Nombre;
  final int IdPerfil;
  final int IdUsuario;
  final List<int> Visible;
  final List<int> Productos;

  Listas({
    required this.Id,
    required this.Nombre,
    required this.IdPerfil,
    required this.IdUsuario,
    required this.Visible,
    required this.Productos,
  });
}

class ServiciosListas {
  final String _host = Host.host;

  // Obtener listas por usuario y perfil
  Future<List<Listas>> getListas(
      BuildContext context, int IdUsuario, int IdPerfil) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse(
            'http://$_host/listas/getByUsuario?IdUsuario=$IdUsuario&IdPerfil=$IdPerfil'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Listas(
          Id: data['Id'],
          Nombre: data['Nombre'],
          IdUsuario: data['IdUsuario'],
          IdPerfil: data['IdPerfil'],
          Visible: List<int>.from(jsonDecode(data['Visible'])),
          Productos: List<int>.from(jsonDecode(data['Productos'])),
        );
      }).toList();
    } else {
      throw Exception('Error al obtener las listas de un usuario');
    }
  }

  // Obtener lista por ID
  Future<Listas?> getListasById(BuildContext context, int Id) async {
    print("Id = $Id");
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/listas/getById?Id=$Id'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print('Respuesta de la API: $responseData');

      Map<String, dynamic> listaData = responseData['arguments'];

      return Listas(
        Id: listaData['Id'],
        Nombre: listaData['Nombre'],
        IdPerfil: listaData['IdPerfilCreador'],
        IdUsuario: listaData['IdUsuarioCreador'],
        Visible: List<int>.from(jsonDecode(listaData['Visible'])),
        Productos: List<int>.from(jsonDecode(listaData['Productos'])),
      );
    } else {
      throw Exception('Error al obtener la lista por ID');
    }
  }

  // Incluir producto en una lista
  Future<bool> incluirProducto(
      BuildContext context, Productos producto, Listas lista) async {
    List<int> productos = lista.Productos;
    if (productos.contains(producto.Id)) {
      return false;
    } else {
      productos.add(producto.Id);
    }

    final response = await HttpService.execute(
      context,
      () => http.put(
        Uri.parse('http://$_host/listas/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Id': lista.Id,
          'Nombre': lista.Nombre.toString(),
          'Visible': jsonEncode(lista.Visible),
          'Productos': jsonEncode(productos),
        }),
      ),
    );

    return response.statusCode == 200;
  }

  // Registrar una nueva lista
  Future<bool> registrarLista(BuildContext context, String Nombre, int IdPerfil,
      int IdUsuario, List<int> Visible) async {
    Visible.add(IdPerfil);

    Map<String, dynamic> ListaData = {
      'Nombre': Nombre.toString(),
      'IdUsuario': IdUsuario,
      'IdPerfil': IdPerfil,
      'Visible': jsonEncode(Visible).toString(),
      'Productos': jsonEncode([]).toString(),
    };

    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/listas/create'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(ListaData),
      ),
    );

    return response.statusCode == 200;
  }

  // Actualizar una lista
  Future<bool> actualizarLista(BuildContext context, int Id, String Nombre,
      List<int> Visible, List<int> Productos) async {
    final response = await HttpService.execute(
      context,
      () => http.put(
        Uri.parse('http://$_host/listas/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Id': Id,
          'Nombre': Nombre.toString(),
          'Visible': jsonEncode(Visible),
          'Productos': jsonEncode(Productos),
        }),
      ),
    );

    return response.statusCode == 200;
  }

  // Eliminar una lista
  Future<bool> eliminarLista(BuildContext context, int idLista) async {
    final response = await HttpService.execute(
      context,
      () => http.delete(
        Uri.parse('http://$_host/listas/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'IdLista': idLista}),
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
