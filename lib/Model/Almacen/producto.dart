// ignore_for_file: avoid_print, non_constant_identifier_names
import 'dart:io';
import 'package:famsync/components/host.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Error_Conexion.dart';

// CLASES DE PRODUCTOS
class Productos {
  final int Id;
  final String Nombre;
  final List<String> Imagenes;
  final String Tienda;
  final double Precio;
  final int IdPerfilCreador;
  final int IdUsuarioCreador;
  final List<int> Visible;

  Productos({
    required this.Id,
    required this.Nombre,
    required this.Imagenes,
    required this.Tienda,
    required this.Precio,
    required this.IdPerfilCreador,
    required this.IdUsuarioCreador,
    required this.Visible,
  });
}

class ServicioProductos {
  final String _host = Host.host;

  // Obtener productos por usuario y perfil
  Future<List<Productos>> getProductos(
      BuildContext context, int IdUsuarioCreador, int IdPerfil) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse(
            'http://$_host/productos/getByUsuario?IdUsuarioCreador=$IdUsuarioCreador&IdPerfil=$IdPerfil'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) {
        return Productos(
          Id: data['Id'],
          Nombre: data['Nombre'],
          Imagenes: List<String>.from(jsonDecode(data['Imagenes'])),
          Tienda: data['Tienda'],
          Precio: double.parse(data['Precio'].toString()),
          IdPerfilCreador: data['IdPerfilCreador'],
          IdUsuarioCreador: data['IdUsuarioCreador'],
          Visible: List<int>.from(jsonDecode(data['Visible'])),
        );
      }).toList();
    } else {
      throw Exception('Error al obtener los productos de un usuario');
    }
  }

  // Obtener producto por ID
  Future<Productos?> getProductoById(BuildContext context, int Id) async {
    final response = await HttpService.execute(
      context,
      () => http.get(
        Uri.parse('http://$_host/productos/getById?Id=$Id'),
        headers: {'Content-type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> productoData = responseData['arguments'];

      return Productos(
        Id: productoData['Id'],
        Nombre: productoData['Nombre'],
        Imagenes: List<String>.from(jsonDecode(productoData['Imagenes'])),
        Tienda: productoData['Tienda'],
        Precio: double.parse(productoData['Precio'].toString()),
        IdPerfilCreador: productoData['IdPerfilCreador'],
        IdUsuarioCreador: productoData['IdUsuarioCreador'],
        Visible: List<int>.from(jsonDecode(productoData['Visible'])),
      );
    } else {
      throw Exception('Error al obtener el producto por ID');
    }
  }

  // Registrar producto
  Future<bool> registrarProducto(
      BuildContext context,
      String Nombre,
      List<File>? Imagenes,
      String Tienda,
      double Precio,
      int IdPerfilCreador,
      int IdUsuarioCreador,
      List<int> Visible) async {
    List<String> NombresImagnes = [];
    if (Imagenes != null) {
      for (int i = 0; i < Imagenes.length; i++) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://$_host/productos/uploadImagen'),
        );
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagen',
            Imagenes[i].path,
          ),
        );

        String nombre = "error";
        try {
          final response = await request.send();
          final responseBody = await response.stream.bytesToString();

          if (response.statusCode == 200) {
            nombre = responseBody;
          } else {
            print('Error en la solicitud: ${responseBody.toString()}');
          }
        } catch (e) {
          print('Error al enviar la solicitud: $e');
        }

        Map<String, dynamic> jsonMap = json.decode(nombre);
        String imageUrl = jsonMap['imageUrl'];
        NombresImagnes.add(imageUrl);
      }
    }
    Visible.add(IdPerfilCreador);

    Map<String, dynamic> ProductoData = {
      'Nombre': Nombre.toString(),
      'Imagenes': jsonEncode(NombresImagnes),
      'Tienda': Tienda.toString(),
      'Precio': Precio,
      'IdPerfilCreador': IdPerfilCreador,
      'IdUsuarioCreador': IdUsuarioCreador,
      'Visible': jsonEncode(Visible).toString(),
    };

    final response = await HttpService.execute(
      context,
      () => http.post(
        Uri.parse('http://$_host/productos/create'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(ProductoData),
      ),
    );

    return response.statusCode == 200;
  }

  // Actualizar producto
  Future<bool> actualizarProducto(
      BuildContext context,
      int Id,
      String Nombre,
      List<String> imagnesExistentes,
      List<File> Imagenes,
      String Tienda,
      double Precio,
      List<int> Visible) async {
    for (int i = 0; i < Imagenes.length; i++) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$_host/productos/uploadImagen'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'imagen',
          Imagenes[i].path,
        ),
      );

      String nombre = "error";
      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          nombre = responseBody;
        } else {
          print('Error en la solicitud: ${responseBody.toString()}');
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
      }

      Map<String, dynamic> jsonMap = json.decode(nombre);
      String imageUrl = jsonMap['imageUrl'];
      imagnesExistentes.add(imageUrl);
    }

    Map<String, dynamic> ProductoData = {
      'Id': Id,
      'Nombre': Nombre.toString(),
      'Imagenes': jsonEncode(imagnesExistentes),
      'Tienda': Tienda.toString(),
      'Precio': Precio,
      'Visible': jsonEncode(Visible),
    };

    final response = await HttpService.execute(
      context,
      () => http.put(
        Uri.parse('http://$_host/productos/update'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(ProductoData),
      ),
    );

    return response.statusCode == 200;
  }

  // Eliminar producto
  Future<bool> eliminarProducto(BuildContext context, int idProducto) async {
    final response = await HttpService.execute(
      context,
      () => http.delete(
        Uri.parse('http://$_host/productos/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'IdProducto': idProducto}),
      ),
    );

    return response.statusCode == 200;
  }

  // Obtener imagen
  Future<File> obtenerImagen(BuildContext context, String nombre) async {
    try {
      // Obtener el directorio temporal del dispositivo
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$nombre';
      final file = File(filePath);

      // Verificar si la imagen ya está guardada en caché
      if (await file.exists()) {
        print("Imagen cargada desde caché: $filePath");
        return file; // Retorna la imagen desde el almacenamiento temporal
      }

      // Si no existe en caché, hacer la solicitud al servidor
      Map<String, dynamic> data = {"fileName": nombre};
      final response = await http.post(
        Uri.parse('http://$_host/productos/receiveFile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print("Imagen descargada y guardada en caché: $filePath");
        return file; // Devuelve el archivo descargado
      } else {
        print("Imagen no encontrada en el servidor: ${response.statusCode}");
        throw Exception('Error al obtener el archivo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener la imagen: $e');
      throw Exception('No se pudo obtener la imagen.');
    }
  }
}

// Servicio global para manejar errores de conexión
class HttpService {
  static Future<http.Response> execute(
    BuildContext context,
    Future<http.Response> Function() httpCall,
  ) async {
    try {
      return await httpCall();
    } catch (e) {
      print('Error en la llamada HTTP: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoconnectionScreen()),
      );
      throw Exception('Error en la conexión con la base de datos');
    }
  }
}
