// ignore_for_file: avoid_print, non_constant_identifier_names
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Perfiles {
  final int Id;
  final int UsuarioId;
  final String Nombre;
  final String FotoPerfil;
  final int Pin;
  final String FechaNacimiento;

  Perfiles({
    required this.Id,
    required this.UsuarioId,
    required this.Nombre,
    required this.FotoPerfil,
    required this.Pin,
    required this.FechaNacimiento,
  });
}

class ServicioPerfiles {
  // Datos estáticos para simular respuestas de la API
  final List<Perfiles> _perfilesEstaticos = [
    Perfiles(
      Id: 1,
      UsuarioId: 1,
      Nombre: "Perfil Principal",
      FotoPerfil: "avatar1.png",
      Pin: 1234,
      FechaNacimiento: "1990-01-01",
    ),
    Perfiles(
      Id: 2,
      UsuarioId: 1,
      Nombre: "Perfil Niños",
      FotoPerfil: "avatar2.png",
      Pin: 0000,
      FechaNacimiento: "2015-05-15",
    ),
    Perfiles(
      Id: 3,
      UsuarioId: 2,
      Nombre: "Usuario Dos",
      FotoPerfil: "avatar3.png",
      Pin: 5678,
      FechaNacimiento: "1985-10-20",
    ),
    Perfiles(
      Id: 4,
      UsuarioId: 3,
      Nombre: "Admin",
      FotoPerfil: "admin.png",
      Pin: 9999,
      FechaNacimiento: "1980-12-31",
    ),
  ];

  // Obtener perfiles por usuario
  Future<List<Perfiles>> getPerfiles(
      BuildContext context, int UsuarioId) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 500));

    return _perfilesEstaticos
        .where((perfil) => perfil.UsuarioId == UsuarioId)
        .toList();
  }

  // Obtener perfil por ID
  Future<Perfiles?> getPerfilById(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _perfilesEstaticos.firstWhere((perfil) => perfil.Id == Id);
    } catch (e) {
      return null; // Si no encuentra el perfil
    }
  }

  // Registrar perfil
  Future<bool> registrarPerfilFirebase(
    BuildContext context,
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
      final storageRef = FirebaseStorage.instance.ref().child(
          'perfiles/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.png');

      await storageRef.putFile(imagen);
      final fotoUrl = await storageRef.getDownloadURL();

      // 2. Crear perfil en Firestore
      final perfilData = {
        'UsuarioId': user.uid,
        'Nombre': nombre,
        'FotoPerfil': fotoUrl,
        'Pin': pin,
        'FechaNacimiento': fechaNacimiento
      };

      await FirebaseFirestore.instance.collection('perfiles').add(perfilData);

      print('Perfil registrado correctamente');
      return true;
    } catch (e) {
      print('Error al registrar perfil: $e');
      return false;
    }
  }

  // Editar perfil
  Future<bool> editarPerfil(
      BuildContext context,
      int Id,
      String Nombre,
      File? imagen,
      int Pin,
      String FechaNacimiento,
      String? fotoAnterior) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Buscar índice del perfil a actualizar
    final index = _perfilesEstaticos.indexWhere((p) => p.Id == Id);
    if (index == -1) {
      return false; // No se encontró el perfil
    }

    // Determinar la foto de perfil
    String fotoPerfil = fotoAnterior ?? _perfilesEstaticos[index].FotoPerfil;

    // Si hay una nueva imagen, simular el procesamiento
    if (imagen != null) {
      fotoPerfil = "perfil_${Id}_${DateTime.now().millisecondsSinceEpoch}.png";
    }

    // Crear el perfil actualizado
    final perfilActualizado = Perfiles(
      Id: Id,
      UsuarioId: _perfilesEstaticos[index].UsuarioId,
      Nombre: Nombre,
      FotoPerfil: fotoPerfil,
      Pin: Pin,
      FechaNacimiento: FechaNacimiento,
    );

    // Actualizar el perfil en la lista estática
    _perfilesEstaticos[index] = perfilActualizado;

    print('Perfil con ID $Id actualizado');
    return true;
  }

  // Eliminar perfil
  Future<bool> eliminarPerfil(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 400));

    // Buscar índice del perfil a eliminar
    final index = _perfilesEstaticos.indexWhere((p) => p.Id == Id);
    if (index == -1) {
      return false; // No se encontró el perfil
    }

    // Eliminar el perfil de la lista estática
    _perfilesEstaticos.removeAt(index);

    print('Perfil con ID $Id eliminado');
    return true;
  }

  // Obtener imagen de perfil
  Future<File> obtenerImagen(BuildContext context, String nombre) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 600));

    // Crear un archivo temporal vacío para simular la imagen
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$nombre';
    final file = File(filePath);

    if (!file.existsSync()) {
      await file.create();
      // Aquí podrías escribir bytes de una imagen por defecto si lo necesitas
    }

    print('Imagen obtenida: $nombre');
    return file;
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
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => NoconnectionScreen()),
      // );
      throw Exception('Error simulado en la conexión con la base de datos');
    }
  }
}
