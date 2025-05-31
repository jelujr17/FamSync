// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Eventos {
  final String EventoID;
  final String nombre;
  final String descripcion;
  final Timestamp fechaInicio;
  final Timestamp fechaFin;
  final String PerfilID;
  final String? CategoriaID;
  final List<String> participantes;

  final String? TareaID;

  Eventos({
    required this.EventoID,
    required this.nombre,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.PerfilID,
    required this.CategoriaID,
    required this.participantes,
    required this.TareaID,
  });

  factory Eventos.fromMap(String id, Map<String, dynamic> data) {
    return Eventos(
      EventoID: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fechaInicio: data['fechaInicio'] as Timestamp? ?? Timestamp.now(),
      fechaFin: data['fechaFin'] as Timestamp? ?? Timestamp.now(),
      PerfilID: data['PerfilID'] ?? '',
      CategoriaID: data['CategoriaID'],
      participantes: List<String>.from(data['participantes'] ?? []),
      TareaID: data['TareaID'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'PerfilID': PerfilID,
      'CategoriaID': CategoriaID,
      'participantes': participantes,
      'TareaID': TareaID,
    };
  }
}

class ServicioEventos {
  // Obtener eventos por usuario y perfil
  Future<List<Eventos>> getEventos(
       String UID, String PerfilID) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('eventos')
          .where('participantes', arrayContains: PerfilID)
          .get();

      return snapshot.docs
          .map((doc) => Eventos.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener los eventos: $e');
      return [];
    }
  }

  // Obtener eventos diarios (por fecha y participante)
  Future<List<Eventos>> getEventosDiarios( String UID,
      String PerfilID, Timestamp fecha) async {
    try {
      final inicio = DateTime(
          fecha.toDate().year, fecha.toDate().month, fecha.toDate().day);
      final fin = inicio.add(Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('eventos')
          .where('participantes', arrayContains: PerfilID)
          .where('fechaInicio',
              isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('fechaInicio', isLessThan: Timestamp.fromDate(fin))
          .get();

      return snapshot.docs
          .map((doc) => Eventos.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener eventos diarios: $e');
      return [];
    }
  }

  // Obtener evento por ID
  Future<Eventos?> getEventoById(
       String UID, String EventoID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('eventos')
          .doc(EventoID)
          .get();

      if (doc.exists) {
        return Eventos.fromMap(doc.id, doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener el evento: $e');
      return null;
    }
  }

  // Registrar evento
  Future<bool> registrarEvento(
      
      String UID,
      String nombre,
      String descripcion,
      Timestamp fechaInicio,
      Timestamp fechaFin,
      String PerfilID,
      String? CategoriaID,
      List<String> participantes,
      String? TareaID) async {
    // Validación de fechas
    if (fechaInicio.compareTo(fechaFin) > 0) {
      print('La fecha de inicio no puede ser posterior a la fecha de fin');
      return false;
    }
    try {
      final nuevoEvento = {
        'nombre': nombre,
        'descripcion': descripcion,
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        'PerfilID': PerfilID,
        'CategoriaID': CategoriaID,
        'participantes': participantes,
        'TareaID': TareaID,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('eventos')
          .add(nuevoEvento);

      print('Evento registrado correctamente');
      return true;
    } catch (e) {
      print('Error al registrar evento: $e');
      return false;
    }
  }

  // Actualizar evento
  Future<bool> actualizarEvento(
      
      String UID,
      String EventoID,
      String nombre,
      String descripcion,
      Timestamp fechaInicio,
      Timestamp fechaFin,
      String PerfilID,
      String? CategoriaID,
      List<String> participantes,
      String? TareaID) async {
    // Validación de fechas
    if (fechaInicio.compareTo(fechaFin) > 0) {
      print('La fecha de inicio no puede ser posterior a la fecha de fin');
      return false;
    }
    try {
      final eventoActualizado = {
        'nombre': nombre,
        'descripcion': descripcion,
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        'PerfilID': PerfilID,
        'CategoriaID': CategoriaID,
        'participantes': participantes,
        'TareaID': TareaID,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('eventos')
          .doc(EventoID)
          .update(eventoActualizado);

      print('Evento con ID $EventoID actualizado');
      return true;
    } catch (e) {
      print('Error al actualizar evento: $e');
      return false;
    }
  }

  // Eliminar evento
  Future<bool> eliminarEvento(
       String UID, String EventoID) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('eventos')
          .doc(EventoID)
          .delete();

      print('Evento con ID $EventoID eliminado');
      return true;
    } catch (e) {
      print('Error al eliminar evento: $e');
      return false;
    }
  }
}
