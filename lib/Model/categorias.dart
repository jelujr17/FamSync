// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Categorias {
  final String CategoriaID; // Usamos String para el ID de Firestore
  final String Color;
  final String nombre;
  final String PerfilID; // Ahora es String (UID de Firebase)

  Categorias({
    required this.CategoriaID,
    required this.Color,
    required this.nombre,
    required this.PerfilID,
  });

  factory Categorias.fromMap(String CategoriaID, Map<String, dynamic> data) {
    return Categorias(
      CategoriaID: CategoriaID,
      Color: data['Color'] ?? '',
      nombre: data['nombre'] ?? '',
      PerfilID: data['PerfilID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'CategoriaID': CategoriaID,
      'Color': Color,
      'nombre': nombre,
      'PerfilID': PerfilID,
    };
  }
}

class ServiciosCategorias {
  // Obtener todas las categorías de un usuario
  Future<List<Categorias>> getCategorias(
       String UID, String PerfilID) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('categorias')
          .where('PerfilID', isEqualTo: PerfilID) // Filtrar por PerfilID
          .get();

      return snapshot.docs
          .map((doc) => Categorias.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener las categorías: $e');
      return [];
    }
  }

  // Obtener categoría por ID
  Future<Categorias?> getCategoriasID(
       String UID, String CategoriaID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('categorias')
          .doc(CategoriaID)
          .get();

      if (doc.exists) {
        return Categorias.fromMap(doc.id, doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener la categoría: $e');
      return null;
    }
  }

  // Registrar categoría
  Future<bool> registrarCategoria( String UID,
      String PerfilID, String nombre, String Color) async {
    try {
      final nuevaCategoria = {
        'nombre': nombre,
        'Color': Color,
        'PerfilID': PerfilID,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('categorias')
          .add(nuevaCategoria);

      print('Categoría registrada correctamente');
      return true;
    } catch (e) {
      print('Error al registrar categoría: $e');
      return false;
    }
  }

  // Actualizar categoría
  Future<bool> actualizarCategoria( String UID,
      String CategoriaID, String PerfilID, String nombre, String Color) async {
    try {
      final categoriaActualizada = {
        'nombre': nombre,
        'Color': Color,
        'PerfilID': PerfilID,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('categorias')
          .doc(CategoriaID)
          .update(categoriaActualizada);

      print('Categoría con ID $CategoriaID actualizada');
      return true;
    } catch (e) {
      print('Error al actualizar categoría: $e');
      return false;
    }
  }

  // Eliminar categoría
  Future<bool> eliminarCategoria(
       String UID, String CategoriaID) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('categorias')
          .doc(CategoriaID)
          .delete();

      print('Categoría con ID $CategoriaID eliminada');
      return true;
    } catch (e) {
      print('Error al eliminar categoría: $e');
      return false;
    }
  }
}
