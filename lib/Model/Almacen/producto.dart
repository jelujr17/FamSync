// ignore_for_file: avoid_print, non_constant_identifier_names
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

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
  // Datos estáticos para simular respuestas de la API
  final List<Productos> _productosEstaticos = [
    Productos(
      Id: 1,
      Nombre: "Leche Entera",
      Imagenes: ["leche1.jpg", "leche2.jpg"],
      Tienda: "Supermercado Central",
      Precio: 25.50,
      IdPerfilCreador: 1,
      IdUsuarioCreador: 1,
      Visible: [1, 2],
    ),
    Productos(
      Id: 2,
      Nombre: "Pan Integral",
      Imagenes: ["pan1.jpg"],
      Tienda: "Mercado Local",
      Precio: 18.75,
      IdPerfilCreador: 1,
      IdUsuarioCreador: 1,
      Visible: [1],
    ),
    Productos(
      Id: 3,
      Nombre: "Detergente Multiusos",
      Imagenes: ["detergente1.jpg", "detergente2.jpg", "detergente3.jpg"],
      Tienda: "Tienda de Conveniencia",
      Precio: 45.99,
      IdPerfilCreador: 1,
      IdUsuarioCreador: 1,
      Visible: [1, 2, 3],
    ),
    Productos(
      Id: 4,
      Nombre: "Pasta Dental",
      Imagenes: ["pasta1.jpg"],
      Tienda: "Farmacia",
      Precio: 32.00,
      IdPerfilCreador: 2,
      IdUsuarioCreador: 1,
      Visible: [1, 2],
    ),
    Productos(
      Id: 5,
      Nombre: "Jugo de Naranja",
      Imagenes: ["jugo1.jpg", "jugo2.jpg"],
      Tienda: "Supermercado Central",
      Precio: 29.99,
      IdPerfilCreador: 1,
      IdUsuarioCreador: 1,
      Visible: [1, 2],
    ),
    Productos(
      Id: 6,
      Nombre: "Martillo",
      Imagenes: ["martillo1.jpg"],
      Tienda: "Ferretería",
      Precio: 120.50,
      IdPerfilCreador: 3,
      IdUsuarioCreador: 2,
      Visible: [3],
    ),
    Productos(
      Id: 7,
      Nombre: "Cuaderno",
      Imagenes: ["cuaderno1.jpg", "cuaderno2.jpg"],
      Tienda: "Tienda Online",
      Precio: 15.00,
      IdPerfilCreador: 3,
      IdUsuarioCreador: 2,
      Visible: [3],
    ),
  ];

  // Obtener productos por usuario y perfil
  Future<List<Productos>> getProductos(
      BuildContext context, int IdUsuarioCreador, int IdPerfil) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 600));

    return _productosEstaticos
        .where((producto) =>
            producto.IdUsuarioCreador == IdUsuarioCreador &&
            producto.Visible.contains(IdPerfil))
        .toList();
  }

  // Obtener producto por ID
  Future<Productos?> getProductoById(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _productosEstaticos.firstWhere((producto) => producto.Id == Id);
    } catch (e) {
      return null; // Si no encuentra el producto
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
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 1000));

    List<String> nombresImagenes = [];

    // Simular procesamiento de imágenes
    if (Imagenes != null) {
      for (int i = 0; i < Imagenes.length; i++) {
        // Generar un nombre único para la imagen
        final nombreImagen =
            'producto_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        nombresImagenes.add(nombreImagen);
        print('Imagen procesada: $nombreImagen');
      }
    }

    // Asegurarse que el perfil creador esté en la lista de visibles
    if (!Visible.contains(IdPerfilCreador)) {
      Visible.add(IdPerfilCreador);
    }

    // Simular ID generado para el nuevo producto
    final nuevoId = _productosEstaticos.isNotEmpty
        ? _productosEstaticos.map((p) => p.Id).reduce((a, b) => a > b ? a : b) +
            1
        : 1;

    // Crear el nuevo producto
    final nuevoProducto = Productos(
      Id: nuevoId,
      Nombre: Nombre,
      Imagenes: nombresImagenes,
      Tienda: Tienda,
      Precio: Precio,
      IdPerfilCreador: IdPerfilCreador,
      IdUsuarioCreador: IdUsuarioCreador,
      Visible: Visible,
    );

    // Añadir el producto a la lista estática
    _productosEstaticos.add(nuevoProducto);

    print('Producto registrado con ID: $nuevoId');
    return true;
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
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Buscar índice del producto a actualizar
    final index = _productosEstaticos.indexWhere((p) => p.Id == Id);
    if (index == -1) {
      return false; // No se encontró el producto
    }

    // Simular procesamiento de nuevas imágenes
    for (int i = 0; i < Imagenes.length; i++) {
      // Generar un nombre único para la imagen
      final nombreImagen =
          'producto_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      imagnesExistentes.add(nombreImagen);
      print('Nueva imagen procesada: $nombreImagen');
    }

    // Crear el producto actualizado
    final productoActualizado = Productos(
      Id: Id,
      Nombre: Nombre,
      Imagenes: imagnesExistentes,
      Tienda: Tienda,
      Precio: Precio,
      IdPerfilCreador: _productosEstaticos[index].IdPerfilCreador,
      IdUsuarioCreador: _productosEstaticos[index].IdUsuarioCreador,
      Visible: Visible,
    );

    // Actualizar el producto en la lista estática
    _productosEstaticos[index] = productoActualizado;

    print('Producto con ID $Id actualizado');
    return true;
  }

  // Eliminar producto
  Future<bool> eliminarProducto(BuildContext context, int idProducto) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Buscar índice del producto a eliminar
    final index = _productosEstaticos.indexWhere((p) => p.Id == idProducto);
    if (index == -1) {
      return false; // No se encontró el producto
    }

    // Eliminar el producto de la lista estática
    _productosEstaticos.removeAt(index);

    print('Producto con ID $idProducto eliminado');
    return true;
  }

  // Obtener imagen
  Future<File> obtenerImagen(BuildContext context, String nombre) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      // Obtener el directorio temporal del dispositivo
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$nombre';
      final file = File(filePath);

      // Crear un archivo vacío si no existe
      if (!file.existsSync()) {
        await file.create();
        // Aquí podrías escribir bytes de una imagen por defecto si lo necesitas
        print("Imagen creada como archivo vacío: $filePath");
      }

      return file;
    } catch (e) {
      print('Error al crear archivo temporal: $e');
      // En caso de error, crear un archivo temporal genérico
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/default_image.jpg');
      await file.create();
      return file;
    }
  }
}

// Servicio global para manejar errores de conexión (versión simulada)
class HttpService {
  static Future<http.Response> execute(
    BuildContext context,
    Future<http.Response> Function() httpCall,
  ) async {
    try {
      // Simular una respuesta HTTP exitosa
      final headers = {'content-type': 'application/json'};
      final body = utf8.encode(json.encode({'status': 'success'}));

      return http.Response.bytes(body, 200, headers: headers);
    } catch (e) {
      print('Error simulado en HttpService: $e');
      // Comentado para evitar navegación no deseada durante pruebas
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const NoconnectionScreen()),
      // );
      throw Exception('Error simulado en la conexión con la base de datos');
    }
  }
}
