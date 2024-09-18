// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:mysql1/mysql1.dart';
import 'package:smart_family/Library/db_data.dart';

// CLASES DE PERSONAS REALES
class Modulos {
  final int Id;
  final String Nombre;
  final String Descripcion;

  Modulos({required this.Id, required this.Nombre, required this.Descripcion});
}

class ServicioModulos {
  Future<List<Modulos>> getModulos() async {
    MySqlConnection conn = await DB().conexion();
    try {
      // Asegúrate de que la columna 'UsuarioId' y las demás existan en tu tabla y estén correctamente escritas.
      final resultado = await conn.query('SELECT * FROM modulos');
      final List<Modulos> modulos = resultado.map((row) {
        return Modulos(
            Id: row['Id'],
            Nombre: row['Nombre'].toString(),
            Descripcion: row['Descripcion'].toString());
      }).toList();
      return modulos;
    } catch (e) {
      print('Error al obtener los mosdulos existentes.');
      return []; // Devolver una lista vacía en caso de error
    } finally {
      await conn.close();
    }
  }

  Future<Modulos?> getModulosById(int Id) async {
    MySqlConnection conn = await DB().conexion();
    try {
      final resultado =
          await conn.query('SELECT * FROM modulos WHERE Id = ?', [Id]);
      if (resultado.isNotEmpty) {
        final modulo = Modulos(
            Id: resultado.first['Id'],
            Nombre: resultado.first['Nombre'].toString(),
            Descripcion: resultado.first['Descripcion'].toString());
        return modulo;
      }
      return null;
    } catch (e) {
      print('Error al recibir el modulo por id: $e');
      return null;
    } finally {
      await conn.close();
    }
  }
}
