// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:mysql1/mysql1.dart';
import 'package:smart_family/Library/db_data.dart';
import 'package:bcrypt/bcrypt.dart';

abstract class Authenticatable {}

// CLASES DE PERSONAS REALES
class Usuario implements Authenticatable {
  final int Id;
  final int Telefono;
  final String Correo;
  final String Nombre;
  final String Password;

  Usuario(
      {required this.Id,
      required this.Telefono,
      required this.Correo,
      required this.Nombre,
      required this.Password});

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
        Id: map['Id'] as int,
        Telefono: map['Telefono'] as int,
        Correo: map['Correo'] as String,
        Nombre: map['Nombre'] as String,
        Password: map['Password'] as String);
  }
}

class ServicioUsuarios {
  // BUSCAR USUARIOS //
  Future<List<Usuario>> getUsuarios() async {
    MySqlConnection conn = await DB().conexion();
    try {
      final resultado = await conn.query('SELECT * FROM usuarios');
      final List<Usuario> usuarios = resultado.map((row) {
        return Usuario(
            Id: row['Id'],
            Telefono: row['Telefono'],
            Correo: row['Correo'],
            Nombre: row['Nombre'],
            Password: row['Password']);
      }).toList();
      return usuarios;
    } catch (e) {
      print('Error al obtener los usuarios existentes: $e');
      return []; // Devolver una lista vacía en caso de error
    } finally {
      await conn.close();
    }
  }

  Future<Usuario?> getUsuarioByCorreo(String Correo) async {
    MySqlConnection conn = await DB().conexion();
    try {
      final resultado =
          await conn.query('SELECT * FROM usuarios WHERE Correo = ?', [Correo]);
      if (resultado.isNotEmpty) {
        final usuario = Usuario(
          Id: resultado.first['Id'],
          Telefono: resultado.first['Telefono'],
          Correo: resultado.first['Correo'].toString(),
          Nombre: resultado.first['Nombre'].toString(),
          Password: resultado.first['Password'].toString(),
        );
        return usuario;
      }
      return null;
    } catch (e) {
      print('Error al recibir el usuario por correo: $e');
      return null;
    } finally {
      await conn.close();
    }
  }

  Future<Usuario?> getUsuarioByTelefono(int Telefono) async {
    MySqlConnection conn = await DB().conexion();
    try {
      final resultado = await conn
          .query('SELECT * FROM usuarios WHERE Telefono = ?', [Telefono]);
      if (resultado.isNotEmpty) {
        final usuario = Usuario(
          Id: resultado.first['Id'],
          Telefono: resultado.first['Telefono'],
          Correo: resultado.first['Correo'].toString(),
          Nombre: resultado.first['Nombre'].toString(),
          Password: resultado.first['Password'].toString(),
        );
        return usuario;
      }
      return null;
    } catch (e) {
      print('Error al recibir el usuario por telefono: $e');
      return null;
    } finally {
      await conn.close();
    }
  }

  // LOGIN CON DEVUELTA DE USUARIO
  Future<Usuario?> login(String usuario, String password) async {
    print("usuario: $usuario, contraseña: $password");
    // Comprobacion de que el correo existe
    Usuario? usuarioAuxiliar;
    if (usuario.contains("@")) {
      usuarioAuxiliar = await getUsuarioByCorreo(usuario);
    } else {
      usuarioAuxiliar = await getUsuarioByTelefono(int.parse(usuario));
    }
    //------------------------------------------------------------------

    if (usuarioAuxiliar == null) {
      print("No existe un usuario con ese correo o telefono");
    } else {
      if (BCrypt.checkpw(password, usuarioAuxiliar.Password)) {
        print("Contraseña correcta");
        return usuarioAuxiliar;
      } else {
        print("Contraseña incorrecta");
      }
    }
    return null;
    // Si se devuelve null es que o el usuario no existe o que la contraseña no es correcta
  }

  // REGISTRO DE USUARIO
  Future<bool> isCorreoRegistered(String correo) async {
    MySqlConnection conn = await DB().conexion();
    try {
      final resultado =
          await conn.query('SELECT * FROM usuarios WHERE Correo = ?', [correo]);
      return resultado.isNotEmpty;
    } catch (e) {
      print('Error al verificar el correo: $e');
      return false;
    } finally {
      await conn.close();
    }
  }

  // Verificar si el teléfono ya está registrado
  Future<bool> isTelefonoRegistered(int telefono) async {
    MySqlConnection conn = await DB().conexion();
    try {
      final resultado = await conn
          .query('SELECT * FROM usuarios WHERE Telefono = ?', [telefono]);
      return resultado.isNotEmpty;
    } catch (e) {
      print('Error al verificar el teléfono: $e');
      return false;
    } finally {
      await conn.close();
    }
  }

  // Registro de usuario con verificación
  Future<bool> registrarUsuario(
      int telefono, String correo, String nombre, String password) async {
    if (await isCorreoRegistered(correo)) {
      print('El correo ya está registrado');
      return false;
    }

    if (await isTelefonoRegistered(telefono)) {
      print('El teléfono ya está registrado');
      return false;
    }

    MySqlConnection conn = await DB().conexion();
    try {
      await conn.query(
          'INSERT INTO usuarios (Telefono, Correo, Nombre, Password) VALUES (?, ?, ?, ?)',
          [telefono, correo, nombre, password]);

      return true;
    } catch (e) {
      print('Registro de usuario fallido: $e');
      return false;
    } finally {
      await conn.close();
    }
  }
}
