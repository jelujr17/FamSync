import 'package:mysql1/mysql1.dart';

class DB {
  Future<MySqlConnection> conexion() async {
    MySqlConnection conn;
    try {
      conn = await MySqlConnection.connect(ConnectionSettings(
        host: '172.27.147.244',
        port: 3306,
        user: 'root',
        password: 'root',
        db: 'smart_family',
      ));
    } catch (e) {
      conn = await MySqlConnection.connect(ConnectionSettings(
        host: '192.168.0.32',
        port: 3306,
        user: 'root',
        password: 'root',
        db: 'smart_family',
      ));
    }
    return conn;
  }
}
