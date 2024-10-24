// ignore_for_file: avoid_print, non_constant_identifier_names

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
  final String _host = 'localhost:3000';
  // BUSCAR USUARIOS //
  Future<List<Tiendas>> getTiendas(int IdUsuario) async {
    http.Response response = await http.get(
      Uri.parse(
          'http://$_host/tiendas/getByUsuario?IdUsuario=$IdUsuario'),
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
          'Error al obtener las listas de un usuario'); // Lanzar una excepción en caso de error
    }
  }

  Future<Tiendas?> getTiendasById(int Id) async {
    print("Id = $Id");
    http.Response response = await http.get(
      Uri.parse('http://$_host/listas/getById?Id=$Id'),
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
          'Error al obtener la lista por ID'); // Lanzar una excepción en caso de error
    }
  }

  // Registro de producto
  Future<bool> registrarLista(
      String Nombre, int IdPerfil, int IdUsuario, List<int> Visible) async {
    Visible.add(IdPerfil);
    // Paso 3: Guardar el producto en la base de datos con la URL de la imagen
    Map<String, dynamic> ListaData = {
      'Nombre': Nombre.toString(),
      'IdUsuario': IdUsuario,
      'IdPerfil': IdPerfil,
      'Visible': jsonEncode(Visible).toString(),
      'Productos': jsonEncode(
        [],
      ).toString()
    };

    http.Response response1 = await http.post(
      Uri.parse('http://$_host/listas/create'),
      headers: {'Content-type': 'application/json'},
      body: json.encode(ListaData),
    );
    if (response1.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> actualizarLista(
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

  Future<bool> eliminarLista(int idLista) async {
    try {
      final response = await http.delete(
        Uri.parse('http://$_host/listas/delete'),
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode({'IdProducto': idLista}), // Enviamos el ID en el cuerpo
      );

      if (response.statusCode == 200) {
        print('Producto eliminado con éxito');
        return true;
      } else {
        print('Error al eliminar el producto: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al enviar solicitud de eliminación de producto: $e');
      return false;
    }
  }
}
