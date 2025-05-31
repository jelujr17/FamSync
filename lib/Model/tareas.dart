// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Tareas {
  final String TareaID; // ID de Firestore
  final String creador; // Asignar el UID del usuario que crea la tarea
  final List<String> destinatario; // Lista de UIDs o PerfilIDs
  final String nombre;
  final String descripcion;
  final String? CategoriaID; // ID de la categoría
  final String? EventoID;
  final int prioridad;
  final int progreso;

  Tareas({
    required this.TareaID,
    required this.creador, // Asignar el UID del usuario que crea la tarea
    required this.destinatario,
    required this.nombre,
    required this.descripcion,
    required this.CategoriaID,
    required this.EventoID,
    required this.prioridad,
    required this.progreso,
  });

  factory Tareas.fromMap(String id, Map<String, dynamic> data) {
    return Tareas(
      TareaID: id,
      creador: data['Creador'] ?? '', // Asignar el UID del usuario que crea la tarea
      destinatario: List<String>.from(data['destinatario'] ?? []),
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      CategoriaID: data['CategoriaID'],
      EventoID: data['EventoID'],
      prioridad: data['prioridad'] ?? 0,
      progreso: data['progreso'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Creador': creador, // Asignar el PerfilID del perfil que crea la tarea
      'destinatario': destinatario,
      'nombre': nombre,
      'descripcion': descripcion,
      'CategoriaID': CategoriaID,
      'EventoID': EventoID,
      'prioridad': prioridad,
      'progreso': progreso,
    };
  }
}

class ServicioTareas {
  // Obtener tareas por perfil (destinatario)
  Future<List<Tareas>> getTareas(
       String UID, String PerfilID) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('tareas')
          .where('destinatario', arrayContains: PerfilID)
          .get();

      return snapshot.docs
          .map((doc) => Tareas.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener las tareas: $e');
      return [];
    }
  }

  // Obtener tarea por ID
  Future<Tareas?> getTareasById(
       String UID, String TareaID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('tareas')
          .doc(TareaID)
          .get();

      if (doc.exists) {
        return Tareas.fromMap(doc.id, doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener la tarea: $e');
      return null;
    }
  }

  // Registrar tarea
  Future<bool> registrarTarea(
    
    String UID,
    String creador, // Asignar el UID del usuario que crea la tarea
    List<String> destinatario,
    String nombre,
    String descripcion,
    String? EventoID,
    String? CategoriaID,
    int prioridad,
    int progreso,
  ) async {
    try {
      final nuevaTarea = {
        'Creador': creador,
        'destinatario': destinatario,
        'nombre': nombre,
        'descripcion': descripcion,
        'CategoriaID': CategoriaID,
        'EventoID': EventoID,
        'prioridad': prioridad,
        'progreso': progreso,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('tareas')
          .add(nuevaTarea);

      print('Tarea registrada correctamente');
      return true;
    } catch (e) {
      print('Error al registrar tarea: $e');
      return false;
    }
  }

  // Actualizar tarea
  Future<bool> actualizarTarea(
    
    String UID,
    String TareaID,
    String creador,
    List<String> destinatario,
    String nombre,
    String descripcion,
    String? EventoID,
    String? CategoriaID,
    int prioridad,
    int progreso,
  ) async {
    try {
      final tareaActualizada = {
        'Creador': creador,
        'destinatario': destinatario,
        'nombre': nombre,
        'descripcion': descripcion,
        'CategoriaID': CategoriaID,
        'EventoID': EventoID,
        'prioridad': prioridad,
        'progreso': progreso,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('tareas')
          .doc(TareaID)
          .update(tareaActualizada);

      print('Tarea con ID $TareaID actualizada');
      return true;
    } catch (e) {
      print('Error al actualizar tarea: $e');
      return false;
    }
  }

  // Eliminar tarea
  Future<bool> eliminarTarea(
       String UID, String TareaID) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('tareas')
          .doc(TareaID)
          .delete();

      print('Tarea con ID $TareaID eliminada');
      return true;
    } catch (e) {
      print('Error al eliminar tarea: $e');
      return false;
    }
  }
}
