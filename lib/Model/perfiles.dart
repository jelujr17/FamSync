// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:mysql1/mysql1.dart';
import 'package:smart_family/Library/db_data.dart';

// CLASES DE PERSONAS REALES
class Perfiles {
  final int Id;
  final int UsuarioId;
  final String Nombre;
  final int FotoPerfilId;
  final int Pin;
  final String FechaNacimiento;

  Perfiles(
      {required this.Id,
      required this.UsuarioId,
      required this.Nombre,
      required this.FotoPerfilId,
      required this.Pin,
      required this.FechaNacimiento});
}

class ServicioPerfiles {
  // BUSCAR USUARIOS //
  Future<List<Perfiles>> getPerfiles(int UsuarioId) async {
    print("usuario $UsuarioId");
    MySqlConnection conn = await DB().conexion();
    try {
      // Asegúrate de que la columna 'UsuarioId' y las demás existan en tu tabla y estén correctamente escritas.
      final resultado = await conn
          .query('SELECT * FROM perfiles WHERE UsuarioId = ?', [UsuarioId]);
      final List<Perfiles> perfiles = resultado.map((row) {
        return Perfiles(
          Id: row['Id'],
          UsuarioId: row['UsuarioId'],
          Nombre: row['Nombre'].toString(),
          FotoPerfilId: row['FotoPerfilId'],
          Pin: row['Pin'],
          FechaNacimiento: row['FechaNacimiento'].toString(),
        );
      }).toList();
      return perfiles;
    } catch (e) {
      print(
          'Error al obtener los perfiles existentes del usuario $UsuarioId: $e');
      return []; // Devolver una lista vacía en caso de error
    } finally {
      await conn.close();
    }
  }

  Future<Perfiles?> getPerfilById(int Id) async {
    MySqlConnection conn = await DB().conexion();
    try {
      final resultado =
          await conn.query('SELECT * FROM perfiles WHERE Id = ?', [Id]);
      if (resultado.isNotEmpty) {
        final perfil = Perfiles(
          Id: resultado.first['Id'],
          UsuarioId: resultado.first['UsuarioId'],
          Nombre: resultado.first['Nombre'].toString(),
          FotoPerfilId: resultado.first['FotoPerfilId'],
          Pin: resultado.first['Pin'],
          FechaNacimiento: resultado.first['FechaNacimiento'].toString(),
        );
        return perfil;
      }
      return null;
    } catch (e) {
      print('Error al recibir el perfil por id: $e');
      return null;
    } finally {
      await conn.close();
    }
  }

  // Registro de usuario con verificación
  Future<bool> registrarPerfil(int UsuarioId, String Nombre, int FotoPerfilId,
      int Pin, String FechaNacimiento) async {
    MySqlConnection conn = await DB().conexion();
    try {
      await conn.query(
          'INSERT INTO perfiles (UsuarioId, Nombre, FotoPerfilId, Pin, FechaNacimiento) VALUES (?, ?, ?, ?, ?)',
          [UsuarioId, Nombre, FotoPerfilId, Pin, FechaNacimiento]);

      return true;
    } catch (e) {
      print('Registro de perfil fallido: $e');
      return false;
    } finally {
      await conn.close();
    }
  }

  Future<bool> editarPerfil(int Id, String Nombre, int FotoPerfilId, int Pin,
      String FechaNacimiento) async {
    MySqlConnection conn = await DB().conexion();
    print("-------");
    print(Id);
    print(Nombre);
    print(FotoPerfilId);
    print(Pin);
    print(FechaNacimiento);
    try {
      await conn.query(
          'UPDATE perfiles SET Nombre = ?, FotoPerfilId = ?, Pin = ?, FechaNacimiento = ? WHERE Id = ?',
          [Nombre, FotoPerfilId, Pin, FechaNacimiento, Id]);

      return true;
    } catch (e) {
      print('Registro de perfil fallido: $e');
      return false;
    } finally {
      await conn.close();
    }
  }
}
