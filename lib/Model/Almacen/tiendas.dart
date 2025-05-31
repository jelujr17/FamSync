// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Tiendas {
  final String TiendaID;
  final String nombre;

  Tiendas({
    required this.TiendaID,
    required this.nombre,
  });

  factory Tiendas.fromMap(String id, Map<String, dynamic> data) {
    return Tiendas(
      TiendaID: id,
      nombre: data['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
    };
  }
}

class ServiciosTiendas {
  // Obtener tiendas por usuario
  Future<List<Tiendas>> getTiendas(String UID) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('tiendas')
          .get();

      return snapshot.docs
          .map((doc) => Tiendas.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener las tiendas: $e');
      return [];
    }
  }

  // Obtener tienda por ID
  Future<Tiendas?> getTiendasById(String UID, String TiendaID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('tiendas')
          .doc(TiendaID)
          .get();

      if (doc.exists) {
        return Tiendas.fromMap(doc.id, doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener la tienda: $e');
      return null;
    }
  }

  // Registrar tienda
  Future<bool> registrarTienda(String nombre, String UID) async {
    if (nombre.trim().isEmpty) {
      print('El nombre de la tienda no puede estar vacío');
      return false;
    }
    try {
      final nuevaTienda = {
        'nombre': nombre,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('tiendas')
          .add(nuevaTienda);

      print('Tienda registrada correctamente');
      return true;
    } catch (e) {
      print('Error al registrar tienda: $e');
      return false;
    }
  }

  // Actualizar tienda
  Future<bool> actualizarTienda(
      String UID, String TiendaID, String nombre) async {
    if (nombre.trim().isEmpty) {
      print('El nombre de la tienda no puede estar vacío');
      return false;
    }
    try {
      final tiendaActualizada = {
        'nombre': nombre,
        'UID': UID,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('tiendas')
          .doc(TiendaID)
          .update(tiendaActualizada);

      print('Tienda con ID $TiendaID actualizada');
      return true;
    } catch (e) {
      print('Error al actualizar tienda: $e');
      return false;
    }
  }

  // Eliminar tienda
  Future<bool> eliminarTienda(String UID, String TiendaID) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('tiendas')
          .doc(TiendaID)
          .delete();

      print('Tienda con ID $TiendaID eliminada');
      return true;
    } catch (e) {
      print('Error al eliminar tienda: $e');
      return false;
    }
  }
}
