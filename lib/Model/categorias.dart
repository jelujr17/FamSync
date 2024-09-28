// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:mysql1/mysql1.dart';
import 'package:famsync/Library/db_data.dart';

// CLASES DE PERSONAS REALES
class Categorias {
  final int Id;
  final int IdModulo;
  final int IdColor;
  final String Nombre;
  final int IdCreador;
  final String Descripcion;

  Categorias(
      {required this.Id,
      required this.IdModulo,
      required this.IdColor,
      required this.Nombre,
      required this.IdCreador,
      required this.Descripcion});
}

class ServicioCategorias {
  Future<List<Categorias>> getCategorias() async {
    MySqlConnection conn = await DB().conexion();
    try {
      // Asegúrate de que la columna 'UsuarioId' y las demás existan en tu tabla y estén correctamente escritas.
      final resultado = await conn.query('SELECT * FROM categorias');
      final List<Categorias> categorias = resultado.map((row) {
        return Categorias(
          Id: row['Id'],
          IdModulo: row['IdModulo'],
          IdColor: row['IdColor'],
          Nombre: row['Nombre'].toString(),
          IdCreador: row['IdCreador'],
          Descripcion: row['Descripcion'].toString(),
        );
      }).toList();
      return categorias;
    } catch (e) {
      print(
          'Error al obtener las categorias existentes.');
      return []; // Devolver una lista vacía en caso de error
    } finally {
      await conn.close();
    }
  }

  Future<Categorias?> getCategoriaById(int Id) async {
    MySqlConnection conn = await DB().conexion();
    try {
      final resultado =
          await conn.query('SELECT * FROM categorias WHERE Id = ?', [Id]);
      if (resultado.isNotEmpty) {
        final categoria = Categorias(
          Id: resultado.first['Id'],
          IdModulo: resultado.first['IdModulo'],
          IdColor: resultado.first['IdColor'],
          Nombre: resultado.first['Nombre'].toString(),
          IdCreador: resultado.first['IdCreador'],
          Descripcion: resultado.first['Descripcion'].toString(),
        );
        return categoria;
      }
      return null;
    } catch (e) {
      print('Error al recibir la categoria por id: $e');
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

  Future<bool> eliminarPerfil(int Id) async {
    MySqlConnection conn = await DB().conexion();
    print("-------");
    print(Id);

    try {
      await conn.query('DELETE FROM perfiles WHERE Id = ?', [Id]);

      return true;
    } catch (e) {
      print('Eliminación de perfil fallido: $e');
      return false;
    } finally {
      await conn.close();
    }
  }
}
