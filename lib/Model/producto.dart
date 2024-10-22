// ignore_for_file: avoid_print, non_constant_identifier_names
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

// CLASES DE PERSONAS REALES
class Productos {
  final int Id;
  final String Nombre;
  final List<String> Imagenes;
  final String Tienda;
  final double Precio;
  final int IdPerfilCreador;
  final int IdUsuarioCreador;
  final List<int> Visible;

  Productos(
      {required this.Id,
      required this.Nombre,
      required this.Imagenes,
      required this.Tienda,
      required this.Precio,
      required this.IdPerfilCreador,
      required this.IdUsuarioCreador,
      required this.Visible});
}

class ServicioProductos {
  final String _host = 'localhost:3000';
  // BUSCAR USUARIOS //
  Future<List<Productos>> getProductos(
      int IdUsuarioCreador, int IdPerfil) async {
    http.Response response = await http.get(
      Uri.parse(
          'http://$_host/productos/getByUsuario?IdUsuarioCreador=$IdUsuarioCreador&IdPerfil=$IdPerfil'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseData =
          jsonDecode(response.body); // Parsear la respuesta JSON
      print(responseData);
      List<Productos> productos = responseData.map((data) {
        return Productos(
          Id: data['Id'],
          Nombre: data['Nombre'],
          Imagenes: List<String>.from(jsonDecode(
              data['Imagenes'])), // Desanidar y convertir a List<String>
          Tienda: data['Tienda'],
          Precio: double.parse(data['Precio'].toString()), // Ajustado aquí
          IdPerfilCreador: data['IdPerfilCreador'],
          IdUsuarioCreador: data['IdUsuarioCreador'],
          Visible: List<int>.from(jsonDecode(data[
              'Visible'])), // Asegúrate de que esto también se convierte correctamente
        );
      }).toList();
      return productos;
    } else {
      throw Exception(
          'Error al obtener los productos de un usuario'); // Lanzar una excepción en caso de error
    }
  }

  Future<Productos?> getProductoById(int Id) async {
    print("Id = $Id");
    http.Response response = await http.get(
      Uri.parse('http://$_host/productos/getById?Id=$Id'),
      headers: {'Content-type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
          'Respuesta de la API: $responseData'); // Imprimir respuesta para depuración

      // Acceder a los argumentos
      Map<String, dynamic> productoData = responseData['arguments'];

      Productos producto = Productos(
        Id: productoData['Id'],
        Nombre: productoData['Nombre'],
        Imagenes: List<String>.from(
            productoData['Imagenes']), // Desanidar y convertir a List<String>
        Tienda: productoData['Tienda'],
        Precio: double.parse(productoData['Precio']),
        IdPerfilCreador: productoData['IdPerfilCreador'],
        IdUsuarioCreador: productoData['IdUsuarioCreador'],
        Visible: List<int>.from(jsonDecode(productoData['Visible'])),
      );
      return producto;
    } else {
      throw Exception(
          'Error al obtener el producto por ID'); // Lanzar una excepción en caso de error
    }
  }

  // Registro de producto
  Future<bool> registrarProducto(
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
        // Paso 2: Adjuntar el archivo a la solicitud
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagen',
            Imagenes[i].path,
          ),
        );
        // Envía la solicitud y maneja la respuesta
        String nombre = "error";
        try {
          final response = await request.send();
          final responseBody = await response.stream.bytesToString();

          if (response.statusCode == 200) {
            // La solicitud se completó con éxito
            print('Solicitud completada con éxito');

            // Lee el cuerpo de la respuesta como una cadena
            print('Cuerpo de la respuesta: $responseBody');
            nombre = responseBody;
          } else {
            // Error en la solicitud
            print('Error en la solicitud: ${responseBody.toString()}');
          }
        } catch (e) {
          // Error al enviar la solicitud
          print('Error al enviar la solicitud: $e');
        }

