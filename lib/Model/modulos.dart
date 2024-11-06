// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';

// CLASES DE PERSONAS REALES
class Modulos {
  final int Id;
  final String Nombre;
  final String Descripcion;

  Modulos({
    required this.Id,
    required this.Nombre,
    required this.Descripcion,
  });
}

class ServiciosModulos {
  final String _host = 'localhost:3000';
  // BUSCAR USUARIOS //
  Future<List<Modulos>> getModulos() async {
    http.Response response =
        await http.get(Uri.parse('http://$_host/modulos/get'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
      print(responseData);
      List<Modulos> modulos = responseData
          .map((data) => Modulos(
                Id: data['Id'],
                Nombre: data['Nombre'],
                Descripcion: data['Descripcion'],
              ))
          .toList();
      return modulos;
    } else {
      throw Exception(
          'Error al obtener los modulos'); // Lanzar una excepción en caso de error
    }
  }

  Future<Modulos?> getModulosById(int Id) async {
    print("Id = $Id");
    http.Response response = await http.get(
      Uri.parse('http://$_host/modulos/getById?Id=$Id'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
          'Respuesta de la API: $responseData'); // Imprimir respuesta para depuración

      // Acceder a los argumentos
      Map<String, dynamic> modulosData = responseData['arguments'];

      Modulos categoria = Modulos(
          Id: modulosData['Id'],
          Nombre: modulosData['Nombre'],
          Descripcion: modulosData['Descripcion']);
      return categoria;
    } else {
      throw Exception(
          'Error al obtener el modulo por ID'); // Lanzar una excepción en caso de error
    }
  }
}
