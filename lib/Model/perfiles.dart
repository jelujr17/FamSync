// ignore_for_file: avUID_print, non_constant_identifier_names
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Perfiles {
  final String PerfilID;
  final String nombre;
  final String FotoPerfil;
  final int Pin;
  final String FechaNacimiento;

  Perfiles({
    required this.PerfilID,
    required this.nombre,
    required this.FotoPerfil,
    required this.Pin,
    required this.FechaNacimiento,
  });

  factory Perfiles.fromMap(String id, Map<String, dynamic> data) {
    return Perfiles(
      PerfilID: id,
      nombre: data['nombre'] ?? '',
      FotoPerfil: data['FotoPerfil'] ?? '',
      Pin: data['Pin'] ?? 0,
      FechaNacimiento: data['FechaNacimiento'] ?? '',
    );
  }
}

class ServicioPerfiles {
  // Obtener perfiles por usuario
  Future<List<Perfiles>> getPerfiles(String UID) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('perfiles')
          .get();

      return snapshot.docs
          .map((doc) => Perfiles.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener los perfiles: $e');
      return [];
    }
  }

  // Obtener perfil por ID
  Future<Perfiles?> getPerfilByPID(String UID, String PerfilID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('perfiles')
          .doc(PerfilID)
          .get();

      if (doc.exists) {
        return Perfiles.fromMap(doc.id, doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener el perfil: $e');
      return null;
    }
  }

  // Registrar perfil
  Future<bool> registrarPerfilFirebase(
    String UID,
    String nombre,
    File imagen,
    int pin,
    String fechaNacimiento,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Usuario no autenticado');
      return false;
    }

    try {
      // 1. Subir imagen a Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('perfiles/$UID/${DateTime.now().millisecondsSinceEpoch}.png');

      await storageRef.putFile(imagen);
      final fotoUrl = await storageRef.getDownloadURL();

      // 2. Crear perfil en Firestore
      final perfilData = {
        'nombre': nombre,
        'FotoPerfil': fotoUrl,
        'Pin': pin,
        'FechaNacimiento': fechaNacimiento
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('perfiles')
          .add(perfilData);

      print('Perfil registrado correctamente');
      return true;
    } catch (e) {
      print('Error al registrar perfil: $e');
      return false;
    }
  }

  // Editar perfil
  Future<bool> editarPerfil(
    String UID,
    String PerfilID,
    String nombre,
    File? imagen,
    int pin,
    String fechaNacimiento,
    String? fotoAnterior,
  ) async {
    try {
      String fotoPerfil = fotoAnterior ?? '';

      // Si hay una nueva imagen, subirla
      if (imagen != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'perfiles/$UID/${DateTime.now().millisecondsSinceEpoch}.png');
        await storageRef.putFile(imagen);
        fotoPerfil = await storageRef.getDownloadURL();
      }

      final perfilActualizado = {
        'nombre': nombre,
        'FotoPerfil': fotoPerfil,
        'Pin': pin,
        'FechaNacimiento': fechaNacimiento,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('perfiles')
          .doc(PerfilID)
          .update(perfilActualizado);

      print('Perfil con ID $PerfilID actualizado');
      return true;
    } catch (e) {
      print('Error al editar perfil: $e');
      return false;
    }
  }

  // Eliminar perfil
  Future<bool> eliminarPerfil(String UID, String PerfilID) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('perfiles')
          .doc(PerfilID)
          .delete();

      print('Perfil con ID $PerfilID eliminado');
      return true;
    } catch (e) {
      print('Error al eliminar perfil: $e');
      return false;
    }
  }

  // Obtener el archivo de la imagen de perfil
  Future<File?> getFotoPerfil(String UID, String PerfilID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(UID)
          .collection('perfiles')
          .doc(PerfilID)
          .get();

      if (!doc.exists) {
        print('Perfil no encontrado');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      final url = data['FotoPerfil'] as String?;
      if (url == null || url.isEmpty) {
        print('No hay foto de perfil');
        return null;
      }

      // Descargar la imagen y guardarla como archivo temporal
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/perfil_$PerfilID.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('No se pudo descargar la imagen');
        return null;
      }
    } catch (e) {
      print('Error al obtener el archivo de la foto de perfil: $e');
      return null;
    }
  }
}