        Map<String, dynamic> jsonMap = json.decode(nombre);
        String imageUrl = jsonMap['imageUrl'];
        NombresImagnes.add(imageUrl);
      }
    }
    Visible.add(IdPerfilCreador);
    // Paso 3: Guardar el producto en la base de datos con la URL de la imagen
    Map<String, dynamic> ProductoData = {
      'Nombre': Nombre.toString(),
      'Imagenes': jsonEncode(NombresImagnes),
      'Tienda': Tienda.toString(),
      'Precio': Precio,
      'IdPerfilCreador': IdPerfilCreador,
      'IdUsuarioCreador': IdUsuarioCreador,
      'Visible': jsonEncode(Visible).toString(),
    };

    http.Response response1 = await http.post(
      Uri.parse('http://$_host/productos/create'),
      headers: {'Content-type': 'application/json'},
      body: json.encode(ProductoData),
    );
    if (response1.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> editarProducto(int Id, String Nombre, List<File> Imagenes,
      String Tienda, double Precio, List<int> Visible) async {
    List<String> NombresImagnes = [];
    for (int i = 0; i < Imagenes.length; i++) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$_host/productos/uploadImagen'),
      );

      // Paso 2: Adjuntar el archivo a la solicitud
      request.files.add(
        await http.MultipartFile.fromPath(
          'imagen',
          Imagenes[i].path,
        ),
      );
      // Envía la solicitud y maneja la respuesta
      String nombre = "error";
      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          // La solicitud se completó con éxito
          print('Solicitud completada con éxito');

          // Lee el cuerpo de la respuesta como una cadena
          print('Cuerpo de la respuesta: $responseBody');
          nombre = responseBody;
        } else {
          // Error en la solicitud
          print('Error en la solicitud: ${responseBody.toString()}');
        }
      } catch (e) {
        // Error al enviar la solicitud
        print('Error al enviar la solicitud: $e');
      }

      Map<String, dynamic> jsonMap = json.decode(nombre);
      String imageUrl = jsonMap['imageUrl'];
      NombresImagnes.add(imageUrl);
    }

    // Paso 3: Guardar el producto en la base de datos con la URL de la imagen
    Map<String, dynamic> ProductoData = {
      'Id': Id,
      'Nombre': Nombre.toString(),
      'Imagenes': NombresImagnes,
      'Tienda': Tienda.toString(),
      'Precio': Precio,
      'Visible': Visible,
    };
    try {
      http.Response response1 = await http.post(
        Uri.parse('http://$_host/productos/update'),
        headers: {'Content-type': 'application/json'},
        body: json.encode(ProductoData),
      );

      return response1.statusCode == 200;
    } catch (e) {
      print('Error al actualizar el producto: $e');
      return false;
    }
  }

// Función para eliminar la foto anterior
  Future<void> eliminarFotoAnterior(String fotoUrl) async {
    // Aquí haces la lógica para eliminar la imagen del servidor o sistema de archivos
    try {
      final response = await http.get(
        Uri.parse('http://$_host/perfiles/eliminarImagen?urlImagen=$fotoUrl'),
        headers: {'Content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Foto anterior eliminada con éxito');
      } else {
        print('Error al eliminar la foto anterior: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar solicitud de eliminación de imagen: $e');
    }
  }

  Future<bool> eliminarProducto(int idProducto) async {
    try {
      final response = await http.delete(
        Uri.parse('http://$_host/productos/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'IdProducto': idProducto}), // Enviamos el ID en el cuerpo
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

  Future<File> obtenerImagen(String nombre) async {
    Map<String, dynamic> data = {"fileName": nombre};
    // Realizar la solicitud al servidor
    final response = await http.post(
      Uri.parse('http://$_host/productos/receiveFile'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode(data),
    );
    // Verificar si la solicitud fue exitosa
    if (response.statusCode == 200) {
      // Guardar el contenido de la respuesta en un archivo temporal
      const tempDir =
          'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Productos\\';
      final filePath =
          '$tempDir/$nombre'; // Puedes usar un nombre de archivo específico si lo deseas
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print("imagen encontrada");
      return file; // Devolver el archivo creado
    } else {
      print("imagen no encontrada");
      // Si hay un error en la solicitud, lanzar una excepción
      throw Exception('Error al obtener el archivo: ${response.statusCode}');
    }
  }
}
