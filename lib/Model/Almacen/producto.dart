// ignore_for_file: avoid_print, non_constant_identifier_names
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// CLASES DE PRODUCTOS
class Productos {
  final String ProductoID;
  final String nombre;
  final List<String> imagenes;
  final String TiendaID;
  final double precio;
  final String PerfilID;
  final List<String> visible;

  Productos({
    required this.ProductoID,
    required this.nombre,
    required this.imagenes,
    required this.TiendaID,
    required this.precio,
    required this.PerfilID,
    required this.visible,
  });

  factory Productos.fromMap(String id, Map<String, dynamic> data) {
    return Productos(
      ProductoID: id,
      nombre: data['nombre'] ?? '',
      imagenes: List<String>.from(data['imagenes'] ?? []),
      TiendaID: data['TiendaID'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      PerfilID: data['PerfilID'] ?? '',
      visible: List<String>.from(data['visible'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'imagenes': imagenes,
      'TiendaID': TiendaID,
      'precio': precio,
      'PerfilID': PerfilID,
      'visible': visible,
    };
  }
}

class ServicioProductos {
  // Obtener productos por usuario y perfil
  Future<List<Productos>> getProductos(String UID, String PerfilID) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('productos')
          .where('visible', arrayContains: PerfilID)
          .get();

      return snapshot.docs
          .map((doc) => Productos.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener productos: $e');
      return [];
    }
  }

  // Obtener producto por ID
  Future<Productos?> getProductoById(String UID, String ProductoID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('productos')
          .doc(ProductoID)
          .get();

      if (doc.exists) {
        return Productos.fromMap(doc.id, doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener producto: $e');
      return null;
    }
  }

  // Registrar producto
  Future<bool> registrarProducto(
      String nombre,
      List<File>? imagenes,
      String TiendaID,
      double precio,
      String PerfilID,
      String UID,
      List<String> visible) async {
    if (nombre.trim().isEmpty) {
      print('El nombre del producto no puede estar vacío');
      return false;
    }
    if (precio <= 0) {
      print('El precio debe ser mayor que 0');
      return false;
    }
    if (TiendaID.trim().isEmpty) {
      print('El TiendaID no puede estar vacío');
      return false;
    }
    if (PerfilID.trim().isEmpty) {
      print('El PerfilID no puede estar vacío');
      return false;
    }
    if (imagenes == null || imagenes.isEmpty) {
      print('Debes subir al menos una imagen');
      return false;
    }
    try {
      List<String> urlsImagenes = [];
      for (var imagen in imagenes) {
        final ref = FirebaseStorage.instance.ref().child(
            'productos/$UID/${DateTime.now().millisecondsSinceEpoch}_${imagen.path.split('/').last}');
        await ref.putFile(imagen);
        final url = await ref.getDownloadURL();
        urlsImagenes.add(url);
      }

      final nuevoProducto = {
        'nombre': nombre,
        'imagenes': urlsImagenes,
        'TiendaID': TiendaID,
        'precio': precio,
        'PerfilID': PerfilID,
        'visible': visible,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('productos')
          .add(nuevoProducto);

      print('Producto registrado correctamente');
      return true;
    } catch (e) {
      print('Error al registrar producto: $e');
      return false;
    }
  }

  // Actualizar producto
  Future<bool> actualizarProducto(
      String UID,
      String ProductoID,
      String nombre,
      List<String> imagenesExistentes,
      List<File> nuevasImagenes,
      String TiendaID,
      double precio,
      List<String> visible,
      Productos? productoActual) async {
    if (nombre.trim().isEmpty) {
      print('El nombre del producto no puede estar vacío');
      return false;
    }
    if (precio <= 0) {
      print('El precio debe ser mayor que 0');
      return false;
    }
    if (TiendaID.trim().isEmpty) {
      print('El TiendaID no puede estar vacío');
      return false;
    }
    if (productoActual == null &&
        (imagenesExistentes.isEmpty && nuevasImagenes.isEmpty)) {
      print('Debes tener al menos una imagen');
      return false;
    }
    try {
      // Si tienes el producto actual, compara campos
      Map<String, dynamic> productoActualizado = {};

      // Comprobar nombre
      if (productoActual == null || productoActual.nombre != nombre) {
        productoActualizado['nombre'] = nombre;
      }

      // Comprobar imágenes
      List<String> urlsImagenes = List.from(imagenesExistentes);
      for (var imagen in nuevasImagenes) {
        final ref = FirebaseStorage.instance.ref().child(
            'productos/$UID/${DateTime.now().millisecondsSinceEpoch}_${imagen.path.split('/').last}');
        await ref.putFile(imagen);
        final url = await ref.getDownloadURL();
        urlsImagenes.add(url);
      }
      if (productoActual == null ||
          productoActual.imagenes.join(',') != urlsImagenes.join(',')) {
        productoActualizado['imagenes'] = urlsImagenes;
      }

      // Comprobar TiendaID
      if (productoActual == null || productoActual.TiendaID != TiendaID) {
        productoActualizado['TiendaID'] = TiendaID;
      }

      // Comprobar precio
      if (productoActual == null || productoActual.precio != precio) {
        productoActualizado['precio'] = precio;
      }

      // Comprobar visible
      if (productoActual == null ||
          productoActual.visible.join(',') != visible.join(',')) {
        productoActualizado['visible'] = visible;
      }

      if (productoActualizado.isEmpty) {
        print('No hay cambios para actualizar');
        return true;
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('productos')
          .doc(ProductoID)
          .update(productoActualizado);

      print('Producto con ID $ProductoID actualizado');
      return true;
    } catch (e) {
      print('Error al actualizar producto: $e');
      return false;
    }
  }

  // Eliminar producto
  Future<bool> eliminarProducto(String UID, String ProductoID) async {
    try {
      // Obtener el producto para saber las imágenes a borrar
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('productos')
          .doc(ProductoID)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final List<String> imagenes = List<String>.from(data['imagenes'] ?? []);
        // Eliminar cada imagen de Storage
        for (final url in imagenes) {
          try {
            final ref = FirebaseStorage.instance.refFromURL(url);
            await ref.delete();
          } catch (e) {
            print('Error al eliminar imagen de Storage: $e');
          }
        }
      }

      // Eliminar el documento del producto
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('productos')
          .doc(ProductoID)
          .delete();

      print('Producto con ID $ProductoID eliminado');
      return true;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }

  // Obtener productos paginados
  Future<List<Productos>> getProductosPaginados(
    String UID,
    String PerfilID, {
    DocumentSnapshot? lastDoc,
    int pageSize = 20,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('productos')
          .where('visible', arrayContains: PerfilID)
          .orderBy('nombre') // <-- IMPORTANTE para paginación
          .limit(pageSize);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) =>
              Productos.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error al obtener productos paginados: $e');
      return [];
    }
  }

  // Obtener los archivos de las imágenes del producto
  Future<List<File>?> getArchivosImagenesProducto(
      String UID, String ProductoID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('productos')
          .doc(ProductoID)
          .get();

      if (!doc.exists) {
        print('Producto no encontrado');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      final List<String> imagenes = List<String>.from(data['imagenes'] ?? []);
      if (imagenes.isEmpty) {
        print('El producto no tiene imágenes');
        return [];
      }

      final tempDir = await getTemporaryDirectory();
      List<File> archivos = [];

      for (int i = 0; i < imagenes.length; i++) {
        final url = imagenes[i];
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final file = File('${tempDir.path}/producto_${ProductoID}_$i.jpg');
          await file.writeAsBytes(response.bodyBytes);
          archivos.add(file);
        } else {
          print('No se pudo descargar la imagen $url');
        }
      }
      return archivos;
    } catch (e) {
      print('Error al obtener archivos de imágenes del producto: $e');
      return null;
    }
  }
}
