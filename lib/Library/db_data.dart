import 'package:mysql1/mysql1.dart';

class DB {
  Future<MySqlConnection> conexion() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'lin155.loading.es',
      port: 3306,
      user: 'jaquemat_usr',
      password: 'infor_matica_7',
      db: 'apptercera_',
    ));
    return conn;
  }
}
