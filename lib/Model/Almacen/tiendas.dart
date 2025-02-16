// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// CLASES DE PERSONAS REALES
class Tiendas {
  final int Id;
  final String Nombre;
  final int IdUsuario;

  Tiendas({
    required this.Id,
    required this.Nombre,
    required this.IdUsuario,
  });
}

class ServiciosTiendas {
  final String _host = Host.host;
  // BUSCAR USUARIOS //
  Future<List<Tiendas>> getTiendas(int IdUsuario) async {
    http.Response response = await http.get(
      Uri.parse('http://$_host/tiendas/getByUsuario?IdUsuario=$IdUsuario'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
      print(responseData);
      List<Tiendas> tiendas = responseData.map((data) {
        return Tiendas(
          Id: data['Id'],
          Nombre: data['Nombre'],
          IdUsuario: data['IdUsuario'],
        );
      }).toList();
      return tiendas;
    } else {
      throw Exception(
          'Error al obtener las tiendas de un usuario ${response.statusCode}'); // Lanzar una excepción en caso de error
    }
  }

  Future<Tiendas?> getTiendasById(int Id) async {
    print("Id = $Id");
    http.Response response = await http.get(
      Uri.parse('http://$_host/tiendas/getById?Id=$Id'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
          'Respuesta de la API: $responseData'); // Imprimir respuesta para depuración

      // Acceder a los argumentos
      Map<String, dynamic> tiendaData = responseData['arguments'];

      Tiendas tienda = Tiendas(
        Id: tiendaData['Id'],
        Nombre: tiendaData['Nombre'],
        IdUsuario: tiendaData['IdUsuarioCreador'],
      );
      return tienda;
    } else {
      throw Exception(
          'Error al obtener la tienda por ID'); // Lanzar una excepción en caso de error
    }
  }

  // Registro de producto
  Future<bool> registrarTienda(String Nombre, int IdUsuario) async {
    Map<String, dynamic> TiendaData = {
      'Nombre': Nombre.toString(),
      'IdUsuario': IdUsuario
    };

    http.Response response1 = await http.post(
      Uri.parse('http://$_host/tiendas/create'),
      headers: {'Content-type': 'application/json'},
      body: json.encode(TiendaData),
    );
    if (response1.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /*Future<bool> actualizarLista(
      int Id, String Nombre, List<int> Visible, List<int> Productos) async {
    final response = await http.put(
      Uri.parse('http://$_host/listas/update'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Id': Id,
        'Nombre': Nombre.toString(),
        'Visible': jsonEncode(Visible),
        'Productos': jsonEncode(Productos),
      }),
    );

    if (response.statusCode == 200) {
      return true; // La actualización fue exitosa
    } else {
      // Manejo de errores
      print('Error al actualizar la lista: ${response.statusCode}');
      return false; // La actualización falló
    }
  }
*/
  Future<bool> eliminarTienda(int IdTienda) async {
    try {
      final response = await http.delete(
        Uri.parse('http://$_host/tiendas/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Id': IdTienda}), // Enviamos el ID en el cuerpo
      );

      if (response.statusCode == 200) {
        print('Tienda eliminado con éxito');
        return true;
      } else {
        print('Error al eliminar la tienda: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al enviar solicitud de eliminación de la tienda: $e');
      return false;
    }
  }
}
