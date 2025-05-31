// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Listas {
  final String ListaID;
  final String nombre;
  final String PerfilID;
  final List<String> visible;
  final List<String> productos;

  Listas({
    required this.ListaID,
    required this.nombre,
    required this.PerfilID,
    required this.visible,
    required this.productos,
  });

  factory Listas.fromMap(String id, Map<String, dynamic> data) {
    return Listas(
      ListaID: id,
      nombre: data['nombre'] ?? '',
      PerfilID: data['PerfilID'] ?? '',
      visible: List<String>.from(data['visible'] ?? []),
      productos: List<String>.from(data['productos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'PerfilID': PerfilID,
      'visible': visible,
      'productos': productos,
    };
  }
}

class ServiciosListas {
  // Obtener listas por usuario y perfil
  Future<List<Listas>> getListas(String UID, String PerfilID) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('listas')
          .where('visible', arrayContains: PerfilID)
          .get();

      return snapshot.docs
          .map((doc) => Listas.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener listas: $e');
      return [];
    }
  }

  // Obtener lista por ID
  Future<Listas?> getListasById(String UID, String ListaID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('listas')
          .doc(ListaID)
          .get();

      if (doc.exists) {
        return Listas.fromMap(doc.id, doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener la lista: $e');
      return null;
    }
  }

  // Registrar una nueva lista
  Future<bool> registrarLista(
      String nombre, String PerfilID, String UID, List<String> visible) async {
    if (nombre.trim().isEmpty) {
      print('El nombre de la lista no puede estar vacío');
      return false;
    }
    if (PerfilID.trim().isEmpty) {
      print('El PerfilID no puede estar vacío');
      return false;
    }
    if (UID.trim().isEmpty) {
      print('El UID no puede estar vacío');
      return false;
    }
    // Asegurarse que el perfil creador esté en la lista de visibles
    if (!visible.contains(PerfilID)) {
      visible.add(PerfilID);
    }
    try {
      final nuevaLista = {
        'nombre': nombre,
        'PerfilID': PerfilID,
        'visible': visible,
        'productos': [],
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('listas')
          .add(nuevaLista);

      print('Lista registrada correctamente');
      return true;
    } catch (e) {
      print('Error al registrar lista: $e');
      return false;
    }
  }

  // Actualizar una lista
  Future<bool> actualizarLista(String UID, String ListaID, String nombre,
      List<String> visible, List<String> productos) async {
    if (nombre.trim().isEmpty) {
      print('El nombre de la lista no puede estar vacío');
      return false;
    }
    try {
      final listaActualizada = {
        'nombre': nombre,
        'visible': visible,
        'productos': productos,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('listas')
          .doc(ListaID)
          .update(listaActualizada);

      print('Lista con ID $ListaID actualizada');
      return true;
    } catch (e) {
      print('Error al actualizar lista: $e');
      return false;
    }
  }

  // Eliminar una lista
  Future<bool> eliminarLista(String UID, String ListaID) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('listas')
          .doc(ListaID)
          .delete();

      print('Lista con ID $ListaID eliminada');
      return true;
    } catch (e) {
      print('Error al eliminar lista: $e');
      return false;
    }
  }

  Future<bool> eliminarProducto(
      String UID, String ListaID, String ProductoID) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('listas')
          .doc(ListaID);

      final doc = await docRef.get();
      if (!doc.exists) {
        print('La lista no existe');
        return false;
      }
      List<String> productos = List<String>.from(doc['productos'] ?? []);
      if (!productos.contains(ProductoID)) {
        print('El producto no está en la lista');
        return false;
      }

      await docRef.update({
        'productos': FieldValue.arrayRemove([ProductoID])
      });
      print('Producto $ProductoID eliminado de la lista $ListaID');
      return true;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }

  // Incluir producto en una lista
  Future<bool> incluirProducto(
      String UID, String ListaID, String ProductoID) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('listas')
          .doc(ListaID);

      final doc = await docRef.get();
      if (!doc.exists) {
        print('La lista no existe');
        return false;
      }

      List<String> productos = List<String>.from(doc['productos'] ?? []);
      if (productos.contains(ProductoID)) {
        print('El producto ya está en la lista');
        return false;
      }

      await docRef.update({
        'productos': FieldValue.arrayUnion([ProductoID])
      });
      print('Producto $ProductoID añadido a la lista $ListaID');
      return true;
    } catch (e) {
      print('Error al incluir producto en la lista: $e');
      return false;
    }
  }
}
