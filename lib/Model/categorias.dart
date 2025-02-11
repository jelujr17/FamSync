// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';

// CLASES DE PERSONAS REALES
class Categorias {
  final int Id;
  final int IdModulo;
  final String Color;
  final String Nombre;
  final int IdUsuario;

  Categorias({
    required this.Id,
    required this.IdModulo,
    required this.Color,
    required this.Nombre,
    required this.IdUsuario,
  });
}

class ServiciosCategorias {
  final String _host = '172.20.10.3:3000';
  // BUSCAR USUARIOS //
  Future<List<Categorias>> getCategorias(int IdUsuario) async {
    http.Response response = await http.get(
      Uri.parse('http://$_host/categorias/getByPerfil?IdUsuario=$IdUsuario'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
      print(responseData);
      List<Categorias> categorias = responseData.map((data) {
        return Categorias(
          Id: data['Id'],
          IdModulo: data['IdModulo'],
          Color: data['Color'],
          Nombre: data['Nombre'],
          IdUsuario: data['IdUsuario'],
        );
      }).toList();
      return categorias;
    } else {
      throw Exception(
          'Error al obtener las categorías de un perfil ${response.statusCode}'); // Lanzar una excepción en caso de error
    }
  }

  Future<List<Categorias>> getCategoriasByModulo(
      int IdUsuario, int IdModulo) async {
    http.Response response = await http.get(
      Uri.parse(
          'http://$_host/categorias/getByModulo?IdUsuario=$IdUsuario&IdModulo=$IdModulo'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
      print(responseData);
      List<Categorias> categorias = responseData.map((data) {
        return Categorias(
          Id: data['Id'],
          IdModulo: data['IdModulo'],
          Color: data['Color'],
          Nombre: data['Nombre'],
          IdUsuario: data['IdUsuario'],
        );
      }).toList();
      return categorias;
    } else {
      throw Exception(
          'Error al obtener las categorías de un perfil ${response.statusCode}'); // Lanzar una excepción en caso de error
    }
  }

  Future<Categorias?> getCategoriasById(int Id) async {
    print("Id = $Id");
    http.Response response = await http.get(
      Uri.parse('http://$_host/categorias/getById?Id=$Id'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
          'Respuesta de la API: $responseData'); // Imprimir respuesta para depuración

      // Acceder a los argumentos
      Map<String, dynamic> categoriaData = responseData['arguments'];

      Categorias categoria = Categorias(
          Id: categoriaData['Id'],
          IdModulo: categoriaData['IdModulo'],
          Nombre: categoriaData['Nombre'],
          Color: categoriaData['Color'],
          IdUsuario: categoriaData['IdUsuario']);
      return categoria;
    } else {
      throw Exception(
          'Error al obtener la categorá por ID'); // Lanzar una excepción en caso de error
    }
  }

  // Registro de producto
  Future<bool> registratCategoria(
      int IdModulo, String Nombre, String Color, int IdUsuario) async {
    Map<String, dynamic> CategoriaData = {
      'IdModulo': IdModulo,
      'Nombre': Nombre.toString(),
      'Color': Color.toString(),
      'IdUsuario': IdUsuario
    };

    http.Response response1 = await http.post(
      Uri.parse('http://$_host/categorias/create'),
      headers: {'Content-type': 'application/json'},
      body: json.encode(CategoriaData),
    );
    if (response1.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> eliminarCategoria(int Id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://$_host/categoria/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Id': Id}), // Enviamos el ID en el cuerpo
      );

      if (response.statusCode == 200) {
        print('Categoria eliminada con éxito');
        return true;
      } else {
        print('Error al eliminar la categoria: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al enviar solicitud de eliminación de la categoria: $e');
      return false;
    }
  }
}
